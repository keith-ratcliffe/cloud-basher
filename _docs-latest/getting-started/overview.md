---
title: DataWave Overview
tags: [getting_started, architecture]
toc: false
---

## Introduction

The DataWave project provides a general purpose framework to facilitate persistence, indexing
and retrieval of both structured and unstructured textual objects. Central to DataWave's design is that it leverages
[Apache Accumulo][apache_accumulo] to implement a flexible [data model](data-model) and to implement [ingest](../ingest/overview)
and [query](../query/overview) components that are robust and scalable.

Common use cases for DataWave include...

* Data fusion across structured and unstructured datasets
* Construction and analysis of distributed graphs
* Multi-tenant data architectures, with tenants having distinct security requirements and access patterns

DataWave provides flexible and extensible data security features predicated on Accumulo's [security][cell_level_sec] model.
As a result, organizations can apply either coarse- or fine-grained access controls to their data, and they can easily
integrate DataWave query clients into their existing security infrastructure.

## Software Architecture

DataWave is written in Java and its core services are built upon an extensible software architecture. Its primary components
are its [ingest](../ingest/overview) and [query](../query/overview) frameworks. Both were designed to support a high degree
of customization, through highly configurable application components and through extensible software interfaces.

## System Architecture

If necessary, DataWave's ingest and query components can easily be decoupled and hosted on distinct clusters, as shown
below. In this configuration, ingest processing is performed on dedicated resources so that user queries may be given
priority over CPU, memory, and network resources within the data warehouse cluster. However, if resource contention
between ingest processing and query processing is not a concern, then DataWave may just as easily be configured to operate
on a single, shared environment.

{% include image.html file="dw-system-overview.png" alt="DataWave System Overview" %}

Whether or not the ingest and warehouse clusters are distinct, raw data to be ingested may arrive in a staging area for
pre-processing, if needed, or it may be written directly to HDFS. Once the data arrives in HDFS, DataWave will process it
via MapReduce and ultimately write the MapReduce output to DataWave's Accumulo [tables](data-model) in the data
warehouse. Query clients then utilize DataWave's web services to retrieve data of interest from the warehouse.

[apache_accumulo]: http://accumulo.apache.org/
[apache_hadoop]: http://hadoop.apache.org/
[cell_level_sec]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_security


