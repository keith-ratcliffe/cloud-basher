---
title: "DataWave Tour: Ingest Basics"
layout: tour
tags: [getting_started, ingest]
summary: |
  The examples below will demonstrate DataWave Ingest usage. In order to follow along in your own DataWave
  environment, you should first complete the <a href="../getting-started/quickstart-install">Quickstart Installation</a>
---

## Configuration Basics

DataWave Ingest is highly configuration-driven. Below we'll demonstrate the basic configuration concepts using
DataWave's example **tvmaze** data type.

{% include tvmaze-quickstart-note.html %}

<ul id="profileTabs" class="nav nav-tabs">
    <li class="active"><a class="noCrossRef" href="#define-type" data-toggle="tab">1: Define the Data Type</a></li>
    <li><a class="noCrossRef" href="#register-type" data-toggle="tab">2: Register the Data Type</a></li>
    <li><a class="noCrossRef" href="#ingest-data" data-toggle="tab">3: Ingest Some Data</a></li>
</ul>
<div class="tab-content">
<div role="tabpanel" class="tab-pane active" id="define-type" markdown="1">
### Step 1: Define the 'tvmaze' Data Type

The example config, [myjson-ingest-config.xml][dw_blob_myjson_config], defines the **tvmaze** data type.

**Deploy directory**: $DATAWAVE_INGEST_HOME/config/

```xml
<configuration>

    <property>
        <name>data.name</name>
        <value>myjson</value>
        <description>
            This is the name of the data type, which distinguishes it
            internally from other defined types for the purposes of
            ingest processing. Must be unique.
        </description>
    </property>

    <property>
        <name>myjson.output.name</name>
        <value>tvmaze</value>
        <description>
            This is the name to use on the data in Accumulo. Does not have to
            be unique. This will be the name known to DataWave Query clients.
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
            datawave.ingest.mapreduce.EventMapper as input
        </description>
    </property>

    <property>
        <name>myjson.ingest.helper.class</name>
        <value>datawave.ingest.json.config.helper.JsonIngestHelper</value>
        <description>
            Implements datawave.ingest.data.config.ingest.IngestHelperInterface,
            which knows how to parse field name/value pairs from a data object
            (e.g., a TV show)
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

    ...
    ...

</configuration>

```
</div>
<div role="tabpanel" class="tab-pane" id="register-type" markdown="1">
### Step 2: Register the 'tvmaze' Data Type

```xml

```
</div>
<div role="tabpanel" class="tab-pane" id="ingest-data" markdown="1">
### Step 3: Ingest New 'tvmaze' Data

```bash

```
</div>
</div>

## Summary

In **Step 1**, to initialize our query, we invoked *DataWave/Query/{ query-logic }/create* using *EventQuery* for the logic parameter.

* Alternatively, we could have used the *createAndNext* endpoint, which combines *Step 1* and *Step 2* into
  a single client request for convenience, automatically retrieving the first page of results, if any

* *EventQuery* here denotes the [query logic component](../query/development#query-logic-components) that we
  used for query execution. Semantically, an *event* in this context is a simple abstraction that DataWave uses to denote a
  single date-sorted record stored within DataWave's [primary data table](../getting-started/data-model#primary-data-table).
  Thus, the *EventQuery* logic is the primary API component that DataWave provides for fetching *events* from this table

* Our required parameters here were typical for most DataWave query types: the *query* expression to be evaluated, the *syntax*
  associated with that expression, the set of Accumulo *auths* enabled for data access, and others. In practice, required
  and optional parameters may be specified by a combination of the endpoint being invoked, the query logic being used,
  and the REST service itself

In **Step 2**, to retrieve results, we invoked *DataWave/Query/{ query-id }/next* with our query ID from *Step 1*.

* The *next* endpoint should have returned a page of results containing multiple TV shows, the size of which was bounded
  by the *pagesize* parameter that we specified in *Step 1* (defaulted to 10 by the *datawaveQuery* client)

* If there are no more results to fetch, the *next* endpoint responds with HTTP status code *204*

In **Step 3**, to release server-side resources, we invoked *DataWave/Query/{ query-id }/close* with our query ID from *Step 1*.

* Query clients should always invoke the *close* endpoint to release server-side resources when no further interaction
  with the query is needed

* Production query clients should be designed to automatically invoke *close* when *next* has no more results (as
  indicated by HTTP status code *204*), and also when the client encounters an unrecoverable error anytime after
  query creation

[dw_blob_myjson_config]: https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-configuration/src/main/resources/config/myjson-ingest-config.xml