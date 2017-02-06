
# Resolve cloud-devel-env.sh
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="$( dirname "${INSTALL_DIR}" )"
source "${BIN_DIR}/cloud-devel-env.sh"

if [ -f "${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}/bin/java" ] ; then
   info "Java is already installed"
   exit 0
else
   [ ! -f "${INSTALL_DIR}/tarballs/${CD_JAVA_DIST}" ] && fatal "Java tarball not found"   

   tar xf "${INSTALL_DIR}/tarballs/${CD_JAVA_DIST}" -C "${BIN_DIR}"
   $( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/${CD_JAVA_BASEDIR}" "${CD_JAVA_SYMLINK}" )

   [ ! -f "${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}/bin/java" ] && fatal "Java was not installed"

   info "Java installed"
fi

