---
title: DataWave Ingest Configuration
tags: [ingest, configuration]
toc: true
---

## Data Type Configuration

### Configuration Files

* File Name: *{Data Type}-config.xml*
  - The only requirement for the file name is that it must end with "*-config.xml*"
  - Defines how a given data type should be processed
  - Example file: [myjson-ingest-config.xml][dw_blob_myjson_config]

* Edge definitions for the data type, if any, should be defined in a distinct, global config file
  - Example file: [edge-definitions.xml][dw_blob_edge_config]

### Properties

In practice, properties for a given data type may be defined by any number of specialized classes throughout the ingest API,
with each class establishing its own set of configurable behaviors for various purposes. The properties below are a small
subset of these, but they represent the core of ingest configuration and will be the most commonly used. 

{% include configuration.html 
   properties=site.data.config-data-type.data-type 
   caption="Data Type Properties" 
   sort_by_name=false %}
   
## Flag Maker Configuration

### Configuration Files

File Name: *flag-maker-{Flow Name}.xml*

This file contains configuration settings for a single Flag Maker process and its associated data types. The above file name format
is only a recommendation. The file name is not important and can be whatever you'd like.

DataWave provides two example Flag Maker configs and two sets of accompanying bash scripts. These are for
**[bulk][dw_blob_flag_config_bulk]** ingest and **[live][dw_blob_flag_config_live]** ingest respectively. However, new
configs and scripts can be created as needed. Generally speaking, there is no upper bound on the number of Flag Maker
processes that DataWave Ingest can support.

### Scripts

* *{Flow Name}-ingest-server.sh* -- regulates the number of jobs running and existing marker files for the flow, calls
  *{Flow Name}-execute.sh* if more jobs can be supported
* *{Flow Name}-execute.sh* -- runs the {Flow Name}-ingest.sh command from the first line in the flag file
* *{Flow Name}-ingest.sh* -- starts the mapreduce job

### Java Classes

* *FlagMaker.java*
* *FlagMakerConfig.java*
* *FlagDataTypeConfig.java*
* *FlagDistributor.java*

### Properties

{% include configuration.html 
   properties=site.data.config-flag-maker.flag-maker 
   caption="Flag Maker Instance Properties" 
   sort_by_name=true %}

{% include configuration.html 
   properties=site.data.config-flag-maker.flag-maker-datatype
   caption="Flag Maker Data Type Properties" 
   sort_by_name=true %}
   

## Bulk Loader Configuration

### Usage

Java class: *datawave.ingest.mapreduce.job.BulkIngestMapFileLoader*

```bash
*.BulkIngestMapFileLoader hdfsWorkDir jobDirPattern instanceName zooKeepers username password \
   [-sleepTime sleepTime] \
   [-majcThreshold threshold] \
   [-majcCheckInterval count] \
   [-majcDelay majcDelay] \
   [-seqFileHdfs seqFileSystemUri] \
   [-srcHdfs srcFileSystemURI] \
   [-destHdfs destFileSystemURI] \
   [-jt jobTracker] \
   [-shutdownPort portNum] \
   confFile [{confFile}]
```
### Properties

{% include configuration.html 
   properties=site.data.config-bulk-loader.bulk-loader 
   caption="Bulk Loader Arguments" 
   sort_by_name=true %}

[dw_blob_flag_config_bulk]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/flag-maker-bulk.xml
[dw_blob_flag_config_live]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/flag-maker-live.xml

[dw_blob_myjson_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/myjson-ingest-config.xml
[dw_blob_edge_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/edge-definitions.xml