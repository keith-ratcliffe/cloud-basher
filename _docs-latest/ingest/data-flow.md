---
title: Ingest Data Flow
tags: [ingest]
toc: true
---

## Data Flow Overview

Raw data will often require grooming or pre-processing of some sort before being passed along to DataWave to be ingested.
However, this happens outside of the scope and purview of DataWave. Thus, DataWave's interaction with incoming data begins
in HDFS.

Each distinct data type registered within DataWave Ingest will have a configured "base directory" within HDFS, where a
dedicated *Flag Maker* process will monitor the arrival of new files for the given type. Based on the Flag Maker's governing
configuration, it will group some number of these files together and mark them as "flagged", which signals that they are
ready to be submitted as input to a MapReduce job.

If the given MapReduce job is configured for "live" ingest, then map tasks will write mutations directly into DataWave's
Accumulo [tables](../getting-started/data-model) in the warehouse cluster. If the MapReduce job is configured for "bulk"
ingest, then reduce tasks will write Accumulo RFiles as output, and a separate *Bulk Loader* process is then responsible
for loading them into Accumulo.   

{% include image.html url="/images/dw-data-flow-1.png" file="dw-data-flow-1.png" alt="Ingest Data Flow" %}

## The Flag Maker

A given Flag Maker process will be configured and deployed to manage a single data flow within the system. There can be
any number of Flag Maker processes, each driving M/R processing for its own flow, and that flow may consist of one or more
distinct data types. Data types are registered via DataWave Ingest configuration and are uniquely identified by their
respective **data.name** values.

Thus, the configuration settings for a given Flag Maker are tailored for the characteristics of its managed flow and its
associated data types, characteristics such as data volume, individual file size, raw file format, etc.   

{% include image.html url="/images/dw-flag-maker-1.png" file="dw-flag-maker-1.png" alt="Flag Maker Overview" %}

### Example Flag File

```bash
$DATAWAVE_INGEST_HOME/bin/ingest/live-ingest.sh /local/flags/1453374646.00_mydatatype_20160121103632_mymachine_16f803c3a4eff08c7.seq+784.flag.inprogress 150 -inputFormat datawave.ingest.input.reader.event.EventSequenceFileInputFormat -inputFileLists -inputFileListMarker ***FILE_LIST***
***FILE_LIST***
/data/flagged/mydatatype/2016/01/21/mydatatype_20160121103632_mymachine_16f803c3a4eff08c7.seq
/data/flagged/mydatatype/2016/01/21/mydatatype_20160121103455_mymachine_26d06d0502a022163.seq
/data/flagged/mydatatype/2016/01/21/mydatatype_20160121100507_mymachine_21732b5e75f12c859.seq
/data/flagged/mydatatype/2016/01/21/mydatatype_20160121105902_mymachine_32fb2a1590733dcfa.seq
/data/flagged/mydatatype/2016/01/21/mydatatype_20160121102012_mymachine_267877fd6f6f24357.seq
...
```

### Configuration Files

**flag-maker-{Flow Name}.xml**

This file contains [configuration settings](configuration#flag-maker-configuration) for a single Flag Maker process and its associated data types. The above file name format
is only a recommendation. The file name is not important and can be whatever you'd like.

DataWave provides two example Flag Maker configs and two sets of accompanying bash scripts. These are for
**[bulk][dw_blob_flag_config_bulk]** ingest and **[live][dw_blob_flag_config_live]** ingest respectively. However, new
configs and scripts can be created as needed. Generally speaking, there is no upper bound on the number of Flag Maker
processes that DataWave Ingest can support.

### Scripts

* **{Flow Name}-ingest-server.sh** -- regulates the number of jobs running and existing marker files for the flow, calls
  *{Flow Name}-execute.sh* if more jobs can be supported
* **{Flow Name}-execute.sh** -- runs the {Flow Name}-ingest.sh command from the first line in the flag file
* **{Flow Name}-ingest.sh** -- starts the mapreduce job

### Java Classes

* **FlagMaker.java**
* **FlagMakerConfig.java**
* **FlagDataTypeConfig.java**
* **FlagDistributor.java**

### Flag File Processing and Lifecycle

{% include image.html url="/images/dw-flag-maker-2.png" file="dw-flag-maker-2.png" alt="Flag File Lifecycle 1" %}

{% include image.html url="/images/dw-flag-maker-3.png" file="dw-flag-maker-3.png" alt="Flag File Lifecycle 2" %}

### Flag Maker Recovery

If a Flag Maker process happens to terminate abnormally for any reason...
1. Move all **flagging** files back to the HDFS base folder for the given data type
2. For all **flag.generating** files, move the flagged files to the base directory
3. Remove the **flag.generating** files
4. Investigate the root cause of the issue and restart the Flag Maker as needed

## MapReduce Jobs

### IngestJob.java

{% include image.html url="/images/dw-ingest-job-1.png" file="dw-ingest-job-1.png" alt="Ingest Job Overview" %}

[dw_blob_flag_config_bulk]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/flag-maker-bulk.xml
[dw_blob_flag_config_live]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/flag-maker-live.xml

