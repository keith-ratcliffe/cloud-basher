# Resolve env.sh
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICES_DIR="$( dirname "${THIS_DIR}" )"
BIN_DIR="$( dirname "${SERVICES_DIR}" )"
source "${BIN_DIR}/env.sh"
source "${THIS_DIR}/bootstrap.sh"

hadoopIsInstalled && info "Hadoop is already installed" && exit 1

[ -f "${CD_HADOOP_SERVICE_DIR}/${CD_HADOOP_DIST}" ] || fatal "Hadoop tarball not found"

# Extract, set symlink, and verify...
tar xf "${CD_HADOOP_SERVICE_DIR}/${CD_HADOOP_DIST}" -C "${CD_HADOOP_SERVICE_DIR}" || fatal "Failed to extract Hadoop tarball"
( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/services/hadoop/${CD_HADOOP_BASEDIR}" "${CD_HADOOP_SYMLINK}" ) || fatal "Failed to set Hadoop symlink"
! hadoopIsInstalled && fatal "Hadoop was not installed"

info "Hadoop tarball extracted and symlinked"

# Write *-site.xml files...

if [ ! -z "${CD_HADOOP_CORE_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/core-site.xml" "${CD_HADOOP_CORE_SITE_CONF}" || fatal "Failed to write core-site.xml"
   info "Hadoop core-site.xml written"
else
   warn "No core-site.xml content defined! :("
fi

if [ ! -z "${CD_HADOOP_HDFS_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/hdfs-site.xml" "${CD_HADOOP_HDFS_SITE_CONF}" || fatal "Failed to write hdfs-site.xml"
   info "Hadoop hdfs-site.xml written"
else
   warn "No hdfs-site.xml content defined! :("
fi

if [ ! -z "${CD_HADOOP_MAPRED_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/mapred-site.xml" "${CD_HADOOP_MAPRED_SITE_CONF}" || fatal "Failed to write mapred-site.xml"
   info "Hadoop mapred-site.xml written"
else
   warn "No mapred-site.xml content defined! :("
fi

if [ ! -z "${CD_HADOOP_YARN_SITE_CONF}" ] ; then
   writeSiteXml "${HADOOP_CONF_DIR}/yarn-site.xml" "${CD_HADOOP_YARN_SITE_CONF}" || fatal "Failed to write yarn-site.xml"
   info "Hadoop yarn-site.xml written"
else
   warn "No yarn-site.xml content defined! :("
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
elif [ ! -f ~/.ssh/authorized_keys ] ; then
   cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
   chmod 0600 ~/.ssh/authorized_keys
fi

# Format namenode
$HADOOP_HOME/bin/hdfs namenode -format || fatal "Failed to initialize Hadoop"

echo
echo "Hadoop initialized and ready to start..."
echo
echo "      Start command: hadoopStart"
echo "       Stop command: hadoopStop"
echo "     Status command: hadoopStatus"
echo
echo "See CLOUD_DEVEL_HOME/bin/services/hadoop/bootstrap.sh to view/edit commands as needed"
