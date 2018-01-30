### [Dex - Identity Provider](https://github.com/coreos/dex/blob/master/README.md)

Because terraform does not support lookup of map entries of inhomogeneous types, the
config options of the `dex` addon are grouped according their complex type: `lists`, `maps` and plain `values`.
They are stored in separated field of the addon config map.

#### List configuration settings

List configuration settings are stored under `lists`.  The following options are supported:

|Name|Meaning|
|--|--|
|`connectors`|list of connector specifications|


##### Connector configuration 

So far two types of connectors are supported: `saml` and `github`.
All connector types require the following common settings:

|Name|Meaning|
|--|--|
|`type`|connector type (see above)|
|`id`|Optional: id to use for the connector (default is `type`)|
|`name`|Optional: name to use for the connector (default is `id`)|

###### SAML Connector

|Name|Meaning|
|--|--|
|`ssoURL`|single-sign-on service location to use for SAML request|
|`ssoIssuer`|identifier of identity provider|
|`entityIssuer`|identifier of saml service provider|
|`ca_cert`|certificate authority to validate saml assertions|


###### Github Connector

|Name|Meaning|
|--|--|
|`client_id`|client id of GitHub OAuth App|
|`client_secret`|client secret of GitHub OAuth App|
|`orgs`|Json document describing the [user/group selection](https://github.com/coreos/dex/blob/master/Documentation/connectors/github.md) |


#### Map configuration settings

The following map configuartion options are supported for the addon `dex`:

|Name|Meaning|
|--|--|
|`tls`   |Optional: tls certificate setting for the identity endpoint. If `kube-lego` is used, this option can be omitted, otherwise it must be set.|
|&nbsp;&nbsp;&nbsp;&nbsp;`cert`|The server certificate for `identity.`<cluster domain> |
|&nbsp;&nbsp;&nbsp;&nbsp;`key` |The private key for the certificate|


So far, no simple value settings are supported.
