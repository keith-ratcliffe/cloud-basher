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
[Accumulo Iterators][acc_iterators] to facilitate query evaluation and object retrieval for the text objects that reside
in DataWave's [tables](../getting-started/data-model).

## Query Logics

DataWave Query can be customized through a wide variety of client- and server-side configuration options and also through
direct extension of software interfaces. Software extension is typically accomplished through the implementation
of [query logic](development#query-logic-components) components. A DataWave query logic is a loosely-coupled Java class that
leverages the [JEXL/Iterator framework](#jexl--iterator-framework) to support a specific type of query or use case. A query
logic instance receives a user's query request as input, and it encapsulates the business logic necessary to service that
query. Query logics are typically instantiated within the web tier via dependency injection, using IoC frameworks such as
Spring and CDI.

The DataWave project provides several query logics that support a variety of use cases and configuration options. These
will be discussed in detail within subsequent [pages](/pages/tags/query) of this user documentation.

## REST Services

External DataWave clients typically interact with the query framework by way of REST services. DataWave's REST services
are designed to support a large number of concurrent users and may be deployed to one or more application servers as needed for
scalability. They accept ad hoc query expressions from users, and they leverage [query logics](#query-logics) to evaluate those
expressions in an efficient manner. Moreover, DataWave's REST services support the retrieval of query results using a
variety of client-side strategies, and they support the serialization of query results into a variety of binary formats,
such as XML, JSON, Protobuf, and others.


[acc_iterators]: https://accumulo.apache.org/1.8/accumulo_user_manual.html#_iterators
[jexl]: http://commons.apache.org/proper/commons-jexl/