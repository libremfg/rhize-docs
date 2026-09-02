---
title: {{ replace .File.ContentBaseName `-` `.` | title | humanize }}
date: '{{ .Date }}'
description: Release notes for v{{ replace .File.ContentBaseName `-` `.` | title }} of the Rhize application
categories: ["releases"]
weight: {{ $t := time.Now }}{{ sub 3418067418 $t.Unix }} ## auto-generated, don't change
---

Release notes for version {{ replace .File.ContentBaseName `-` `.` | title }} of the Rhize application.

_Release date:_
{{ $t := time.Now }}{{ time.Format "2 Jan 2006" $t }}

## Changes by service

The following sections document the changes this release brings to each service.


### Admin

_No changes. Releasing in step with other components._

### Agent

_No changes. Releasing in step with other components._

### BaaS

_No changes. Releasing in step with other components._

### ISA-95

_No changes. Releasing in step with other components._

### Typescript host service

_No changes. Releasing in step with other components._

### Workflow

_No changes. Releasing in step with other components._

## Compatibility

{{< compatible "{{ replace .File.ContentBaseName `-` `.` | title }}" >}}

## Checksums

{{% checksums "v{{ replace .File.ContentBaseName `-` `.` | title }}-checksums.txt"  %}}

## Upgrade

To upgrade to v{{ replace .File.ContentBaseName `-` `.` | title }}, follow the [Upgrade instructions](/deploy/upgrade).
