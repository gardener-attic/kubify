This module contains a iaas config handling. It maps dedicated parameters to a single map value
and a map value to dedicated outputs (pack and unpack).
The map version is used to pass the iaas config to generic modules that internally call iaas specific modules.
The module can be used by the iaas wrapper to pack the dedicated inpout parameters and by the iaas specific modules
to access the dedicated parameters again.

Change the file `variables.tf` to modify the iaas config interface.
Then call `../../../create.sh` to create the appropriate terraform file (`config.tf`).
