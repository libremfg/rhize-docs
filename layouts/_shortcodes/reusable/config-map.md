{{ $service := .Get 0 }}

To configure services in Kubernetes, add your configs to an overrides file.
For example, you might add your configuration to the {{ $service }} service through a command like this:

```shell
helm upgrade --install <MY_{{ upper $service }}_INSTANCE> -f ./<{{ upper $service }}_OVERRIDES>.yaml libremfg/core -n <MY_RHIZE_NAMESPACE>
```

On successful deployment, this configuration is added to the Kubernetes [ConfigMap](https://kubernetes.io/docs/concepts/configuration/configmap/).
