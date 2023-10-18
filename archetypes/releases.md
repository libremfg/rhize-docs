---
title: Version '{{ replace .File.ContentBaseName `-` `.` | title | humanize }}'
date: '{{ .Date }}'
draft: true 
version:
description: Release notes for v{{ replace .File.ContentBaseName `-` `.` | title }} of the Rhize application
categories: ["releases"]
menu:
  main:
    parent: releases
---

Release notes for v{{ replace .File.ContentBaseName `-` `.` | title }} of the Rhize application.

<!---
## Breaking changes
-
-
## Features

-
-
## Fixes and refactoring

-
-
## Upgrade instructions

1.
1.

Confirm the upgrade succeeded by ...
-->
