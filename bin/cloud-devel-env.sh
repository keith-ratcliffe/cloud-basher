#!/bin/bash

# Resolve this script's parent directory ('bin') so that we can
# dynamically assign CLOUD_DEVEL_HOME below...
BIN_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

################################################################################
#
# You should consider modifying these OS settings:
#
#   - Set system swappiness to 10 or below. Default is usually 60
#       which Accumulo will definitely complain about.
#
#   - Set max open files ('ulimit -n') to around 33000. Default is 
#       1024 which is always too low for services like Hadoop, Accumulo, NiFi
#
# The overriding goal here is to make standup, teardown, and modification
# of the environment easy, consistent, repeatable.
#
# Portability of the environment is achieved by making the simple assumption 
# that all installation directories are oriented under CLOUD_DEVEL_HOME, and by
# making the assumption that all services will run as the same user. Obviously, 
# that makes this a real bad choice for anything like production use, but that's
# not the intended purpose. The purpose here is to make your development and 
# prototyping workflow a lot less painful. That is all.
#
# Given that everything is oriented under $CLOUD_DEVEL_HOME, it should be 
# trivial to create multiple distinct environments on a single host, if needed 
# (or to version-control your one working environment with Git for that matter). 
# Switching between environments is a simple matter of changing which 
# cloud-devel-env.sh is being sourced in ~/.bashrc
#
###############################################################################

# Home is the parent directory of this script's dir, ie, 'bin/..'
CLOUD_DEVEL_HOME="$( dirname "${BIN_DIR}" )"

# All data for your services should reside here. Not *required* to be under 
# CLOUD_DEVEL_HOME necessarily, just needs to be a single, common location.
# Services will create their own subdirectories here as needed...
CLOUD_DEVEL_DATA="${CLOUD_DEVEL_HOME}/data"

# Import functions common to all services
source "${BIN_DIR}/common.sh"

# BEGIN SERVICE REGISTRATION  ###########################################################

# Your services are made pluggable by following a few simple naming conventions with your
# scripts and functions. See 'registerService' and other functions in bin/common.sh
# for details.

# You can add/remove lines below to affect which services are available in this 
# environment. To create additional services, use the example scripts noted below
# as a model.

register "hadoop"   # Service implementation: bin/services/hadoop.sh
register "accumulo" # Service implementation: bin/services/accumulo.sh
register "nifi"     # Service implementation: bin/services/nifi.sh 

# END SERVICE REGISTRATION  #############################################################

# Set bootstraps for any shared services & resources below...

# Unlike with Hadoop, Accumulo, and NiFi, there's no simple way to 'wget' a legit JDK/JRE
# tarball directly from the interwebs, but it's easy enough to roll your own after yum/apt-get
# installing one...
CD_JAVA_DIST_URI="file://${BIN_DIR}/install/tarballs/java-1.7.0-openjdk-1.7.0.121.tar.gz"
CD_JAVA_DIST="$( downloadTarball "${CD_JAVA_DIST_URI}" && echo "${tarball}" )"
CD_JAVA_BASEDIR="$( getTarballBasedir "${CD_JAVA_DIST}" && echo "${basedir}" )"
CD_JAVA_SYMLINK="java-current"

export JAVA_HOME="${CLOUD_DEVEL_HOME}/${CD_JAVA_SYMLINK}"

# Each bin/service-*.sh script will build up PATH and *_HOME variables as needed, so
# as long as you've sourced this script in ~/.bashrc, you shouldn't have to set any 
# variables in ~/.bashrc at all for your services.

export PATH=$JAVA_HOME/bin:$PATH

