+++
title = "Troubleshooting"
weight = 21
[menu.main]
    parent = "deploy"
+++

This page provides tips on how to troubleshoot issues with running Dgraph.

### "Too many open files" errors

If Dgraph logs `too many open files` errors, you should increase the per-process
open file descriptor limit to permit more open files. During normal operations,
Dgraph must be able to open many files. Your operating system may have an open 
file descriptor limit with a low default value that isn't adequate for a database
like Dgraph. If so, you might need to increase this limit.

On Linux and Mac, you can get file descriptor limit settings with the `ulimit`
command, as follows:

* Get hard limit: `ulimit -n -H`
* Get soft limit: `ulimit -n -S`

A soft limit of `1048576` open files is the recommended minimum to use Dgraph in
production, but you can try increasing this soft limit if you continue to see 
this error. To learn more, see the `ulimit` documentation for your operating
system.

{{% notice "note" %}}
Depending on your OS, your shell session limits might not be the same as the Dgraph process limits.
{{% /notice %}}

For example, to properly set up the `ulimit` values on Ubuntu 20.04 systems:

```sh
sudo sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=1048576/' /etc/systemd/system.conf
sudo sed -i 's/#DefaultLimitNOFILE=/DefaultLimitNOFILE=1048576/' /etc/systemd/user.conf
```

This affects the base limits for all processes. After a reboot, your OS will pick up the new values.
