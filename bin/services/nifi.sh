# Sourced by env.sh

CD_NIFI_DIST_URI="http://apache.claz.org/nifi/1.1.1/nifi-1.1.1-bin.tar.gz"      # Download URI
CD_NIFI_DIST="$( downloadTarball "${CD_NIFI_DIST_URI}" && echo "${tarball}" )"  # Tarball filename (dynamic)
CD_NIFI_BASEDIR="$( getTarballBasedir "${CD_NIFI_DIST}" && echo "${basedir}" )" # Base directory name (dynamic)
CD_NIFI_SYMLINK="nifi-current"                                                  # Name to use for the symlink

# Standard exports...
export NIFI_HOME="${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}"

export PATH=$NIFI_HOME/bin:$PATH

# Service helpers...

CD_NIFI_CMD_START="( cd ${NIFI_HOME}/bin && ./nifi.sh start )"
CD_NIFI_CMD_STOP="( cd ${NIFI_HOME}/bin && ./nifi.sh stop )"
CD_NIFI_CMD_FIND_ALL_PIDS="pgrep -f 'org.apache.nifi'"

function nifiIsRunning() {
    NIFI_PID_LIST="$(eval "${CD_NIFI_CMD_FIND_ALL_PIDS} -d ' '")"
    [ -z "${NIFI_PID_LIST}" ] && return 1 || return 0
}

function nifiStart() {
    nifiIsRunning && echo "NiFi is already running" || eval "${CD_NIFI_CMD_START}"
    info "To get to the UI, visit 'http://localhost:8080/nifi/' in your browser"
    info "Be patient, it may take a while for the NiFi web service to start"
}

function nifiStop() {
    nifiIsRunning && eval "${CD_NIFI_CMD_STOP}" || echo "NiFi is already stopped"
}

function nifiStatus() {
    nifiIsRunning && echo "NiFi is running. PIDs: ${NIFI_PID_LIST}" || echo "NiFi is not running"
}

function nifiIsInstalled() {
    [ -d "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin" ] && return 0 || return 1
}

function nifiUninstall() {
   if [ -d "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin" ] ; then
      ( cd "${CLOUD_DEVEL_HOME}" && unlink "${CD_NIFI_SYMLINK}" ) || error "Failed to remove NiFi symlink"
      rm -rf "${CLOUD_DEVEL_HOME}/bin/${CD_NIFI_BASEDIR}"
      info "NiFi uninstalled"
   else
      info "NiFi not installed. Nothing to do"
   fi
}

function nifiInstall() {
   ${CLOUD_DEVEL_HOME}/bin/install/install-nifi.sh
}
