---
title: "Quickstart Reference"
tags: [getting_started]
summary: This page provides reference material for the DataWave Quickstart
---

## Service Bootstrap Functions

The functions below are implemented in *bin/services/{servicename}/bootstrap.sh*, where *{servicename}* is one of 

**hadoop** \| **accumulo** \| **datawave**  

| Function Name&nbsp;&nbsp;&nbsp; | Description |
|----------------:|:------------- |
| ` {servicename}Start ` | Start the service |
| ` {servicename}Stop ` | Stop the service |
| ` {servicename}Status ` | Display current status of the service, including PIDs if running |
| ` {servicename}Install ` | Install the service |
| ` {servicename}Uninstall ` | Uninstall but leave tarball(s) in place. Optional `--remove-binaries` flag |
| ` {servicename}IsRunning ` | Returns 0 if running, non-zero otherwise. Mostly for internal use |
| ` {servicename}IsInstalled ` | Returns 0 if installed, non-zero otherwise. Mostly for internal use |
| ` {servicename}Printenv ` | Display current state of the service configuration, bash variables, etc |
| ` {servicename}PidList ` | Display all service PIDs on a single line, space-delimited |

These service names are also valid...

- **zookeeper**: managed by the *accumulo* service bootstrap
- **datawaveWeb**: managed by the *datawave* service bootstrap
- **datawaveIngest**: managed by the *datawave* service bootstrap

---

## Global Bootstrap Functions

The functions below are implemented in [bin/common.sh][dw_blob_common_sh]

| Function Name | Description |
|---------------:|:------------- |
| `allStart` | Start all services |
| `allStop` | Stop all services gracefully. Use `--hard` flag to `kill -9` |
| `allStatus` | Display current status of all services, including PIDs if running |
| `allInstall` | Install all services |
| `allUninstall` | Uninstall all services, leaving tarballs in place. Optional `--remove-binaries` flag |
| `allPrintenv` | Display current state of all service configurations |

## Nuclear Options


### Quick Uninstall

To quickly kill any running services and uninstall everything (leaving downloaded *.tar.gz files in place):
```bash
   $ allStop --hard ; allUninstall
```
Same as above, but also remove any downloaded *.tar.gz files:
```bash
  $ allStop --hard ; allUninstall --remove-binaries
```
<div markdown="span" class="alert alert-danger" role="alert"><i class="fa fa-exclamation-circle"></i> <b>Warning:</b> If you intend
to uninstall the quickstart *completely*, don't forget to remove the *env.sh* line from your *~/.bashrc* as the
very last step in the process. Otherwise, you'll bootstrap everything again the next time you start a new
bash session</div>

### Quick Reinstall

Same as above, but re-download and reinstall everything:
```bash
  $ allStop --hard ; allUninstall --remove-binaries && allInstall
```
<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> If you're reinstalling
the quickstart and you've updated or overridden any of the quickstart's environment variables since the previous install, you should
start a new bash session prior to executing the commands above, to ensure that your new settings take effect</div>

---

## DataWave Functions

### Scripts

DataWave's features are exposed primarily through configs and functions defined within the scripts listed below

| Script Name&nbsp;&nbsp;&nbsp; | Description |
|---------------:|:------------- |
| [query.sh][dw_blob_query_sh] | Query-related functions for interacting with DataWave Web's REST API |
| [bootstrap.sh][dw_blob_datawave_bootstrap] | Common functions. Parent wrapper for web &amp; ingest bootstraps |
| [bootstrap-web.sh][dw_blob_datawave_bootstrap_web] | Bootstrap for DataWave Web and associated functions |
| [bootstrap-ingest.sh][dw_blob_datawave_bootstrap_ingest] | Bootstrap for DataWave Ingest and associated functions |
| [bootstrap-user.sh][dw_blob_datawave_bootstrap_user] | Configs for defining DataWave Web test user's identity, roles, auths, etc |

