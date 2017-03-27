# Resolve env.sh
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICES_DIR="$( dirname "${THIS_DIR}" )"
BIN_DIR="$( dirname "${SERVICES_DIR}" )"
source "${BIN_DIR}/env.sh"
source "${THIS_DIR}/bootstrap.sh"
source "${SERVICES_DIR}/hadoop/bootstrap.sh"

if zookeeperIsInstalled ; then
   info "ZooKeeper is already installed"
else
   [ -f "${CD_ACCUMULO_SERVICE_DIR}/${CD_ZOOKEEPER_DIST}" ] || fatal "ZooKeeper tarball not found"
fi

accumuloIsInstalled && info "Accumulo is already installed" && exit 1

[ -f "${CD_ACCUMULO_SERVICE_DIR}/${CD_ACCUMULO_DIST}" ] || fatal "Accumulo tarball not found"

# Extract ZooKeeper, set symlink, and verify...
tar xf "${CD_ACCUMULO_SERVICE_DIR}/${CD_ZOOKEEPER_DIST}" -C "${CD_ACCUMULO_SERVICE_DIR}" || fatal "Failed to extract ZooKeeper tarball"
( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/services/accumulo/${CD_ZOOKEEPER_BASEDIR}" "${CD_ZOOKEEPER_SYMLINK}" ) || fatal "Failed to set ZooKeeper symlink"
zookeeperIsInstalled || fatal "ZooKeeper was not installed"

# Extract Accumulo, set symlink, and verify...
tar xf "${CD_ACCUMULO_SERVICE_DIR}/${CD_ACCUMULO_DIST}" -C "${CD_ACCUMULO_SERVICE_DIR}" || fatal "Failed to extract Accumulo tarball"
( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/services/accumulo/${CD_ACCUMULO_BASEDIR}" "${CD_ACCUMULO_SYMLINK}" ) || fatal "Failed to set Accumulo symlink"
accumuloIsInstalled || fatal "Accumulo was not installed"

info "Accumulo and ZooKeeper tarballs extracted and symlinked"

# Move example configs into place.
cp ${ACCUMULO_HOME}/conf/examples/2GB/standalone/* ${ACCUMULO_HOME}/conf

# Overwrite the example accumulo-site.xml with our own settings from CD_ACCUMULO_SITE_CONF...
if [ ! -z "${CD_ACCUMULO_SITE_CONF}" ] ; then
   writeSiteXml "${ACCUMULO_HOME}/conf/accumulo-site.xml" "${CD_ACCUMULO_SITE_CONF}" || fatal "Failed to write accumulo-site.xml"
   info "Accumulo accumulo-site.xml written"
else
   warn "No accumulo-site.xml content defined! :("
fi

# Write zoo.cfg file using our settings in CD_ZOOKEEPER_CONF
if [ ! -z "${CD_ZOOKEEPER_CONF}" ] ; then 
   echo "${CD_ZOOKEEPER_CONF}" > ${ZOOKEEPER_HOME}/conf/zoo.cfg || fatal "Failed to write zoo.cfg"
else
   warn "No zoo.cfg content defined! :("
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
echo "See CLOUD_DEVEL_HOME/bin/services/accumulo/service.sh to view/edit commands as needed"

