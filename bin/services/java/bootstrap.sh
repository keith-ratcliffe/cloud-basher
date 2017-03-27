# Sourced by env.sh

CD_JAVA_SERVICE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

CD_JAVA_DIST_URI="file://${CD_JAVA_SERVICE_DIR}/java-1.8.0-openjdk-1.8.0.121.tar.gz"
CD_JAVA_DIST="$( downloadTarball "${CD_JAVA_DIST_URI}" "${CD_JAVA_SERVICE_DIR}" && echo "${tarball}" )"
CD_JAVA_BASEDIR="$( getTarballBasedir "${CD_JAVA_DIST}" "${CD_JAVA_SERVICE_DIR}" && echo "${basedir}" )"
CD_JAVA_SYMLINK="java"

export JAVA_HOME="${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}"
export PATH=${JAVA_HOME}/bin:$PATH

function javaIsInstalled() {
    [ ! -f "${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}/bin/java" ] && return 1
    return 0
}

function javaInstall() {
    javaIsInstalled && info "Java is already installed" && exit 1
    [ ! -f "${CD_JAVA_SERVICE_DIR}/${CD_JAVA_DIST}" ] && fatal "Java tarball not found"
    tar xf "${CD_JAVA_SERVICE_DIR}/${CD_JAVA_DIST}" -C "${CD_JAVA_SERVICE_DIR}"
    $( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/services/java/${CD_JAVA_BASEDIR}" "${CD_JAVA_SYMLINK}" )
    ! javaIsInstalled && fatal "Java was not installed"
    info "Java installed"
}

function javaUninstall() {
    if javaIsInstalled ; then
        ( cd "${CLOUD_DEVEL_HOME}" && unlink "${CD_JAVA_SYMLINK}" ) \
            && rm -rf "${CD_JAVA_SERVICE_DIR}/${CD_JAVA_BASEDIR}" \
            && info "Java uninstalled" || error "Java uninstall failed"
    else
        info "Java not installed. Nothing to do"
    fi
}

function javaIsRunning() {
    return 1 # No op
}

function javaStart() {
    return 0 # No op
}

function javaStop() {
    return 0 # No op
}

function javaStatus() {
    return 0 # No op
}

function javaPrintenv() {
   echo
   echo "Java Environment"
   echo
   ( set -o posix ; set ) | grep "JAVA_"
   echo
}
