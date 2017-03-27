# Resolve env.sh
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SERVICES_DIR="$( dirname "${THIS_DIR}" )"
BIN_DIR="$( dirname "${SERVICES_DIR}" )"
source "${BIN_DIR}/env.sh"
source "${THIS_DIR}/bootstrap.sh"

nifiIsInstalled && info "NiFi is already installed" && exit 1

[ ! -f "${CD_NIFI_SERVICE_DIR}/${CD_NIFI_DIST}" ] && fatal "NiFi tarball not found"

tar xf "${CD_NIFI_SERVICE_DIR}/${CD_NIFI_DIST}" -C "${CD_NIFI_SERVICE_DIR}"
$( cd "${CLOUD_DEVEL_HOME}" && ln -s "bin/services/nifi/${CD_NIFI_BASEDIR}" "${CD_NIFI_SYMLINK}" )

nifiIsInstalled || fatal "NiFi was not installed"

# If needed, embed a distinct Java 8 jre inside $NIFI_HOME to run nifi...
#CD_NIFIJAVA_DIST_URI="file://${INSTALL_DIR}/tarballs/java-1.8.0-openjdk-1.8.0.111.tar.gz"
#CD_NIFIJAVA_DIST="$( downloadTarball "${CD_NIFIJAVA_DIST_URI}" && echo "${tarball}" )"
#CD_NIFIJAVA_BASEDIR="$( getTarballBasedir "${CD_NIFIJAVA_DIST}" && echo "${basedir}" )"
#CD_NIFIJAVA_SYMLINK="nifi-java"
#tar xf "${INSTALL_DIR}/tarballs/${CD_NIFIJAVA_DIST}" -C "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/"
#$( cd "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}" && ln -s "${CD_NIFIJAVA_BASEDIR}" "${CD_NIFIJAVA_SYMLINK}" )
#[ ! -d "${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/${CD_NIFIJAVA_SYMLINK}/jre" ] && fatal "NiFi's embedded Java8 was not installed"
#echo >> ${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin/nifi-env.sh
#echo "JAVA_HOME=\"\${NIFI_HOME}/nifi-java/jre\"" >> ${CLOUD_DEVEL_HOME}/${CD_NIFI_SYMLINK}/bin/nifi-env.sh

info "NiFi installed"

echo
echo "NiFi initialized and ready to start..."
echo
echo "      Start command: nifiStart"
echo "       Stop command: nifiStop"
echo "     Status command: nifiStatus"
echo
echo "See CLOUD_DEVEL_HOME/bin/services/nifi/bootstrap.sh to view/edit commands as needed"
