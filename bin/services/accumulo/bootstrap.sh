# Sourced by env.sh

#
# You should consider modifying these OS settings:
#
#   - Set system swappiness to 10 or below. Default is usually 60
#       which Accumulo will definitely complain about.
#
#   - Set max open files ('ulimit -n') to around 34000. Default is 
#       1024 which is too low in most cases
#

CD_ACCUMULO_SERVICE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Zookeeper config
CD_ZOOKEEPER_DIST_URI="http://apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz"
CD_ZOOKEEPER_DIST="$( downloadTarball "${CD_ZOOKEEPER_DIST_URI}" "${CD_ACCUMULO_SERVICE_DIR}" && echo "${tarball}" )"
CD_ZOOKEEPER_BASEDIR="$( getTarballBasedir "${CD_ZOOKEEPER_DIST}" "${CD_ACCUMULO_SERVICE_DIR}" && echo "${basedir}" )"
CD_ZOOKEEPER_SYMLINK="zookeeper"

# zoo.cfg...
CD_ZOOKEEPER_CONF="
tickTime=2000
syncLimit=5
clientPort=2181
dataDir=${CLOUD_DEVEL_DATA}/zookeeper
maxClientCnxns=100"

# Accumulo config
CD_ACCUMULO_DIST_URI="http://apache.cs.utah.edu/accumulo/1.6.6/accumulo-1.6.6-bin.tar.gz"
CD_ACCUMULO_DIST="$( downloadTarball "${CD_ACCUMULO_DIST_URI}" "${CD_ACCUMULO_SERVICE_DIR}" && echo "${tarball}" )"
CD_ACCUMULO_BASEDIR="$( getTarballBasedir "${CD_ACCUMULO_DIST}" "${CD_ACCUMULO_SERVICE_DIR}" && echo "${basedir}" )"
CD_ACCUMULO_SYMLINK="accumulo"
CD_ACCUMULO_INSTANCE_NAME="my-instance-01"
CD_ACCUMULO_PASSWORD="secret"

# accumulo-site.xml (Format: <property-name><space><property-value>{<newline>})
CD_ACCUMULO_SITE_CONF="instance.zookeeper.host localhost:2181
instance.secret ${CD_ACCUMULO_PASSWORD}
tserver.memory.maps.max 385M
tserver.memory.maps.native.enabled false
tserver.cache.data.size 64M
tserver.cache.index.size 64M
trace.token.property.password ${CD_ACCUMULO_PASSWORD}
trace.user root
general.classpaths \$ACCUMULO_HOME/lib/accumulo-server.jar,\n\$ACCUMULO_HOME/lib/accumulo-core.jar,\n\$ACCUMULO_HOME/lib/accumulo-start.jar,\n\$ACCUMULO_HOME/lib/accumulo-fate.jar,\n\$ACCUMULO_HOME/lib/accumulo-proxy.jar,\n\$ACCUMULO_HOME/lib/[^.].*.jar,\n\$ZOOKEEPER_HOME/zookeeper[^.].*.jar,\n\$HADOOP_CONF_DIR,\n\$HADOOP_PREFIX/share/hadoop/common/[^.].*.jar,\n\$HADOOP_PREFIX/share/hadoop/common/lib/(?!slf4j)[^.].*.jar,\n\$HADOOP_PREFIX/share/hadoop/hdfs/[^.].*.jar,\n\$HADOOP_PREFIX/share/hadoop/mapreduce/[^.].*.jar,\n\$HADOOP_PREFIX/share/hadoop/yarn/[^.].*.jar,\n\$HADOOP_PREFIX/share/hadoop/yarn/lib/jersey.*.jar"

export ZOOKEEPER_HOME="${CLOUD_DEVEL_HOME}/${CD_ZOOKEEPER_SYMLINK}"
export ACCUMULO_HOME="${CLOUD_DEVEL_HOME}/${CD_ACCUMULO_SYMLINK}"
export PATH=${ACCUMULO_HOME}/bin:${ZOOKEEPER_HOME}/bin:$PATH

# Service helper variables and functions....

