### Migrating a self-hosted Etcd Cluster to Static Etcds

The etcd mode is selecting in the configuartion by the `selfhosted_etcd` parameter. Setting it to `false` will enable the static etcd mode. This is simply possible for new clusters. Existing clusters must explicitly be migrated. Unfortunately this migration cannot be done just by switching the value for this parameter.

The migration is only possible using a cluster recovery. The following steps
must be performed:

- Save the latest etcd backup file somewhere near the terraform project
- Set the following parameters in `terraform.tfvars`:

|Name|Value|
|---|---|
|selfhosted_etcd|false|
|recover_cluster|true|
|recover_redeploy|true|
|etcd_backup_file|"file path of the backup file"|

- Because of a misbehaving terraform the terraform state must be adapted manually before applying the changes:

  -  remove a used resource for `module.instance.module.seed.null_resource.manifests`: `template_dir.bootkube-self`.
  
  This can be done with the following terraform command from the landscape folder

```bash
$ terraform state rm module.instance.module.seed.template_dir.bootkube-self
```

- Now the changes can be applied by `terraform apply variant` 

- Afterwards the recovery options must be removed again.
