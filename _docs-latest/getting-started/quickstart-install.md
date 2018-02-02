---
title: "Quickstart Install"
tags: [getting_started, ingest, query]
summary: Follow the instructions below to quickly setup a standalone DataWave instance, which you may use to follow along with the <a href="../tour/getting-started">Guided Tour</a> doc, or use as needed for your own experimentation and development
---

## Introduction

The DataWave Quickstart automates the steps that you'd otherwise need to perform manually to configure, build, deploy,
and test a standalone DataWave environment.

It includes setup and tear-down automation for DataWave, Hadoop, Accumulo, ZooKeeper, and Wildfly, and it provides many
utility functions for testing DataWave's ingest and query components.

Depending on your needs, the quickstart environment may be suitable for use as both a learning tool and, if you're a
code contributor, a general purpose tool for speeding up your dev workflow.

## Before You Start

### Prerequisites

* Linux, Bash, and an Internet connection to `wget` tarballs

### System Recommendations

* OS: To date, this quickstart has been tested on CentOS 6x, 7x and Ubuntu 16x
* 8GB RAM + single quad-core processor (minimum)
* Storage: To install everything, you'll need at least a few GB free
* ulimit -u (max user processes): 32768
* ulimit -n (open files): 32768
* vm.swappiness: 0

### Get the Source Code

