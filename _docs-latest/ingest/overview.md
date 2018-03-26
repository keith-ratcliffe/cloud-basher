---
title: DataWave Ingest Overview
tags: [getting_started, architecture, ingest]
toc: false
---

## API Overview

DataWave Ingest utilizes MapReduce as its basis. It is highly scalable and is designed to support extensive
customization through [configuration](configuration) alone. For example, DataWave can be configured to ingest arbitrarily-defined
data schemas with no software development required, providing that the ingested schemas are encoded in common file formats
such as CSV, JSON, etc.

DataWave Ingest can also be extended to accept *new* file formats with minimal software development. Typically,
this is accomplished by extending one or more base classes within the [API](development) and by implementing
familiar Hadoop MapReduce abstractions such as *InputFormat* and *RecordReader*.
 
In any case, distributed *map* tasks perform the work of transforming your raw data objects into [Accumulo
key/value pairs][acc_data_model]. These key/value pairs are created in accordance with the DataWave
[data model](../getting-started/data-model) and as prescribed by any user-supplied configuration. Furthermore,
a DataWave ingest job may be configured to run in one of two operational modes, *live* mode or *bulk* mode, both of which
are described below.

## Live Ingest

A DataWave ingest job configured for *live* mode is a *map*-only job in which the *map* tasks use Accumulo *BatchWriter*
instances to write keys/values directly to DataWave's [tables](../getting-started/data-model) and directly into *tserver*
memory.

Thus, *live* mode provides the least amount of latency from the user's perspective, as the new data is made
available for query without first having to write it to disk. However, Accumulo must eventually write out the data
to the distributed file system, which will consume CPU, memory and other resources, thus decreasing the resources available
to service users' queries during that time.

## Bulk Ingest

In contrast to *live* mode, DataWave ingest jobs configured to operate in *bulk* mode use the *reduce* phase to write out
DataWave key/value pairs to the distributed file system in Accumulo's *RFile* format. Accumulo's *bulk import* feature can then
be employed to bring a large volume of *RFiles* online all at once, with little overhead required on the part of Accumulo.

Generally, this allows for greater overall ingest throughput and prioritizes system resources for user queries, but at
the cost of increased latency for users who may be waiting for the very latest data.

The DataWave project provides several ingest examples for a variety of file formats and data schemas. These and other
ingest topics will be discussed in greater detail within subsequent [pages](/pages/tags/ingest) of this user documentation.

[acc_data_model]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_data_model