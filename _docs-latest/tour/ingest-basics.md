---
title: "DataWave Tour: Ingest Basics"
layout: tour
tags: [getting_started, ingest]
summary: |
  The examples below will demonstrate usage of DataWave's Ingest API. In order to follow along in your own DataWave
  environment, you should first complete the <a href="../getting-started/quickstart-install">Quickstart Installation</a>
---

## A Simple Query Example

DataWave creates and maintains a data dictionary
([https://localhost:8443/DataWave/DataDictionary](https://localhost:8443/DataWave/DataDictionary)) of known data types
and their associated field names. A typical DataWave query expression will leverage one or more of these field names to
find data of interest.

Here, we'll construct a simple query that uses the *GENRES* field from our *tvmaze* data type to find TV shows in the
action and adventure genres.

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b>
The data for this example originated from [tvmaze.com/api](http://tvmaze.com/api), and the file that we ingested automatically
during the quickstart setup is [here](https://github.com/NationalSecurityAgency/datawave/blob/master/warehouse/ingest-json/src/test/resources/input/tvmaze-api.json).
For more information, view the [datawaveIngestJson](../getting-started/quickstart-reference#datawave-ingest-functions)
function documentation
</div>

### The Query Expression

DataWave accepts query expressions in either JEXL or Lucene syntax as shown below.

<div class="row">
  <div class="col-md-6">
       <h4>Lucene</h4>
       <pre>GENRES:action OR GENRES:adv*</pre>
  </div>
  <div class="col-md-6">
       <h4>JEXL</h4>
       <pre>GENRES == 'action' || GENRES =~ 'adv.*'</pre>
  </div>
</div>

For help with query syntax, view the [guide](../query/syntax).

## Using the Query API

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> Most query
examples in the guided tour will utilize the quickstart's
**datawaveQuery** [function](../getting-started/quickstart-reference#datawave-web-functions). It provides a curl-based
client that streamlines your interactions with the Query API and sets reasonable defaults for most parameters.
Query parameters can also be easily added and/or overridden.
<br/><br/>Use **`datawaveQuery --help`** for assistance<br/><br/>
More importantly, in order to demonstrate Query API usage, each example below will display the key aspects of
actual curl command used and also display the web service response
</div>

<ul id="profileTabs" class="nav nav-tabs">
    <li class="active"><a class="noCrossRef" href="#create-query" data-toggle="tab">1: Create the Query</a></li>
    <li><a class="noCrossRef" href="#get-results" data-toggle="tab">2: Fetch Paged Results</a></li>
    <li><a class="noCrossRef" href="#close-query" data-toggle="tab">3: Close the Query</a></li>
</ul>
<div class="tab-content">
<div role="tabpanel" class="tab-pane active" id="create-query" markdown="1">
### Step 1: Create the Query

DataWave/Query/{ query-logic }/create (*POST*)

Initializes server-side resources and responds with a unique ID for the query

```bash
 # Quickstart client command...

 $ datawaveQuery --verbose \                       # To output the actual curl command used
    --create-only \                                # For /create endpoint. Default is /createAndNext
    --logic EventQuery \                           # Query logic identifier for the path parameter
    --syntax LUCENE \                              # To use JEXL: --syntax JEXL
    --query " GENRES:action OR GENRES:adv* "

 # Curl command (abbreviated)...

 $ /usr/bin/curl -X POST https://localhost:8443/DataWave/Query/EventQuery/create \
 ... \
 -d pagesize=10 \                                  # Max results to return per page
 -d auths=BAR,FOO,PRIVATE,PUBLIC \                 # Accumulo auths to enable for user
 -d begin=19700101 -d end=20990101 \               # Date range filter
 -d queryName=Query_20180312121809 \               # Query name that's meaningful to user
 -d columnVisibility=BAR%26FOO \                   # Viz expression to use for query logging, etc.
 -d query=GENRES%3Aaction%20OR%20GENRES%3Aadv%2A \ # Query expression, URL-encoded
 -d query.syntax=LUCENE                            # Syntax identifier

 # Web service response...

 {
   "HasResults": true,
   "OperationTimeMS": 70,
   "Result": "758b6e03-4eb0-4923-b098-c161f0cb322d"
 }

```
</div>
<div role="tabpanel" class="tab-pane" id="get-results" markdown="1">
### Step 2: Fetch Paged Results

DataWave/Query/{ query-id }/next (*GET*)

Repeat this step until all pages have been returned, indicated by HTTP status code 204

```bash
 # Quickstart client command...

 $ datawaveQuery --verbose --next 758b6e03-4eb0-4923-b098-c161f0cb322d

 # Curl command (abbreviated)...

 $ /usr/bin/curl ... \
   -X GET https://localhost:8443/DataWave/Query/758b6e03-4eb0-4923-b098-c161f0cb322d/next

 # Web service response (abbreviated)...

 {
   "Events": [
     # Record 1 of N...
     {
       "Fields": [
          # Field name/value data for record 1 (omitted)
       ],
       # Record-level security markings for record 1...
       "Markings": {
         "entry": [
           { "key": "columnVisibility", "value": "PRIVATE|(BAR&FOO)" }
         ]
       },
       # Database metadata for record 1...
       "Metadata": {
         "DataType": "tvmaze",
         "InternalId": "-27cfzr.phrhgm.-jax0u1",
         "Row": "20180305_0",
         "Table": "shard"
       }
     },
     ... # Records 2 thru N omitted...
   ],
   # Listing of all field names returned by the query (most omitted here)
   "Fields": [
       ...
       "EXTERNALS_IMDB",
       "EXTERNALS_THETVDB",
       "EXTERNALS_TVRAGE",
       "GENRES",
       "ID",
       "LOAD_DATE",
       "NAME",
       "NETWORK_ID",
       "NETWORK_NAME",
       "OFFICIALSITE",
       "PREMIERED",
       "RECORD_ID",
       "RUNTIME",
       "SCHEDULE_TIME",
       "STATUS",
       "SUMMARY",
       ...
     ],
     "HasResults": true,
     "LogicName": "EventQuery",
     "OperationTimeMS": 229,
     "PageNumber": 1,
     "PartialResults": false,
     "QueryId": "758b6e03-4eb0-4923-b098-c161f0cb322d",
     "ReturnedEvents": N
 }

```
</div>
<div role="tabpanel" class="tab-pane" id="close-query" markdown="1">
### Step 3: Close the Query

DataWave/Query/{ query-id }/close (*PUT*)

Release any server-side resources (*datawaveQuery* client may have already done this for you automatically)

```bash
 # Quickstart client command...

 $ datawaveQuery --verbose --close 758b6e03-4eb0-4923-b098-c161f0cb322d

 # Curl command (abbreviated)...

 $ /usr/bin/curl ... \
   -X PUT https://localhost:8443/DataWave/Query/758b6e03-4eb0-4923-b098-c161f0cb322d/close

 # Web service response...

 <?xml version="1.0"?>
 <html>
   <head>
     <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
     <title>DATAWAVE - Void Response</title>
     <link rel="stylesheet" type="text/css" href="/screen.css" media="screen"/>
   </head>
   <body>
     <h1>datawave.webservice.result.VoidResponse</h1>
     <div>
        <b>MESSAGES:</b><br/>
        758b6e03-4eb0-4923-b098-c161f0cb322d closed.<br/>
        <b>EXCEPTIONS:</b><br/>
     </div>
   </body>
 </html>

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
