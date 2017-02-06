
# Resolve cloud-devel-env.sh
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="$( dirname "${INSTALL_DIR}" )"
source "${BIN_DIR}/cloud-devel-env.sh"

# Make sure JDK already installed
if [ ! -f "${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}/bin/java" ] ; then
   ${INSTALL_DIR}/install-java.sh || fatal "Can't proceed with Accumulo install: Java install failed"
fi

# Make sure hadoop already installed
if [ ! -d "${CLOUD_DEVEL_HOME}/${CD_HADOOP_SYMLINK}/bin" ] ; then
   ${INSTALL_DIR}/install-hadoop.sh || fatal "Can't proceed with Accumulo install: Hadoop install failed"
fi

# Check for existence of zookeeper and accumulo tarballs, directories, etc...

[ -z "${CD_ZOOKEEPER_BASEDIR}" ] && fatal "CD_ZOOKEEPER_BASEDIR is not set. Is Accumulo not registered as a service?"
[ -z "${CD_ZOOKEEPER_DIST}" ] && fatal "CD_ZOOKEEPER_DIST is not set. Is Accumulo not registered as a service?"
[ -z "${CD_ZOOKEEPER_SYMLINK}" ] && fatal "CD_ZOOKEEPER_SYMLINK is not set. Is Accumulo not registered as a service?"
if [ -d "${CLOUD_DEVEL_HOME}/${CD_ZOOKEEPER_SYMLINK}/bin" ] ; then
   warn "ZooKeeper directory already exists: '${CLOUD_DEVEL_HOME}/${CD_ZOOKEEPER_SYMLINK}/bin'"
   fatal "Can't proceed with Accumulo install"
fi

[ -f "${INSTALL_DIR}/tarballs/${CD_ZOOKEEPER_DIST}" ] || fatal "ZooKeeper tarball not found"

[ -z "${CD_ACCUMULO_BASEDIR}" ] && fatal "CD_ACCUMULO_BASEDIR is not set. Is Accumulo not registered as a service?"
[ -z "${CD_ACCUMULO_DIST}" ] && fatal "CD_ACCUMULO_DIST is not set. Is Accumulo not registered as a service?"
[ -z "${CD_ACCUMULO_SYMLINK}" ] && fatal "CD_ACCUMULO_SYMLINK is not set. Is Accumulo not registered as a service?"
if [ -d "${CLOUD_DEVEL_HOME}/${CD_ACCUMULO_SYMLINK}/bin" ] ; then
   warn "Accumulo directory already exists: '${CLOUD_DEVEL_HOME}/${CD_ACCUMULO_SYMLINK}/bin'"
   fatal "Can't proceed with Accumulo install"
fi

[ -f "${INSTALL_DIR}/tarballs/${CD_ACCUMULO_DIST}" ] || fatal "Accumulo tarball not found"

# Ok to extract ZooKeeper, set symlink, and verify...
tar xf "${INSTALL_DIR}/tarballs/${CD_ZOOKEEPER_DIST}" -C "${BIN_DIR}" || fatal "Failed to extract ZooKeeper tarball"
( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/${CD_ZOOKEEPER_BASEDIR}" "${CD_ZOOKEEPER_SYMLINK}" ) || fatal "Failed to set ZooKeeper symlink"
[ -f "${CLOUD_DEVEL_HOME}/${CD_ZOOKEEPER_SYMLINK}/bin/zkServer.sh" ] || fatal "ZooKeeper was not installed"

# Ok to extract Accumulo, set symlink, and verify...
tar xf "${INSTALL_DIR}/tarballs/${CD_ACCUMULO_DIST}" -C "${BIN_DIR}" || fatal "Failed to extract Accumulo tarball"
( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/${CD_ACCUMULO_BASEDIR}" "${CD_ACCUMULO_SYMLINK}" ) || fatal "Failed to set Accumulo symlink"
[ -f "${CLOUD_DEVEL_HOME}/${CD_ACCUMULO_SYMLINK}/bin/accumulo" ] || fatal "Accumulo was not installed"

info "Accumulo and ZooKeeper tarballs extracted and symlinked"

# Move example configs into place. (Using the 2GB-standalone configs for this instance)
cp ${ACCUMULO_HOME}/conf/examples/2GB/standalone/* ${ACCUMULO_HOME}/conf

# Overwrite the example accumulo-site.xml with our own settings from CD_ACCUMULO_SITE_CONF...
if [ ! -z "${CD_ACCUMULO_SITE_CONF}" ] ; then
   writeSiteXml "${ACCUMULO_HOME}/conf/accumulo-site.xml" "${CD_ACCUMULO_SITE_CONF}" || fatal "Failed to write accumulo-site.xml"
   info "Accumulo accumulo-site.xml written"
fi

# Write zoo.cfg file using our settings in CD_ZOOKEEPER_CONF
if [ ! -z "${CD_ZOOKEEPER_CONF}" ] ; then 
   echo "${CD_ZOOKEEPER_CONF}" > ${ZOOKEEPER_HOME}/conf/zoo.cfg || fatal "Failed to write zoo.cfg"
fi

if ! hadoopIsRunning ; then 
   info "Starting Hadoop, so that we can initialize Accumulo"
   hadoopStart
fi

if ! zookeeperIsRunning ; then
   info "Starting ZooKeeper, so that we can initialize Accumulo"
   zookeeperStart
fi

# Wait for Hadoop to come out of safemode, if necessary
${HADOOP_HOME}/bin/hdfs dfsadmin -safemode wait

# Initialize Accumulo
${ACCUMULO_HOME}/bin/accumulo init \
 --clear-instance-name \
 --instance-name "${CD_ACCUMULO_INSTANCE_NAME}" \
 --password "${CD_ACCUMULO_PASSWORD}" || fatal "Failed to initialize Accumulo"

echo
echo "Accumulo initialized and ready to start..."
echo
echo "      Start command: accumuloStart"
echo "       Stop command: accumuloStop"
echo "     Status command: accumuloStatus"
echo
echo "See CLOUD_DEVEL_HOME/bin/services/accumulo.sh to view/edit commands as needed"

