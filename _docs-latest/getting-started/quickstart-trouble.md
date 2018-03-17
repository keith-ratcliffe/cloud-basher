---
title: "Troubleshooting"
tags: [getting_started]
summary: This page provides troubleshooting help for the DataWave Quickstart
---

## Troubleshoot DataWave Issues

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> The path to
your local *DW_HOME/contrib/datawave-quickstart* directory will be referenced below as *QUICKSTART_HOME* from this
point forward.
</div>

### Check Query/Web Logs for Errors

*QUICKSTART_HOME/wildfly/standalone/log/*

### Check Ingest Job/Yarn Logs for Errors

*QUICKSTART_HOME/data/hadoop/yarn/log/*

### Investigate Web Test Failures

If you observe test failures when executing when using `$ datawaveWebTest`
* View inline help on test options: `$ datawaveWebTest --help`
* Rerun web tests with more/better output: `$ datawaveWebTest --verbose --pretty-print`
* View DataWave Query/Web logs

### 403 Forbidden from Browser?

* If you're receiving *403 - Forbidden* errors when accessing DataWave Web endpoints from a web browser, make
  sure that you've imported the test user's client certificate into the browser's certificate store. See the 
  quickstart [PKI Notes](quickstart-reference#pki-notes)

### Build &amp; Runtime Errors

* Check the Maven output to determine the cause of any build failures. If needed, a copy of Maven's output is always
  saved to *QUICKSTART_HOME/data/datawave/build-properties/build-progress.tmp*
  
* Inspect build properties to see if anything seems amiss. The properties file used by the quickstart's Maven build is here:
  *QUICKSTART_HOME/data/datawave/build-properties/{profile}.properties*.
  
* Verify that you have a symlink, *~/.m2/datawave/properties/{profile}.properties*, which points to
  *QUICKSTART_HOME/data/datawave/build-properties/{profile}.properties*

## Check Accumulo Logs for Errors

*QUICKSTART_HOME/accumulo/logs/*

## Check Hadoop Logs for Errors

*QUICKSTART_HOME/hadoop/logs/*

## View Status of Services

* Inspect all of your running JVMs: `jps -lm`
* Compare the `jps` output with your quickstart service status: `allStatus` will report PIDs of all your services, and should
  appear similar to the following (Note: ZooKeeper PID appears in the Accumulo PID list, as ZK is managed by the Accumulo bootstrap)...
  ```bash
    $ allStatus
       Hadoop is running. PIDs: 9318 9629 9988 10188 10643 10705
       Accumulo is running. PIDs: 11196 11326 11536 11645 11750 11081
       DataWave Ingest is not running
       DataWave Web is running. PIDs: 17462
  ```

## Quickstart Help

View the [reference guide](quickstart-reference) for more information


[dw_blob_datawave_bootstrap_L77]: https://github.com/NationalSecurityAgency/datawave/blob/master/contrib/datawave-quickstart/bin/services/datawave/bootstrap.sh#L77