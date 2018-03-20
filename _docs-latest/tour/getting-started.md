---
title: "DataWave Tour: Getting Started"
layout: tour
tags: [getting_started]
toc: false
summary: |
  The guided tour will introduce you to DataWave's ingest and query components and provide several examples of how to use
  and configure them. In order to follow along with the examples, you should first complete the
  <a href="../getting-started/quickstart-install">Quickstart Installation</a>
---

## Verify Your Environment Setup

At this point, you should have a standalone DataWave Quickstart environment instantiated. Throughout the tour, we'll be
using its example datasets, its pre-built configs, and many of its [utility functions](../getting-started/quickstart-reference).
Follow the steps below to ensure that your environment is up and functioning as required.

### Check the Status of Your Services

Execute the `allStatus` command to show the PIDs of your running DataWave services. If DataWave Ingest isn't running,
that's fine. We'll start it up later on in the tour

```bash
 $ allStatus
    Hadoop is running. PIDs: 9318 9629 9988 10188 10643 10705
    Accumulo is running. PIDs: 11196 11326 11536 11645 11750 11081
    DataWave Ingest is not running
    DataWave Web is running. PIDs: 17462
```

### Check Your DataWave Web Deployment

If DataWave Web is not currently running, then perform the commands shown below to verify that web services are up
and functioning as required

```bash
 $ datawaveWebStart # Will start up web services along with any dependencies, if needed
 
 [DW-INFO] - Starting Wildfly
 [DW-INFO] - Polling for EAR deployment status every 4 seconds (15 attempts max)
     -- Wildfly process not found (1/15)
     +- Wildfly up (7663). EAR deployment pending (2/15)
        ...
        ...
     ++ DataWave Web successfully deployed ...

 [DW-INFO] - Documentation: https://localhost:8443/DataWave/doc
 [DW-INFO] - Data Dictionary: https://localhost:8443/DataWave/DataDictionary
```
```bash
 $ datawaveWebTest # Execute pre-configured, curl-based tests against the REST API
   ...
   ...
   QueryMetricsQueryCreateAndNext
   QueryMetricsQueryClose
   QueryMetricsQueryZeroResults204
   
   Failed Tests: 0 
```

## Troubleshooting

If you experience any issues with your environment during this or any subsequent exercises, please see the
[troubleshooting guide](../getting-started/quickstart-trouble) for help before proceeding. 


