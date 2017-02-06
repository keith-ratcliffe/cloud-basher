# Sourced by env.sh

CD_HADOOP_DIST_URI="http://archive-primary.cloudera.com/cdh5/cdh/5/hadoop-2.6.0-cdh5.9.1.tar.gz" # Download URI
CD_HADOOP_DIST="$( downloadTarball "${CD_HADOOP_DIST_URI}" && echo "${tarball}" )"     # Tarball filename (dynamic)
CD_HADOOP_BASEDIR="$( getTarballBasedir "${CD_HADOOP_DIST}" && echo "${basedir}" )"    # Base directory name (dynamic)
CD_HADOOP_SYMLINK="hadoop-current"                                                     # Name to use for the symlink

# core-site.xml (Format: <property-name><space><property-value>{<newline>})
CD_CORE_SITE_CONF="fs.defaultFS hdfs://localhost:9000
hadoop.tmp.dir file://${CLOUD_DEVEL_DATA}/hadoop/tmp
io.compression.codecs org.apache.hadoop.io.compress.GzipCodec"

# hdfs-site.xml (Format: <property-name><space><property-value>{<newline>})
CD_HDFS_SITE_CONF="dfs.namenode.name.dir file://${CLOUD_DEVEL_DATA}/hadoop/nn
dfs.namenode.checkpoint.dir file://${CLOUD_DEVEL_DATA}/hadoop/nnchk
dfs.datanode.data.dir file://${CLOUD_DEVEL_DATA}/hadoop/dn
dfs.datanode.handler.count 10
dfs.datanode.synconclose true
dfs.replication 1"

# mapred-site.xml (Format: <property-name><space><property-value>{<newline>})
CD_MAPRED_SITE_CONF="mapreduce.jobhistory.address http://localhost:8020
mapreduce.jobhistory.webapp.address http://localhost:8021
mapreduce.jobhistory.intermediate-done-dir ${CLOUD_DEVEL_DATA}/hadoop/jobhist/inter
mapreduce.jobhistory.done-dir ${CLOUD_DEVEL_DATA}/hadoop/jobhist/done
mapreduce.admin.map.child.java.opts -server -XX:NewRatio=8 -Djava.net.preferIPv4Stack=true
mapreduce.map.memory.mb 2048
mapreduce.admin.reduce.child.java.opts -server -XX:NewRatio=8 -Djava.net.preferIPv4Stack=true
mapreduce.framework.name yarn"

# yarn-site.xml (Format: <property-name><space><property-value>{<newline>})
CD_YARN_SITE_CONF="yarn.resourcemanager.scheduler.address localhost:8030
yarn.resourcemanager.scheduler.class org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler
yarn.resourcemanager.resource-tracker.address localhost:8025
yarn.resourcemanager.address localhost:8050
yarn.resourcemanager.admin.address localhost:8033
yarn.resourcemanager.webapp.address localhost:8088
yarn.nodemanager.local-dirs ${CLOUD_DEVEL_DATA}/hadoop/yarn/local
yarn.nodemanager.log-dirs ${CLOUD_DEVEL_DATA}/hadoop/yarn/log
yarn.nodemanager.aux-services mapreduce_shuffle
yarn.nodemanager.pmem-check-enabled false
yarn.nodemanager.vmem-check-enabled false
yarn.log.server.url http://localhost:8070/jobhistory/logs"

# Hadoop standard exports...
export HADOOP_HOME="${CLOUD_DEVEL_HOME}/${CD_HADOOP_SYMLINK}"
export HADOOP_CONF_DIR="${HADOOP_HOME}/etc/hadoop"
export HADOOP_LOG_DIR="${HADOOP_HOME}/logs"
export HADOOP_PREFIX="${HADOOP_HOME}"
export HADOOP_YARN_HOME="${HADOOP_HOME}"
export HADOOP_MAPRED_HOME="${HADOOP_HOME}"
export HADOOP_PID_DIR="${CLOUD_DEVEL_DATA}/hadoop/pids"
export HADOOP_MAPRED_PID_DIR="${HADOOP_PID_DIR}"

export PATH=$HADOOP_HOME/bin:$PATH

# Service helpers...

CD_HADOOP_CMD_START="( cd ${HADOOP_HOME}/sbin && ./start-all.sh && ./mr-jobhistory-daemon.sh start historyserver )"
CD_HADOOP_CMD_STOP="( cd ${HADOOP_HOME}/sbin && ./mr-jobhistory-daemon.sh stop historyserver &&./stop-all.sh )"
CD_HADOOP_CMD_FIND_ALL_PIDS="pgrep -f 'datanode.DataNode|namenode.NameNode|namenode.SecondaryNameNode|nodenamager.NodeManager|resourcemanager.ResourceManager|mapreduce.v2.hs.JobHistoryServer'"

function hadoopIsRunning() {
    HADOOP_PID_LIST="$(eval "${CD_HADOOP_CMD_FIND_ALL_PIDS} -d ' '")"
    [ -z "${HADOOP_PID_LIST}" ] && return 1 || return 0
}

function hadoopStart() {
    hadoopIsRunning && echo "Hadoop is already running" || eval "${CD_HADOOP_CMD_START}"
    echo
    info "For detailed status visit 'http://localhost:50070/dfshealth.html#tab-overview' in your browser"
}

function hadoopStop() {
    hadoopIsRunning && eval "${CD_HADOOP_CMD_STOP}" || echo "Hadoop is already stopped"
}

function hadoopStatus() {
    hadoopIsRunning && echo "Hadoop is running. PIDs: ${HADOOP_PID_LIST}" || echo "Hadoop is not running"
}

function hadoopIsInstalled() {
    [ ! -d "${CLOUD_DEVEL_HOME}/${CD_HADOOP_SYMLINK}/bin" ] && return 1
    return 0
}

function hadoopUninstall() {
   if [ -d "${CLOUD_DEVEL_HOME}/${CD_HADOOP_SYMLINK}/bin" ] ; then
      ( cd "${CLOUD_DEVEL_HOME}" && unlink "${CD_HADOOP_SYMLINK}" ) || error "Failed to remove Hadoop symlink"
      rm -rf "${CLOUD_DEVEL_HOME}/bin/${CD_HADOOP_BASEDIR}"
      info "Hadoop uninstalled"
   else
      info "Hadoop not installed. Nothing to do"
   fi
}

function hadoopInstall() {
   ${CLOUD_DEVEL_HOME}/bin/install/install-hadoop.sh
}