A few noteworthy functions and their descriptions are listed by category below (by no means an exhaustive list). Note that the
[service bootstrap functions](#service-bootstrap-functions) above apply to DataWave Web and DataWave Ingest as well.

### DataWave Web Functions

| `datawaveWebStart [ --debug ]` |
| Start up DataWave's web services in Wildfly. Pass the `--debug` flag to start Wildfly in debug mode |
| Implementation: [bootstrap-web.sh][dw_blob_datawave_bootstrap_web_start] |

| `datawaveQuery --query <query-expression>` |
| Submit queries on demand and inspect results. Use the `--help` flag for information on query options | 
| [Query expression syntax guidance](query-syntax) |
| Implementation: [query.sh][dw_blob_query_sh_query_func] |

| `datawaveWebTest` |
| Wrapper function for [test-web/run.sh][dw_blob_test_web] script. Run a suite of curl-based [tests][dw_web_tests] against DataWave Web |
| Supports several options. Use the `--help` flag for more information |
| Implementation: [bootstrap-web.sh][dw_blob_datawave_bootstrap_web_test] |

### DataWave Ingest Functions
    
| `datawaveIngestJson /path/to/some/tvmaze.json` |
| Kick off M/R job to ingest raw JSON file containing TV show data from <http://tvmaze.com/api> |
| Ingest config file: [myjson-ingest-config.xml][dw_blob_myjson_config] |
| File ingested automatically by the DataWave Ingest installer (install-ingest.sh): [tvmaze-api.json][dw_blob_tvmaze_raw_json] |
| Use the [ingest-tv-shows.sh][dw_blob_ingest_tvshows] script to download &amp; ingest more of your favorite shows |
| Implementation: [bootstrap-ingest.sh][dw_blob_datawave_bootstrap_ingest_json] |

| `datawaveIngestWikipedia /path/to/some/enwiki.xml` |
| Kick off M/R job to ingest a raw Wikipedia XML file. Any standard *enwiki*-flavored file should suffice |
| Ingest config file: [wikipedia-ingest-config.xml][dw_blob_mywikipedia_config] |
| File ingested automatically by the DataWave Ingest installer (install-ingest.sh): [enwiki-20130305*.xml][dw_blob_enwiki_raw_xml] |
| Implementation: [bootstrap-ingest.sh][dw_blob_datawave_bootstrap_ingest_wiki] |
    
| `datawaveIngestCsv /path/to/some/file.csv` |
| Kick off M/R job to ingest a raw CSV file similar to [my.csv][dw_blob_my_raw_csv] |
| Ingest config file: [mycsv-ingest-config.xml][dw_blob_mycsv_config] |
| File ingested automatically by the DataWave Ingest installer (install-ingest.sh): [my.csv][dw_blob_my_raw_csv] |
| Implementation: [bootstrap-ingest.sh][dw_blob_datawave_bootstrap_ingest_csv] |

### Build/Deploy Functions

| `datawaveBuild` |
| Rebuild DataWave as needed (i.e., after the initial install/deploy) |
| Implementation: [bootstrap.sh][dw_blob_datawave_bootstrap_build] |

| `datawaveBuildDeploy` |
| Redeploy DataWave as needed (i.e., after the initial install/deploy) |
| Implementation: [bootstrap.sh][dw_blob_datawave_bootstrap_build_deploy] |

---

## PKI Notes
    
In the quickstart environment, DataWave Web is PKI enabled and uses two-way authentication by default. Moreover, the following
self-signed materials are used...

| File Name | Type | Description |
|----------:|------|------------ |
| [ca.jks][dw_blob_ca_jks] | JKS | Truststore for the Wildfly JEE Application Server |
| [testServer.p12][dw_blob_server_p12] | PKCS12 | Server Keystore for the Wildfly JEE Application Server |
| [testUser.p12][dw_blob_user_p12] | PKCS12 | Test user client cert |
        
* Passwords for all of the above: *`secret`*

* To access DataWave Web endpoints in a browser, you'll need to import the client cert into the browser's certificate store

* The goal of the quickstart's PKI setup is to demonstrate DataWave's ability to be integrated easily into an organization's existing
  private key infrastructure and user auth services. See [datawave/bootstrap-user.sh][dw_blob_datawave_bootstrap_user]
  for more information on configuring the test user's roles and associated Accumulo authorizations

* To test with your own certificate materials, override the keystore &amp; truststore variables from [datawave/bootstrap.sh][dw_blob_datawave_bootstrap_pki]
  within your *~/.bashrc* prior to [installing the quickstart](quickstart-install)

[dw_blob_env_sh]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/env.sh
[dw_blob_common_sh]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/common.sh
[dw_blob_query_sh]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/query.sh
[dw_blob_query_sh_query_func]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/query.sh#L16
[dw_blob_datawave_bootstrap_pki]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh#L50
[dw_blob_datawave_bootstrap]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh
[dw_blob_datawave_bootstrap_web]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-web.sh
[dw_blob_datawave_bootstrap_web_start]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-web.sh#L107
[dw_blob_datawave_bootstrap_web_test]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-web.sh#L59
[dw_blob_datawave_bootstrap_ingest]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-ingest.sh
[dw_blob_datawave_bootstrap_ingest_json]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-ingest.sh#L201
[dw_blob_datawave_bootstrap_ingest_wiki]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-ingest.sh#L138
[dw_blob_datawave_bootstrap_ingest_csv]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-ingest.sh#L176
[dw_blob_datawave_bootstrap_user]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap-user.sh
[dw_web_tests]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/bin/services/datawave/test-web/tests
[dw_datawave_home]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/bin/services/datawave
[dw_blob_ca_jks]: https://github.com/NationalSecurityAgency/datawave/blob/master/web-services/deploy/application/src/main/wildfly/overlay/standalone/configuration/certificates/ca.jks
[dw_blob_server_p12]: https://github.com/NationalSecurityAgency/datawave/blob/master/web-services/deploy/application/src/main/wildfly/overlay/standalone/configuration/certificates/testServer.p12
[dw_blob_user_p12]: https://github.com/NationalSecurityAgency/datawave/blob/master/web-services/deploy/application/src/main/wildfly/overlay/standalone/configuration/certificates/testUser.p12
[dw_blob_test_web]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/bin/services/datawave/test-web
[dw_blob_myjson_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/myjson-ingest-config.xml
[dw_blob_tvmaze_raw_json]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-json/src/test/resources/input/tvmaze-api.json
[dw_blob_ingest_tvshows]: https://github.com/NationalSecurityAgency/datawave/tree/master/contrib/datawave-quickstart/bin/services/datawave/ingest-examples
[dw_blob_mywikipedia_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/wikipedia-ingest-config.xml
[dw_blob_mycsv_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/mycsv-ingest-config.xml
[dw_blob_enwiki_raw_xml]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-wikipedia/src/test/resources/input/enwiki-20130305-pages-articles-brief.xml
[dw_blob_my_raw_csv]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-csv/src/test/resources/input/my.csv
[dw_blob_datawave_bootstrap_build]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh#L382
[dw_blob_datawave_bootstrap_build_deploy]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh#L372