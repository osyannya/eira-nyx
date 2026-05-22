# Bare metal provisioning

**WARNING**
Simplified version will be rewritten soon

## 1. Physical setup

### 1.1 Ensure

Power, Ethernet, USB flash drive

### 1.2 First power on

UEFI (ensure PXE is enabled, secure boot not yet), loading from the USB

## 2. Connection

DHCP assigns a predictable IP, SSH is active, VPN is active - tunnel to the network

## 3. Installation

On our laptop VPN, SSH, ping, nixos-anywhere

Completed

## Automation

nixos-anywhere is suitable for blank and linux machines, it handles secrets provisioning via extra files, LUKS passphrases can be securely piped too, automatic error handling, sbctl for secure boot does not work during installation
If there are lots of machines gnu-parallel or ansible can be used
