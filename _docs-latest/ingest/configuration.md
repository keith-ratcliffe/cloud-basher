---
title: DataWave Ingest Configuration
tags: [ingest, configuration]
toc: false
---

## Flag Maker Configuration

{% include configuration.html 
   properties=site.data.config-flag-maker.flag-maker 
   caption="Flag Maker Instance Properties" 
   sort_by_name=true %}

{% include configuration.html 
   properties=site.data.config-flag-maker.flag-maker-datatype
   caption="Flag Maker Data Type Properties" 
   sort_by_name=true %}
   
## Data Type Configuration

### Overview

* **File Name**: *<data type>-config.xml*
  - The only requirement for the name is that it must end with *\*-config.xml*
  - Defines how a given data type should be processed

* Important Settings
  - Unique name for registering the data type
  - InputFormat and RecordReader classes for the type
  - DataTypeHandler class(es) and IngestHelper class for generating Accumulo key/value pairs
  - Field names to index, reverse index, tokenize, etc
  - Field-specific Normalizer classes

* Edge definitions for the data type, if any, should be defined in *edge-definitions.xml*

### Bulk Loader

**Usage**:
```bash
BulkIngestMapFileLoader hdfsWorkDir jobDirPattern instanceName zooKeepers username password \
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

