
# Logging functions...

function info() {
   echo "INFO - $1"
}

function warn() {
   echo "WARN - $1"
}

function error() {
   echo "ERROR - $1"
}

function fatal() {
   echo "FATAL - $1"
   echo "Aborting $( basename "$0" )" && exit 1
}

function register() {
   servicename="$1"
   servicescript="${CLOUD_DEVEL_HOME}/bin/services/${servicename}.sh"
   #
   # Here we create & maintain a simple registry of service names, so that services 
   # are easily pluggable, and so that the services can be manipulated programatically 
   # without having to hardcode their actual names in scripts
   #
   # The service contract requires the following:
   #
   #   A "bin/services/servicename.sh" script must exist containing any required 
   #   environment variables needed for bootstrapping, and that script must provide
   #   implementations of the following functions:
   # 
   #       "servicenameStart"       - Starts the service
   #       "servicenameStop",       - Stops the service
   #       "servicenameStatus"      - Current status of the service. PIDs if running
   #       "servicenameInstall"     - Installs the service
   #       "servicenameUninstall"   - Uninstalls the service
   #       "servicenameIsRunning"   - Returns 0 if running, non-zero otherwise
   #       "servicenameIsInstalled" - Returns 0 if installed, non-zero otherwise
   #
   if [ -z "${servicename}" ] ; then
      error "Registration failed: service name was null"
      return 1
   fi

   if [ ! -f "${servicescript}" ] ; then
      error "Registration failed: ${servicescript} doesn't exist"
      return 1
   fi

   if [ ! -z "$( echo "${CLOUD_DEVEL_SERVICES}" | grep "${servicename}" )" ] ; then
      return 1 # servicename is already registered
   fi

   # Source the service script
   source "${servicescript}"

   # Finally, add service name to our list
   CLOUD_DEVEL_SERVICES="${CLOUD_DEVEL_SERVICES} ${servicename}"
}

askYesNo() {
   # Get the user's 'yes|y' / 'no|n' reply to the given question
   # (Keeps asking until a valid response is given)
   echo
   YN_MSG="$1"
   while true; do
      read -r -p "$YN_MSG [y/n]: " USER_REPLY
      case "$( echo "$USER_REPLY" | tr '[:upper:]' '[:lower:]' )" in
         y|yes) echo && return 0 ;;
         n|no) echo && return 1 ;;
      esac
      echo " - Invalid response"
   done
}

function getTarballBasedir() {
   # Gets the directory name that will be produced by extracting the tarball
   tarball="$1"
   basedir="$( tar tf "${CLOUD_DEVEL_HOME}/bin/install/tarballs/${tarball}" | head -n 1 | cut -d '/' -f 1 )"
}

function downloadTarball() {
   # Downloads the specified tarball, if it doesn't already exist
   uri="$1"
   tarball="$( basename ${uri} )"
   if [ ! -f "${CLOUD_DEVEL_HOME}/bin/install/tarballs/${tarball}" ] ; then
      $( cd "${CLOUD_DEVEL_HOME}/bin/install/tarballs" && wget "${uri}" ) || error "Failed to wget '${uri}'"
   fi
}

function writeSiteXml() {
   # Writes *-site.xml files, such as hdfs-site.xml, accumulo-site.xml, etc...

   sitefile="$1" # The file name to write
   siteconf="$2" # The property name/value pairs to write

   # read the "name value" siteconf properties, one line at a time
   printf '%s\n' "$siteconf" | ( while IFS= read -r nameval ; do
       # parse the name and value from the line
       name="$( echo $nameval | cut -d ' ' -f1 )"
       value="$( echo $nameval | cut -d ' ' --complement -s -f1 )"
       # concatenate the xml into a big blob
       xml="${xml}$(printf "\n   <property>\n      <name>$name</name>\n      <value>$value</value>\n   </property>\n")"
   done
   # write the blob to file...
   printf "<configuration>${xml}\n</configuration>" > ${sitefile} )
}

function servicesAreRunning() {
   # Returns 0, if any registered services are running.
   # Returns non-zero, if no registered services are running
   services=(${CLOUD_DEVEL_SERVICES})
   for servicename in "${services[@]}" ; do
      eval "${servicename}IsRunning" && return 0
   done
   return 1 # Nothing running
}

function statusAll() {
   # Gets the status of all registered services
   services=(${CLOUD_DEVEL_SERVICES})
   for servicename in "${services[@]}" ; do
      eval "${servicename}Status"
   done
}

function startAll() {
   # Starts all registered services
   services=(${CLOUD_DEVEL_SERVICES})
   for servicename in "${services[@]}" ; do
      if ${servicename}IsInstalled ; then
         eval "${servicename}IsRunning" || eval "${servicename}Start"
      else
         info "${servicename} service is not installed"
      fi
   done
}

function stopAll() {
   # Stops all registered services
   if ! servicesAreRunning ; then
      echo "No services are currently running"
      return 1
   fi
   services=(${CLOUD_DEVEL_SERVICES})
   # Loop in reverse order for stopping services
   # In other words, order of registration matters.
   # e.g., we don't want to stop Hadoop *before* Accumulo.
   for (( idx=${#services[@]}-1 ; idx>=0 ; idx-- )) ; do
      eval "${services[idx]}Stop"
   done
}

function installAll() {
   # Installs all registered services
   if servicesAreRunning ; then
      echo "Services are currently running"
      statusAll
      return 1
   fi
   services=(${CLOUD_DEVEL_SERVICES})
   for servicename in "${services[@]}" ; do
      eval "${servicename}Install"
   done
}

function uninstallAll() {
   # Uninstalls all registered services. 
   if servicesAreRunning ; then
      echo "Stop running services before uninstalling!"
      statusAll
      return 1
   fi
   ${CLOUD_DEVEL_HOME}/bin/install/uninstall-all.sh
}

