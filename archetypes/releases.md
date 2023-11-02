---
title: {{ replace .File.ContentBaseName `-` `.` | title | humanize }}
date: '{{ .Date }}'
description: Release notes for v{{ replace .File.ContentBaseName `-` `.` | title }} of the Rhize application
categories: ["releases"]
weight: 0 ##zero if latest, 1 if otherwise
menu:
  main:
    parent: releases
---

Release notes for version {{ replace .File.ContentBaseName `-` `.` | title }} of the Rhize application.


_Release date:_

## Breaking changes

## Changes by service

## Upgrade

To upgrade to v{{ replace .File.ContentBaseName `-` `.` | title }}, follow the [Upgrade instructions](/deploy/upgrade).
