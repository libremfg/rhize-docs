---
title: Service configuration
description: A collection of pages to look up configuration parameters for various Rhize services.
weight: 400
menu:
    main:
        parent: reference
        identifier: reference-service-config
---

The Rhize services have different configuration parameters, as documented in the following pages.

{{% reusable/config-map "core" %}}

<!---
instructions to print to file

You can use the CLI to print configurations to a file.
For example, to do so for the Core service, run this command:

-->

## Printing Configuration Settings to a File

You can use the CLI to print configuration settings to a file. To print the configuration settings to a file using the provided CLI command, follow these steps:

1. **Open the terminal.**

2. **Navigate to the directory containing the Go file with the configuration structure (`main.go` for Agent and Core, `server.go` for Audit and BPMN).** 
   ```sh
   cd <path/to/directory>
   
3. **Use the following commands, depending on the Go file present in your directory:**
   ```sh
   go run <goFile> config <printPath>
   ```
    For example:
    ```sh
    go run main.go config config/configCopy.yaml
    go run server.go config example.yaml