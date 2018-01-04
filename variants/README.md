
The structure of the `platforms` and `variants` folder must be identical, to ensure the
correct relative parent folder relationship used in the various modules. This is required
because terraform resolves the parent folder according the path name and not the directory
structure. This means that parents of symbolic links are determined by the path of
the symbolic link and not the target path of link.

A symbolic link is required to fade-in platform specific modules. To align the directory
structure including the link, the symbolic link to determine the current platform is
double indirect: The first link is part of the folder structure (see remarks above)
below the `variants` folder with the name `current`. This link does not point directly to the
actual platform, because this location is in the shared module. Instead it points pack to
a link above the root module in the cluster project, that the determines the correct variant for
the actual cluster.

