
# Resolve env.sh
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="$( dirname "${INSTALL_DIR}" )"
source "${BIN_DIR}/env.sh"

# Make sure JDK already installed
if [ ! -f "${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}/bin/java" ] ; then
   ${INSTALL_DIR}/install-java.sh
fi

# Check for existence of tarball, directory, etc...
[ -z "${CD_HADOOP_BASEDIR}" ] && fatal "CD_HADOOP_BASEDIR is not set. Is Hadoop not registered as a service?"
[ -z "${CD_HADOOP_DIST}" ] && fatal "CD_HADOOP_DIST is not set. Is Hadoop not registered as a service?"
[ -z "${CD_HADOOP_SYMLINK}" ] && fatal "CD_HADOOP_SYMLINK is not set. Is Hadoop not registered as a service?"

hadoopIsInstalled && info "Hadoop is already installed" && exit 1

[ -f "${INSTALL_DIR}/tarballs/${CD_HADOOP_DIST}" ] || fatal "Hadoop tarball not found"   

# Ok to extract, set symlink, and verify...
tar xf "${INSTALL_DIR}/tarballs/${CD_HADOOP_DIST}" -C "${BIN_DIR}" || fatal "Failed to extract Hadoop tarball"
( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/${CD_HADOOP_BASEDIR}" "${CD_HADOOP_SYMLINK}" ) || fatal "Failed to set Hadoop symlink"
[ -f "${CLOUD_DEVEL_HOME}/${CD_HADOOP_SYMLINK}/bin/hadoop" ] || fatal "Hadoop was not installed"

info "Hadoop tarball extracted and symlinked"

# Write *-site.xml files...

if [ ! -z "${CD_CORE_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/core-site.xml" "${CD_CORE_SITE_CONF}" || fatal "Failed to write core-site.xml"
   info "Hadoop core-site.xml written"
fi

if [ ! -z "${CD_HDFS_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/hdfs-site.xml" "${CD_HDFS_SITE_CONF}" || fatal "Failed to write hdfs-site.xml"
   info "Hadoop hdfs-site.xml written"
fi

if [ ! -z "${CD_MAPRED_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/mapred-site.xml" "${CD_MAPRED_SITE_CONF}" || fatal "Failed to write mapred-site.xml"
   info "Hadoop mapred-site.xml written"
fi

if [ ! -z "${CD_YARN_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/yarn-site.xml" "${CD_YARN_SITE_CONF}" || fatal "Failed to write yarn-site.xml"
   info "Hadoop yarn-site.xml written"
fi

# Set JAVA_HOME in $HADOOP_CONF_DIR/hadoop-env.sh
sed -i "s~export JAVA_HOME=\${JAVA_HOME}~export JAVA_HOME=\"${JAVA_HOME}\"~g" ${HADOOP_CONF_DIR}/hadoop-env.sh

# Create ssh key for password-less ssh, if necessary
if [ ! -f ~/.ssh/id_rsa ] ; then
   if askYesNo "Hadoop needs password-less ssh, but no ssh key was found. 
Generate the ssh key now?" 
   then
      echo "Hint: Just take defaults (hit <enter>) at all prompts for input" && sleep 3
      ssh-keygen -t rsa
      cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
      chmod 0600 ~/.ssh/authorized_keys
      ssh-agent -s
      echo "Add key to ssh-agent..."
      ssh-add
   fi
fi

# Format namenode
$HADOOP_HOME/bin/hdfs namenode -format || fatal "Failed to initialize Hadoop"

echo
echo "Hadoop initialized and ready to start..."
echo
echo "      Start command: startHadoop"
echo "       Stop command: stopHadoop"
echo "     Status command: statusHadoop"
echo
echo "See CLOUD_DEVEL_HOME/bin/services/hadoop.sh to view/edit commands as needed"

