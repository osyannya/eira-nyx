# Secret problems to be solved

**WARNING**
Simplified version will be rewritten soon

sops-nix issue with re-key, encrypting manually every file, can it be piped.

**Host SSH key** 
Solving the paradox of generating the primary host SSH keypair on a blank machine before `nixos-anywhere` runs, or handling it deterministically during installation without user input.

**User SSH key** 
How to securely generate and inject user-level SSH keypairs onto machines without relying on an existing user password login to place them.

**Secret decryption key ring mapping** 
Determining whether host keys, user keys, or a combination of both should be mapped inside `.sops.yaml` to ensure individual users can only decrypt what they have clearance to see.

**Automatic SSH key rotation**
Workflow for rotating host and user SSH keypairs across one, some, or all systems concurrently without causing administrative lockout.

**Recovery from key rotation** 
Preventing data loss or lockouts by dynamically re-encrypting the SOPS repository payload with the newly rotated public keys during the rotation cycle.

**Large-scale password updates** 
Scaling user password lifecycle updates across multiple users across unique workstation fleets without generating individual, manual PRs for every single password change.

**Role-based secret distribution segmentation**
Isolating the groups so that workstations, servers, etc only receive and decrypt their designated corporate secrets in memory.

**Ephemeral secret management** 
Securing the transit of the initial encryption keys during the `nixos-anywhere` installation before the permanent systemd-sops runtime layer is fully constructed.
