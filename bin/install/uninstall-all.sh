
# Resolve cloud-devel-env.sh
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="$( dirname "${INSTALL_DIR}" )"
source "${BIN_DIR}/cloud-devel-env.sh"

servicesAreRunning && \
error "Stop services before uninstalling them" && \
statusAll && \
exit 1

askYesNo "All data and services associated with '${CLOUD_DEVEL_HOME}' will be removed.
      Continue?" || exit 1

if [ -d "${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}/bin" ] ; then
   ( cd "${CLOUD_DEVEL_HOME}" && unlink "${CD_JAVA_SYMLINK}" ) \
       && rm -rf "${BIN_DIR}/${CD_JAVA_BASEDIR}" \
       && info "Java uninstalled" || error "Java uninstall failed"
else
   info "Java not installed. Nothing to do"
fi

services=(${CLOUD_DEVEL_SERVICES})
for servicename in "${services[@]}" ; do
   eval "${servicename}Uninstall"
done

[ -d "${CLOUD_DEVEL_DATA}" ] && rm -rf "${CLOUD_DEVEL_DATA}" && info "Removed all data"