<a class="btn btn-success" style="width: 220px;" href="https://github.com/{{ site.repository }}/archive/{{ site.default_branch }}.zip" role="button"><i class="fa fa-download fa-lg"></i> Download Archive</a>
or <a class="btn btn-success" style="width: 220px;" href="https://github.com/{{ site.repository }}/" role="button" target="_blank"><i class="fa fa-github fa-lg"></i> Clone the Repo</a>

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> The local path that
you select for DataWave's source code will be referenced as **DW_HOME** from this point forward. Wherever it appears in a bash
command below, be sure to substitute it with the full path to the actual directory</div>

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Docker Alternative:</b> If
you would prefer to run the DataWave Quickstart environment as a Docker container, skip the 4 steps described below.
Go **[here][dw_docker_alternative]** instead and view the **README**
<br/><br/>Note that the **[Overriding Default Binaries](#overriding-default-binaries)** section below is relevant to the Docker image build as well 
</div>

---

## Setup and Installation

```bash
  $ echo "source DW_HOME/contrib/datawave-quickstart/bin/env.sh" >> ~/.bashrc  # Step 1
  $ source ~/.bashrc                                                           # Step 2
  $ allInstall                                                                 # Step 3
  $ datawaveWebStart && datawaveWebTest                                        # Step 4
  # Setup is now complete
```
<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> The
four bash commands shown above will complete the entire quickstart installation. However, it's a good idea
to at least skim over the respective sections below to get an idea of how the setup works and how to customize it
for your own preferences</div>

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> Once you've
executed the command in **Step 2**, you can easily start over via the uininstall / reinstall options described in the
**[Quickstart Reference](quickstart-reference#nuclear-options)**
</div>

### STEP 1

#### Update .bashrc
```bash
  $ echo "source DW_HOME/contrib/datawave-quickstart/bin/env.sh" >> ~/.bashrc  # Step 1
```

The **[env.sh][dw_blob_env_sh]** script is a wrapper that bootstraps each individual service in turn by sourcing its
respective **{servicename}/boostrap.sh** script. These bootstrap scripts are central to the quickstart's design,
as they define supporting bash variables and bash functions, encapsulating both the configuration and functionality of
each service in a consistent manner.

Thus, adding the line above to your **~/.bashrc** ensures that your DataWave environment and all its services will remain
configured correctly across bash sessions.

To keep things as simple as possible, **DataWave**, **Hadoop**, **Accumulo**, **ZooKeeper**, and **Wildfly** will be installed under your
**DW_HOME/contrib/datawave-quickstart** directory, and all will be owned by / executed as the current user.

<br/>
<div markdown="span" class="alert alert-danger" role="alert"><i class="fa fa-exclamation-circle"></i> <b>Caution</b><br/>
If you currently have any of the above installed locally under *any* user account, you should verify that those
services are stopped before proceeding. Moreover, the command in **Step 1** aims to avoid conflicts with existing services
by making this the *last* line in your **~/.bashrc** file, to ensure that variables already defined there will be properly
overridden (e.g., variables such as *HADOOP_HOME*, *ACCUMULO_HOME*, *WILDFLY_HOME*, etc).
<br/><br/>
Typically, these precautions will suffice to avoid conflicts with existing services. However, if conflicts should arise
due to any external settings that override your **~/.bashrc**, beware that the quickstart installation could fail and
possibly even harm your existing installs
</div>

#### Overriding Default Binaries

If needed, you may override the version of the binary that gets downloaded and installed for a particular service. For example,
you may want to use your own locally-built binaries for Hadoop, Accumulo, etc. Or you may simply want to test with the latest
version of a given service. Before proceeding with the installation, simply override the desired `DW_*_DIST_URI` value (defined
in the service's **bootstrap.sh**), following the example below...
```bash
  $ vi ~/.bashrc
     ...
  
     export DW_ACCUMULO_DIST_URI=http://my.favorite.apache.mirror/accumulo/1.8.X/accumulo-1.8.X-bin.tar.gz
     export DW_JAVA_DIST_URI=file:///my/local/binaries/jdk-8-linux-x64.tar.gz
     export DW_MAVEN_DIST_URI=file:///my/local/binaries/apache-maven-3.X.tar.gz
     export DW_HADOOP_DIST_URI=file:///my/local/binaries/hadoop-2.6.0-cdh5.9.1.tar.gz
     export DW_ZOOKEEPER_DIST_URI=file:///my/local/binaries/zookeeper-3.4.5-cdh5.9.1.tar.gz
     export DW_WILDFLY_DIST_URI=file:///my/local/binaries/wildfly-10.X.tar.gz

     source DW_HOME/contrib/datawave-quickstart/bin/env.sh     # Added by Step 1

     # If building the quickstart docker image, you only need the exports...no need to source env.sh
     
```

---

### STEP 2

#### Bootstrap the Environment
```bash
  $ source ~/.bashrc                                                           # Step 2
```
As soon as **~/.bashrc** is sourced as shown above, tarballs for registered services will be automatically retrieved from
their `DW_*_DIST_URI` locations and copied into place. A DataWave build will also be kicked off automatically in turn, and
DataWave's ingest and web services binaries will be copied into place upon conclusion of the build.

Step 2 may also be performed by simply opening a new terminal window, which starts a new bash session and accomplishes the same thing
 
<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> This step can take several 
minutes to complete, so it's a good time step away for a break</div>

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> The **DW_DATAWAVE_BUILD_COMMAND**
variable in [datawave/bootstrap.sh][dw_blob_datawave_bootstrap_mvn_cmd] defines the Maven command used for the build. It may be overridden
in **~/.bashrc** or from the command line as needed</div>

---

### STEP 3

#### Install All Services
```bash
    $ allInstall                                                                 # Step 3
```
The `allInstall` bash function will initialize and configure all services in the correct sequence. Alternatively,
individual services may be installed one at a time, if desired, using their respective `{servicename}Install` bash functions.

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> All binaries are
extracted/installed inside their respective service directories, i.e., under **datawave-quickstart/bin/services/{servicename}/**</div>

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> As part of the
installation of DataWave Ingest, example datasets will be ingested automatically via MapReduce for demonstration purposes.
This includes datasets encoded in a variety of formats, such as JSON, CSV, and XML</div>

---

### STEP 4

#### Start Wildfly and Test Web Services
```bash
    $ datawaveWebStart && datawaveWebTest                                        # Step 4
```

Lastly, `datawaveWebStart && datawaveWebTest` will start up DataWave Web and run [preconfigured tests][dw_web_tests] against
DataWave's REST API. Note any test failures, if present, and check logs for error messages.

## What's Next?

* If all web service tests passed in **Step 4**, then you're ready for the **[guided tour](../tour/getting-started)**.
* If you encountered any issues along the way, please read through the **[troubleshooting](quickstart-trouble)** guide.
* To learn more about the quickstart environment and its available features, check out the **[quickstart reference](quickstart-reference)**.


[dw_blob_env_sh]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/env.sh
[dw_blob_common_sh]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/common.sh
[dw_blob_query_sh]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/query.sh
[dw_blob_datawave_bootstrap_mvn_cmd]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh#L34
[dw_blob_datawave_bootstrap]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh
[dw_blob_datawave_bootstrap_web]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-web.sh
[dw_blob_datawave_bootstrap_ingest]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-ingest.sh
[dw_blob_datawave_bootstrap_user]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-user.sh
[dw_web_tests]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/bin/services/datawave/test-web/tests
[dw_datawave_home]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/bin/services/datawave
[dw_docker_alternative]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/docker
