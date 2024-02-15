---
title: 'Archive CDC InfluxDB'
date: '2024-02-14T15:06:243+5:00'
categories: ["how-to"]
description: How to archive Audit trail data from InfluxDB on Rhize
draft: true
weight: 400
menu:
  main:
    parent: maintain
    identifier: maintain-influx
---

Based on usage and storage you may need to regularly archive the audit trail.

1. Backup a partition of the audit trail 

Get console inside influxdb container

Run the influx command to backup a time slice of history (e.g. time since you last ran a backup until a month ago)

influxd backup --org libre --bucket libre --start 2022-01-01T00:00:00Z --end 2023-01-01T00:00:00Z --token <admin-token> /path/to/backup/location

https://docs.influxdata.com/influxdb/v1/tools/influxd/backup/

2. Verify the backup

3. Delete old data

influx delete --org libre --bucket libre --start 2022-01-01T00:00:00Z --end 2023-01-01T00:00:00Z --token <admin-token> /path/to/backup/location
