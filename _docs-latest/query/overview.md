---
title: DataWave Query Overview
tags: [getting_started, architecture, query]
toc: false
---

## JEXL / Iterator Framework

The design of DataWave Query is predicated in large part upon [Java Expression Language (JEXL)][jexl]. JEXL serves two
key roles within the query framework. First, JEXL is used as the basis for DataWave's [query language](syntax). Thus, it
plays a central role within client requests to retrieve data of interest. Secondly, JEXL is utilized within DataWave internals
to drive query execution. That is, DataWave Query leverages JEXL libraries to harness a variety of custom and stock
[Accumulo Iterators][acc_iterators] which facilitate query evaluation and object retrieval, for the text objects residing
in DataWave's Accumulo [tables](../getting-started/data-model).

## REST Services

External DataWave clients typically interact with the query framework by way of REST services. DataWave's REST services
are designed to support a large number of concurrent users and may be deployed to one or more application servers as needed for
scalability. They accept ad hoc query expressions from users, and they leverage the internal framework to evaluate those
expressions in an efficient manner. Moreover, DataWave's REST services support the retrieval of query results using a
variety of client-side strategies, and they support the serialization of query results into a variety of binary formats,
such as XML, JSON, Protobuf, and others.

## Query Logics

DataWave Query can be customized through a wide variety of client- and server-side configuration options
and through direct extension of its software interfaces. Software extension is typically accomplished through the implementation
of [query logic](development#query-logic-components) components. DataWave's query logics are loosely-coupled Java constructs that
serve as high-level abstractions within the API. Each is designed to support a specific type of query or use case, receiving as
input the user's query request and encapsulating the Accumulo client logic required to service that query. Query logics are
instantiated within the web tier via dependency injection, using IoC frameworks such as Spring and CDI.

DataWave provides several query logic components that support a wide variety of use cases and configuration options.
These will be discussed in detail within subsequent [pages](/pages/tags/query) of this user documentation.

[acc_iterators]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_iterators
[jexl]: http://commons.apache.org/proper/commons-jexl/