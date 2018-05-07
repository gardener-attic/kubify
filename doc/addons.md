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
|logging| Fluentd, Kibana, ElasticSearch logging stack|
|monitoring| Prometheus, Alertmanager, Grafana monitoring stack|
|guestbook|Application Deployment Example|
|[dex](addons/dex.md)|[Identity Provider](https://github.com/coreos/dex/blob/master/README.md)|
|gardener|[Kubernetes Cluster Management](https://github.com/gardener/gardener/blob/master/README.md)|

### Monitoring Addon – Add custom config
The monitoring stack, which consists of Prometheus, Alertmanager and Grafana, can be extended by injection of custom configuration.
The custom configuration, provided in static files, will be appended and/or merged to the default configuration.

An exception here is the alertmanager. The config of those component will be overridden by custom config.
Only some global configuration for smtp will be not overridden.

Config snippet to add to the ``terraform.tfvars``. Everthing is optional (smtp config makes no sense if not provided completly).
```
addons = {
  "monitoring" = {
    "prometheus_rules_file"    = "<relative/path/to/custom/prometheus/rules.yaml>"
    "prometheus_config_file"   = "<relative/path/to/custom/prometheus/scrape/config.yaml>"
    "grafana_config_file"      = "<relative/path/to/custom/grafana/dashboard/config.yaml>"
    "alertmanager_config_file" = "<relative/path/to/custom/alertmanager/config.yaml>"

    "smtp_host"     = "<global-smtp-host>"
    "smtp_from"     = "<global-smtp-from>"
    "smtp_username" = "<global-smtp-user>"
    "smtp_password" = "<global-smtp-password>"
  }
}
```

#### Example config
1. **Prometheus scrape configs**
```yaml
- job_name: 'test'
  ...
- job_name: 'test-2'
  ...
```
2. **Prometheus rules**
```yaml
alerts-1.yaml: |
  groups:
  - name: test.rules
    rules:
    - alert: test
      expr: ...
      for: 0s
  ...
```
3. **Grafana Dashboard**
```yaml
dashboard-1.json: |-
  {
    dashboard: {
      ...
    }
  }
dashboard-2.json: |-
  {
    dashboard: {
      ...
    }
  }
```
4. **Alertmanager config**
```yaml
route:
  receiver: dev-null
  ...
receivers:
- name: dev-null
  ...
```

