---
title: DataWave Overview
tags: [getting_started, architecture]
toc: false
---
## Use Cases

The DataWave project's primary goal is to provide a general purpose framework to facilitate persistence, indexing,
and retrieval of both structured and unstructured textual objects. Central to DataWave's design is that it leverages the
[Accumulo][apache_accumulo] key/value store to implement a [data model](data-model) that supports a wide variety of use
cases, and also to implement [ingest](../ingest/overview) and [query](../query/overview) components that are robust,
scalable and secure.

Additional use cases for DataWave include...

* Data fusion across structured and unstructured datasets
* Construction and analysis of distributed graphs
* Multi-tenant data architectures, with tenants having distinct security requirements and access patterns

For data security, DataWave leverages Accumulo's [cell-level security][cell_level_sec] mechanism as a core feature of
its architecture. As a result, organizations can secure their data with either coarse- or fine-grained access controls,
and they can easily integrate DataWave's client-facing services with their existing private key infrastructure (PKI)
and user-auth services.

## Software Architecture

DataWave is written in Java and its core services are built upon an extensible software architecture. DataWave was
designed to support a high degree of customization within each layer of its architecture, through highly configurable
application components and through direct extension of software interfaces.

DataWave's primary software components are its ingest and query frameworks. To get [DataWave Ingest](../ingest/overview)
and [DataWave Query](../query/overview) up and running quickly, checkout the [quickstart install](quickstart-install) and
the [guided tour](../tour/getting-started) 

---

[apache_accumulo]: http://accumulo.apache.org/
[apache_hadoop]: http://hadoop.apache.org/
[cell_level_sec]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_security


