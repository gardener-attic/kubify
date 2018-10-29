This project uses the following folder structure:

The root folder contains a central `modules` folder
hosting general utility modules and the main terraform
module to maintain a terraform cluster (`instance`).
This main cluster module then uses platform specific
modules for the IaaS setup, the VM creation and the LBaaS
handling.

This central module is called by
platform specific root projects located below the
`variants` folder, here: `openstack`, `azure` and `aws`.
These folders contain the top level terraform projects for the
dedicated variant and variant specific module implementations
used by the central platform agnostic terraform modules.
The platform specific modules are typically linked to a platform
specific module pool found in `platforms/<`platform`>`.
If there are multiple variants for a dedicated IaaS platform
there might be multiple folders below the `variants` folder
refering to shared platform modules stored below the same
`platforms` folder (not yet used).

The folder `basetemplates` contains the bootstrap files 
originally rendered by `bootkube` used as basis for the
actual versions of the bootkube assets stored in this project.
These files are used to check for updates in new `bootkube`
versions. They are not used by the terraform project.
The corresponding template files used by this project can be found
in `modules/seed/templates/bootkube`. The module `seed`
handles the generation of the complete bootkube assets
using settings and certificates generated in the `cluster`
module.

The folder `modules` contains generic terraform
modules used by the main terraform module or utility
modules to be used by the generic and platform specific parts.
The generic modules do not contain platform specific parts.
Platform specific resources are factored out to
dedicated platform specific modules.

The folder `doc` contains some markup files for the
documentation via github.

The folder `bin` contains some useful utility scripts (bash)
used to work with the cluster and cluster nodes as well as 
for the migration of terraform state for new versions
of the terraform project.

Every new version of this project comes with a migration script
[`migration.mig`](../migrate.mig)  that is used by the command
`migrate` to adapt old terraform state files before they can be
used with the actual version. For this purpose the state
structure used by this project is versioned. The update is done
version by version until the actual version is reached.
