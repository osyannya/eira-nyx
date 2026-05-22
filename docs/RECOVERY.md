# Disaster recovery and backup runbook

**WARNING**
Simplified version will be rewritten soon

External monitoring (only servers) and internal agent on each server (not workstations) should report systems state, depending on the system's state it should be returned to previous generation or reinstalled from scratch preserving data from persist if possible.

Emergency situations: 
hardware breaks, 
broken update, 
user breaks something: could be diverse situations including situations which cannot be fixed with the infrastructure alone like credential leakage in Web. If sudo rm -rf was used for instance.

Backups of persist are automatically conducted on schedule to remote storage. Regular snapshots of persist on schedule and before user login just to make sure user cannot break anything and as the result we get bad snapshot. Snapshots of previous generations, NixOS native mechanism.
