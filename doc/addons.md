### Optional Addons for a kubernetes cluster deployment

The configuration variable `addons` can be used to enable dedicated preconfigured
addon deployments provided by the template project. Just add the desired
addon names to a map `addons` in the `terraform.tfvars`file in the cluster project.

```
  addons = {
    "dashboard" = { }
    "nginx-ingress" = { }
    "heapster" = { }
  }
```

The value of every entry must be the local addon config as `map`. If there are no special
settings the map should be empty. It will automatically be backed by default config for
the dedicated addon.

By default the addons `dashboard`, `nginx` and `heapster` are enabled. This can be changed by
explicitly setting the variable `addons` in the cluster configuration and omitting the
dedocazted entry.

The following addons are supported so far:

|Name|Description|
|--|--|
|dashboard|The standard kubernetes dashboard|
|heapster |Resource usage analysis|
|nginx-ingress |Nginx http/https ingress controller for ports 80 and 443|
|kube-lego|Letsencrypt based TLS certificate support|
|fluentd-elasticsearch| Fluentd, Kibana, ElasticSearch logging stack|
|guestbook|Application Deployment Example|


