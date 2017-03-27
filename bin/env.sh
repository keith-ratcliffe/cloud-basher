
################################################################################
#
# All you should need to do is source this script within ~/.bashrc and then
# fire up a new bash terminal.
#
# The overriding goal here is to make standup, teardown, and modification
# of the environment easy/consistent/repeatable, in order to speed up your
# development and prototyping workflow.
#
# Portability is achieved by making the simple assumption that all installation 
# directories are oriented under CLOUD_DEVEL_HOME. And for simplicity, it is
# assumed that all services will run as the same user.
#
# Obviously, this a bad choice for anything like production use, but as already
# stated, that's not the intended purpose.
#
# Given that everything is oriented under $CLOUD_DEVEL_HOME, it should be 
# trivial to create multiple distinct environments on a single host, if desired
# (or to version-control your working environment with Git for that matter).
# Switching between environments is a simple matter of changing which 
# env.sh is being sourced within ~/.bashrc
#
###############################################################################

# Resolve parent dir, ie 'bin'
CLOUD_DEVEL_BIN="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Home is the parent of bin
CLOUD_DEVEL_HOME="$( dirname "${CLOUD_DEVEL_BIN}" )"

# Parent dir for any service-related data, to simplify teardown automation. 
# Services can override data directories if desired, but in that case cleanup
# on teardown will be the responsibility of the service plugin
CLOUD_DEVEL_DATA="${CLOUD_DEVEL_HOME}/data"

# Import functions common to all services
source "${CLOUD_DEVEL_BIN}/common.sh"

# Parent dir for services
CLOUD_DEVEL_PLUGINS="${CLOUD_DEVEL_BIN}/services"

# Begin service registration ##########################################################

# Services are made pluggable by following a few simple naming conventions for
# scripts & functions. See the 'register' function in bin/common.sh for details.

# You can add/remove lines below to affect which services are available in the
# environment. To integrate additional services, use any of the examples below as
# a template.

# Order of registration reflects install and startup order in functions such as
# 'installAll', 'startAll', etc. Likewise, functions such as 'stopAll' and
# 'uninstallAll' will perform actions in reverse order of registration

register "java"     # See CLOUD_DEVEL_PLUGINS/java/bootstrap.sh
register "hadoop"   # See CLOUD_DEVEL_PLUGINS/hadoop/bootstrap.sh
register "accumulo" # See CLOUD_DEVEL_PLUGINS/accumulo/bootstrap.sh
register "nifi"     # See CLOUD_DEVEL_PLUGINS/nifi/bootstrap.sh

# End service registration #############################################################

