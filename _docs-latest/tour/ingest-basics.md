---
title: "DataWave Tour: Ingest Basics"
layout: tour
tags: [getting_started, ingest]
summary: |
  The examples below will demonstrate DataWave Ingest usage. In order to follow along in your own DataWave
  environment, you should first complete the <a href="../getting-started/quickstart-install">Quickstart Installation</a>
---

## Ingest Configuration Basics

DataWave Ingest is largely driven by configuration. Below we'll use DataWave's example **tvmaze** data type ('myjson' config)
to examine the basic configuration settings that are used to establish a data type within the ingest framework.

{% include data-dictionary-note.html %}

{% include tvmaze-note.html %}

<ul id="profileTabs" class="nav nav-tabs">
    <li class="active"><a class="noCrossRef" href="#define-type" data-toggle="tab">1: Define the Data Type</a></li>
    <li><a class="noCrossRef" href="#register-type" data-toggle="tab">2: Register the Data Type</a></li>
</ul>
<div class="tab-content">
<div role="tabpanel" class="tab-pane active" id="define-type" markdown="1">
### Step 1: Define the Data Type

The example config, [myjson-ingest-config.xml][dw_blob_myjson_config], defines our **tvmaze** data type.

**Deploy directory**: $DATAWAVE_INGEST_HOME/config/

```xml
<configuration>

 <property>
     <name>data.name</name>
     <value>myjson</value>
     <description>
       This value is effectively an identifier for both the data type and its associated data
       feed, in order to distinguish it from other data types/feeds registered within DataWave.
       Therefore, it must be unique.
            
       That is, when we kick off an ingest job for a set of related input files, we pass
       this identifier along to the job runner, which instructs DataWave to use the settings
       defined here to control the processing of those files.
                                    
       Additionally, if a "{data.name}.output.name" value is NOT specified below, then, by
       default, this value will also be used as the data type identifier in Accumulo, and
       will therefore be known to DataWave Query clients via the data dictionary.
       
       Also note that {data.name} is used as a prefix for most of the remaining property
       names in this file
     </description>
 </property>

 <property>
     <name>myjson.output.name</name>
     <value>tvmaze</value>
     <description>
       This will be the name used to identify the data type in Accumulo and will be known to
       DataWave Query clients via the data dictionary. It does not have to be unique.
       
       For example, we might find later on that http://api.tvmaze.com has additional data that
       we're interested in, perhaps info about all past episodes of the TV shows we've ingested.
       
       Rather than modify the 'myjson' data feed, we may opt to establish a brand new feed with
       its own distinct config. If so, we can still utilize 'tvmaze' as our *.output.name value.
       
       Using the same output name allows for the Accumulo data objects from the new feed to be
       merged into, and collocated with, the corresponding data objects from the 'myjson' feed,
       provided both feeds are utilizing the same sharding and UID creation strategies
     </description>
 </property>

 <property>
     <name>file.input.format</name>
     <value>datawave.ingest.json.mr.input.JsonInputFormat</value>
     <description>
       Hadoop MapReduce InputFormat implementation
     </description>
 </property>

 <property>
     <name>myjson.reader.class</name>
     <value>datawave.ingest.json.mr.input.JsonRecordReader</value>
     <description>
       Implements Hadoop MapReduce RecordReader and other DataWave-specific
       interfaces in order to present raw data objects (e.g., TV shows) to
       our mappers, i.e., datawave.ingest.mapreduce.EventMapper, as input
     </description>
 </property>

 <property>
     <name>myjson.ingest.helper.class</name>
     <value>datawave.ingest.json.config.helper.JsonIngestHelper</value>
     <description>
       Implements datawave.ingest.data.config.ingest.IngestHelperInterface, for
       parsing and extracting field name/value pairs from each raw data object
     </description>
 </property>

 <property>
     <name>myjson.handler.classes</name>
     <value>datawave.ingest.json.mr.handler.ContentJsonColumnBasedHandler</value>
     <description>
       Comma-delimited list of classes that will process each data object in order
       to produce Accumulo key/value pairs in accordance with DataWave's data model
     </description>
 </property>
 
 <property>
     <name>myjson.data.category.marking.default</name>
     <value>PRIVATE|(BAR&amp;FOO)</value>
     <description>
       ColumnVisibility expression to be applied to each field, when 
       the raw data is known to provide none
     </description>
 </property>
 
 <property>
     <name>myjson.data.category.index</name>
     <value>NAME,ID,EMBEDDED_CAST_CHARACTER_NAME,...</value>
     <description>List fields names that we want to have indexed</description>
 </property>

 <!-- 
    The remaining settings in this file are beyond the scope of
    this example, and will be covered later 
 -->
 
 ...

</configuration>

```
</div>
<div role="tabpanel" class="tab-pane" id="register-type" markdown="1">
### Step 2: Register the Data Type

