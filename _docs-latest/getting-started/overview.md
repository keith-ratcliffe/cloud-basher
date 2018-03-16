---
title: DataWave Overview
tags: [getting_started, architecture, ingest, query]
summary: This page gives a brief overview of DataWave's software architecture and its typical use cases 
---
## Use Cases

The DataWave project's primary goal is to provide a general purpose framework to facilitate persistence, indexing,
and retrieval of both structured and unstructured textual objects. Central to DataWave's design is that it leverages the
[Accumulo][apache_accumulo] key/value store to provide robust, secure, and scalable ingest &amp; query services for these
objects.

Additional use cases for DataWave include...

* Data fusion across structured and unstructured datasets
* Construction and analysis of distributed graphs
* Multi-tenant data architectures, with tenants having distinct security requirements and access patterns

For data security, DataWave leverages Accumulo's [cell-level security][cell_level_sec] mechanism as a core feature of
its architecture. As a result, organizations can secure their data with either coarse- or fine-grained access controls,
and they can easily integrate DataWave's client-facing services with their existing private key infrastructure (PKI)
and user-auth services.

---

## Software Architecture

DataWave is written in Java and its core services are built upon an extensible software architecture. DataWave was
designed to support a high degree of customization within each layer of its architecture through highly configurable
application components and through direct extension of software interfaces. DataWave's primary software components are
its ingest and query frameworks, both of which are described in more detail below. To get DataWave's ingest and query
components up and running quickly, checkout the [quickstart install](quickstart-install) and the [guided tour](../tour/getting-started)

## Ingest Framework

The DataWave Ingest framework utilizes MapReduce as its basis. It is highly scalable, and it is designed to support a
high degree of customization through configuration alone. For example, DataWave can be configured to ingest arbitrarily-defined
data schemas with no software development required, providing that the ingested schemas are encoded in common file formats
such as CSV, JSON, XML, etc.

DataWave Ingest can also be extended to accept *new* file formats with minimal software development. Typically,
this is accomplished by extending one or more [Ingest API](../development/ingest-api) base classes and by implementing
familiar Hadoop MapReduce abstractions such as *InputFormat* and *RecordReader*. These extensions are primarily employed
within the map phase of the ingest job and delegate the majority of work to existing base classes within the API. Thus,
highly scalable map tasks perform the work of transforming your raw data objects into Accumulo
[key/value pairs][acc_data_model], in accordance with DataWave's [data model](data-model) and as dictated by user-supplied
configuration.

The DataWave project provides several ingest examples for a variety of file formats and data schemas. These and other
ingest topics will be discussed in greater detail within subsequent [pages](/pages/tags/ingest) of this user documentation. 

## Query Framework

The design of DataWave's [Query API](../development/query-api) is predicated largely upon [Java Expression Language (JEXL)][jexl],
which serves two key roles within the overall framework. First, JEXL is used as the basis for DataWave's [query language](query-syntax).
Thus, it plays a central role within client requests to retrieve data of interest. JEXL is also utilized extensively
within the Query API's internals to drive query execution. That is, DataWave leverages JEXL libraries to harness a variety
of stock and custom [Accumulo Iterators][acc_iterators] to facilitate query evaluation, in order to efficiently scan and
filter data stored in DataWave's [tables](data-model).

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> JEXL syntax
is DataWave's default. However, as a convenience for those already familiar with Lucene-based applications, queries may
also be submitted using Lucene syntax. See the [query syntax guide](query-syntax) for more information.</div>

The DataWave Query framework is typically exposed to remote clients via REST services. These services are designed to
support a large number of concurrent users and may be deployed to one or more application servers as needed for
scalability. Their primary role is to facilitate ad hoc query requests from users, leveraging the [Query API](../development/query-api)
to evaluate each query as efficiently as possible. Moreover, these services support the retrieval of query results
in a variety of different ways and in a variety of binary formats, such as XML, JSON, Protobuf, and others.


As with DataWave Ingest, DataWave Query supports a high degree of customization through both configuration and software
extension. Typically, software extension is accomplished through the implementation of one or more
[Query Logic](../development/query-api#query-logic-components) components. A DataWave Query Logic is a loosely-coupled API
construct that serves as a high-level abstraction between a user's query request and DataWave's Accumulo client software.

DataWave provides several Query Logic components that support a wide variety of query types and configuration options.
These will be discussed in detail within subsequent [pages](/pages/tags/query) of this user documentation.

---

[apache_accumulo]: http://accumulo.apache.org/
[apache_hadoop]: http://hadoop.apache.org/
[cell_level_sec]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_security
[acc_data_model]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_data_model
[acc_iterators]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_iterators
[jexl]: http://commons.apache.org/proper/commons-jexl/
