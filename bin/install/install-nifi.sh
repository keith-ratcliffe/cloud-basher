
# Resolve cloud-devel-env.sh
INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BIN_DIR="$( dirname "${INSTALL_DIR}" )"
source "${BIN_DIR}/cloud-devel-env.sh"

[ -z "${CD_NIFI_BASEDIR}" ] && fatal "CD_NIFI_BASEDIR is not set. Is NiFi not registered as a service?"
[ -z "${CD_NIFI_DIST}" ] && fatal "CD_NIFI_DIST is not set. Is NiFi not registered as a service?"
[ -z "${CD_NIFI_SYMLINK}" ] && fatal "CD_NIFI_SYMLINK is not set. Is NiFi not registered as a service?"

if [ -d "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin" ] ; then
   info "NiFi is already installed"
   exit 0
fi

[ ! -f "${INSTALL_DIR}/tarballs/${CD_NIFI_DIST}" ] && fatal "NiFi tarball not found"   

tar xf "${INSTALL_DIR}/tarballs/${CD_NIFI_DIST}" -C "${BIN_DIR}"
$( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/${CD_NIFI_BASEDIR}" "${CD_NIFI_SYMLINK}" )

[ ! -d "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin" ] && fatal "NiFi was not installed"

# Embedding a Java 8 jre inside $NIFI_HOME for nifi to use, since we need
# Java 7 for Accumulo, Hadoop, etc
CD_NIFIJAVA_DIST_URI="file://${INSTALL_DIR}/tarballs/java-1.8.0-openjdk-1.8.0.111.tar.gz"
CD_NIFIJAVA_DIST="$( downloadTarball "${CD_NIFIJAVA_DIST_URI}" && echo "${tarball}" )"
CD_NIFIJAVA_BASEDIR="$( getTarballBasedir "${CD_NIFIJAVA_DIST}" && echo "${basedir}" )"
CD_NIFIJAVA_SYMLINK="nifi-java"
tar xf "${INSTALL_DIR}/tarballs/${CD_NIFIJAVA_DIST}" -C "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/"
$( cd "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}" && ln -s "${CD_NIFIJAVA_BASEDIR}" "${CD_NIFIJAVA_SYMLINK}" )
[ ! -d "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/${CD_NIFIJAVA_SYMLINK}/jre" ] && fatal "NiFi's embedded Java8 was not installed"
echo >> ${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin/nifi-env.sh
echo "JAVA_HOME=\"\${NIFI_HOME}/nifi-java/jre\"" >> ${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin/nifi-env.sh

info "NiFi installed"

echo
echo "NiFi initialized and ready to start..."
echo
echo "      Start command: nifiStart"
echo "       Stop command: nifiStop"
echo "     Status command: nifiStatus"
echo
echo "See CLOUD_DEVEL_HOME/bin/services/nifi.sh to view/edit commands as needed"
