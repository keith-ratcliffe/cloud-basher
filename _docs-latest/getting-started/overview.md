---
title: DataWave Overview
tags: [getting_started, architecture]
toc: false
---
## Use Cases

The DataWave project provides a general purpose framework that facilitates persistence, indexing
and retrieval of both structured and unstructured textual objects. Central to DataWave's design is that it leverages
[Apache Accumulo][apache_accumulo] to implement a flexible [data model](data-model) and to implement [ingest](../ingest/overview)
and [query](../query/overview) components that are robust and scalable.

Common use cases for DataWave include...

* Data fusion across structured and unstructured datasets
* Construction and analysis of distributed graphs
* Multi-tenant data architectures, with tenants having distinct security requirements and access patterns

Additionally, DataWave was designed to leverage Accumulo's [cell-level security][cell_level_sec] as a core feature of its
architecture. As a result, organizations can apply either coarse- or fine-grained access controls to their data, and, if
needed, they can easily integrate DataWave query clients into their existing user authorization services and private key
infrastructure.

## Software Architecture

DataWave is written in Java and its core services are built upon an extensible software architecture. Its primary components
are its [ingest](../ingest/overview) and [query](../query/overview) frameworks. Both were designed to support a high degree
of customization, through highly configurable application components and through extensible software interfaces.
To get started, check out the [quickstart install](quickstart-install) and the [guided tour](../tour/getting-started) docs.

---

[apache_accumulo]: http://accumulo.apache.org/
[apache_hadoop]: http://hadoop.apache.org/
[cell_level_sec]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_security