CD_ZOOKEEPER_CMD_START="( cd ${ZOOKEEPER_HOME}/bin && ./zkServer.sh start )"
CD_ZOOKEEPER_CMD_STOP="( cd ${ZOOKEEPER_HOME}/bin && ./zkServer.sh stop )"
CD_ZOOKEEPER_CMD_FIND_ALL_PIDS="pgrep -f 'zookeeper.server.quorum.QuorumPeerMain'"

CD_ACCUMULO_CMD_START="( cd ${ACCUMULO_HOME}/bin && ./start-all.sh )"
CD_ACCUMULO_CMD_STOP="( cd ${ACCUMULO_HOME}/bin && ./stop-all.sh )"
CD_ACCUMULO_CMD_FIND_ALL_PIDS="pgrep -f 'accumulo.start.Main'"

function accumuloIsRunning() {
    ACCUMULO_PID_LIST="$(eval "${CD_ACCUMULO_CMD_FIND_ALL_PIDS} -d ' '")"
    [ -z "${ACCUMULO_PID_LIST}" ] && return 1 || return 0
}

function accumuloStart() {
    accumuloIsRunning && echo "Accumulo is already running" && return 1

    if ! zookeeperIsRunning ; then
       zookeeperStart
       echo
    fi
    if ! hadoopIsRunning ; then
       hadoopStart
       echo
    fi
    eval "${CD_ACCUMULO_CMD_START}"
    echo
    info "For detailed status visit 'http://localhost:50095' in your browser"
}

function accumuloStop() {
    accumuloIsRunning && eval "${CD_ACCUMULO_CMD_STOP}" || echo "Accumulo is already stopped"
    zookeeperStop
}

function accumuloStatus() {
    accumuloIsRunning && echo "Accumulo is running. PIDs: ${ACCUMULO_PID_LIST}" || echo "Accumulo is not running"
    zookeeperStatus
}

function accumuloUninstall() {
    # Remove accumulo
    if accumuloIsInstalled ; then
       ( cd "${CLOUD_DEVEL_HOME}" && unlink "${CD_ACCUMULO_SYMLINK}" ) || error "Failed to remove Accumulo symlink"
       rm -rf "${CD_ACCUMULO_SERVICE_DIR}/${CD_ACCUMULO_BASEDIR}"
       info "Accumulo uninstalled"
    else
      info "Accumulo not installed. Nothing to do"
    fi
    # Remove zookeeper
    if zookeeperIsInstalled ; then
       ( cd "${CLOUD_DEVEL_HOME}" && unlink "${CD_ZOOKEEPER_SYMLINK}" ) || error "Failed to remove ZooKeeper symlink"
       rm -rf "${CD_ACCUMULO_SERVICE_DIR}/${CD_ZOOKEEPER_BASEDIR}"
       info "ZooKeeper uninstalled"
    else
       info "ZooKeeper not installed. Nothing to do"
    fi
}

function accumuloInstall() {
    ${CD_ACCUMULO_SERVICE_DIR}/install.sh
}

function zookeeperIsInstalled() {
    [ ! -d "${CLOUD_DEVEL_HOME}/${CD_ZOOKEEPER_SYMLINK}/bin" ] && return 1
    return 0
}

function accumuloIsInstalled() {
    [ ! -d "${CLOUD_DEVEL_HOME}/${CD_ACCUMULO_SYMLINK}/bin" ] && return 1
    return 0
}

function zookeeperIsRunning() {
    ZOOKEEPER_PID_LIST="$(eval "${CD_ZOOKEEPER_CMD_FIND_ALL_PIDS} -d ' '")"
    [ -z "${ZOOKEEPER_PID_LIST}" ] && return 1 || return 0
}

function zookeeperStart() {
    zookeeperIsRunning && echo "ZooKeeper is already running" || eval "${CD_ZOOKEEPER_CMD_START}"
}

function zookeeperStop() {
    zookeeperIsRunning && eval "${CD_ZOOKEEPER_CMD_STOP}" || echo "ZooKeeper is already stopped"
}

function zookeeperStatus() {
    zookeeperIsRunning && echo "ZooKeeper is running. PIDs: ${ZOOKEEPER_PID_LIST}" || echo "ZooKeeper is not running"
}

function accumuloPrintenv() {
   echo
   echo "Accumulo Environment"
   echo
   ( set -o posix ; set ) | grep -E "ACCUMULO_|ZOOKEEPER_"
   echo
}
