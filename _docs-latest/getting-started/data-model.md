---
title: "Data Model"
tags: [getting_started, data_model, ingest, query]
summary: To facilitate storage, indexing, and retrieval, DataWave organizes data within Accumulo tables as described below
---

## Primary Data Table

The data table uses a sharded approach and can be described as an intra-day hash partitioned table
where fields in an data object are stored collocated in a single partition. The Shard Id is a function of
the UID and therefore should be reproducible given the same object ingested at different points in time.
This enables de-duplication of objects when they are re-ingested. The Data Type is a user defined
category of the data that will typically be used at query time. The Data Type allows for further
reduction in the amount of data to be searched.

The data table also contains an in-partition index, which we call the field index, and we denote the K,V
pairs that are in the field index with a leading 'fi' in the column family. The field index is used by
custom Accumulo iterators at query time to find data objects in the partition. Optionally, if the table is
used to store documents, then the original document or different views of the document can be stored in
the 'd' column family. Typically this column family would be set up as its own locality group. An
example of different views of a document could be .txt and .html versions of the original document.

To enable phrase queries on documents, the 'tf' column family contains a protocol buffer (PB) in the value
that is a list of word offsets for the term in the document. This too could also be stored in a separate
locality group.

The data table has the following structure

{% include table_primary.html %}

## Global Index Tables

[ TODO: Forward and reverse index table descriptions go here ]

## Metadata Table

[ TODO: Metadata table description goes here ]

## Edge Table

[ TODO: Edge table description goes here ]

## Other Tables

### Date Index Table

[ TODO: Date Index table description goes here ]

### Load Dates Table

[ TODO: Load Dates table description goes here ]

### Query Metrics Tables

[ TODO: Query Metrics table descriptions go here ]

### Ingest Error Tables

[ TODO: Ingest Error table descriptions go here ]

## Definitions

{% include data_model.html %}


[apache_accumulo]: http://accumulo.apache.org/
[apache_hadoop]: http://hadoop.apache.org/
[data_fusion]: https://en.wikipedia.org/wiki/Data_fusion
[graph_theory]: https://en.wikipedia.org/wiki/Graph_theory
[cell_level_sec]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_security
[acc_data_model]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_data_model
