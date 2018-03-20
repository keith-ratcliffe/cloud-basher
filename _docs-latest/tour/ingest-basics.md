---
title: "DataWave Tour: Ingest Basics"
layout: tour
tags: [getting_started, ingest]
summary: |
  The guide below will introduce you to DataWave's Ingest API. In order to follow along with the examples, you should
  first complete the <a href="quickstart-install">Quickstart Installation</a>
---

## Getting Started

At this point, you should have a standalone DataWave environment instantiated via the [Quickstart Installation](quickstart-install).
The quickstart environment provides several example datasets and pre-built configurations that we'll be utilizing throughout
the tour. It also provides [bash functions](quickstart-reference) that encapsulate and simplify most of the command line
operations that you'll need to interact with DataWave services. Follow the steps below to ensure that your environment is
up and running and functioning as required.

### Check the Status of Your Services

In a bash terminal, check the status of your running services. The `allStatus` command's output should
appear as below, with different PIDs of course. All services should be running except for DataWave Ingest, which we'll
start up later on in the tour.

```bash
 $ allStatus
    Hadoop is running. PIDs: 9318 9629 9988 10188 10643 10705
    Accumulo is running. PIDs: 11196 11326 11536 11645 11750 11081
    DataWave Ingest is not running
    DataWave Web is running. PIDs: 17462
```

If your output is different than above, then perform the commands as shown below.

```bash
 $ allStop          # Attempts to cleanly stop all running services (add --hard flag, if necessary)
 $ datawaveWebStart # Starts up web services along with any dependencies (e.g., Hadoop, Accumulo, etc)
```

### Verify *DataWave Web* Deployment

Finally, it's a good idea to verify that DataWave's web services are deployed and functioning as required

```bash
 $ datawaveWebTest  # Executes pre-configured, curl-based tests against the REST API
   ...
   QueryMetricsQueryCreateAndNext
   QueryMetricsQueryClose
   QueryMetricsQueryZeroResults204
   
   Failed Tests: 0 
   ...
   
```

## Troubleshooting

If you experience any issues with your environment during this or any subsequent exercises, please see the [troubleshooting guide](quickstart-trouble)
for help before proceeding. 