The config file, [ingest-config.xml][dw_blob_ingest_config], is used to register all of our data types and define a few
global settings

**Deploy directory**: $DATAWAVE_INGEST_HOME/config/

```xml
<configuration>
 
 <property>
   <name>ingest.data.types</name>
   <value>myjson,...</value>
   <description>
     Comma-delimited list of data types to be processed by the system. The {data.name} value for your
     data type MUST appear in this list in order for it to be processed 
   </description>
 </property>
 
 ...
 
 <property>
   <name>event.discard.interval</name>
   <value>0</value>
   <description>
     Per the DataWave data model, each data object (a.k.a. "event") has an associated date which is used
     to determine the object's YYYYMMDD shard partition within the primary data table. The value of this
     property is defined in milliseconds and denotes that an object having a date prior to
     (NOW - event.discard.interval) should be discarded. E.g., use a value of (1000 x 60 x 60 x 24)
     to automatically discard objects more than 24 hrs old  
      - A value of 0 disables this check
      - A data type can override this value with its own "{data.name}.event.discard.interval" property
   </description>
 </property>
 ...
</configuration>

```
</div>
</div>

### Additional Considerations

#### The special 'ALL' data type config

The config file, [all-config.xml][dw_blob_all_config], may be used for settings that we wish to apply to *all* registered data types.

**Deploy directory**: $DATAWAVE_INGEST_HOME/config/

```xml
<configuration>
 ...
 <property>
     <name>all.handler.classes</name>
     <value>datawave.ingest.mapreduce.handler.edge.ProtobufEdgeDataTypeHandler</value>
     <description>
       Comma-delimited list of data type handlers to be utilized by all registered types, in
       *addition* to any distinct handlers set by the individual data types via their *-config.xml files.
     </description>
 </property>
 ...
 <property>
     <name>all.ingest.policy.enforcer.class</name>
     <value>datawave.policy.IngestPolicyEnforcer$NoOpIngestPolicyEnforcer</value>
     <description>
        Name of the class to use for record-level (or per-data object) policy enforcement
     </description>
 </property>
 ...
</configuration>
```

#### Edge definition configs

The config file, [edge-definitions.xml][dw_blob_edge_config], may be used to define various edge types, which are derived
from our registered data types. Edges defined here are persisted in the [DataWave Edge Table](../getting-started/data-model#edge-table).

**Deploy directory**: $DATAWAVE_INGEST_HOME/config/

For example, the *ProtobufEdgeDataTypeHandler* class is responsible for generating graph edges from incoming data objects.
Thus, it leverages this config file to determine how and when to create edge key/value pairs.

Our **myjson** data type defines multiple edge types based on the fields present in the *TVMAZE-API* dataset

{% include edge-dictionary-note.html %}

## In Review



[dw_blob_myjson_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/myjson-ingest-config.xml
[dw_blob_ingest_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/ingest-config.xml
[dw_blob_all_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/all-config.xml
[dw_blob_edge_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/edge-definitions.xml
