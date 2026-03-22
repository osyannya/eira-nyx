let
  # /persist/etc/ssh/ssh_host_ed25519_key.pub
  legion5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDYJ7yC167CdM/b4QvTptrkwvfT/fwd9eR5Go0b3xH7s";
  # /persist/home/alva/.ssh/id_ed25519.pub
  # alva = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPa1If2ZLO/5SiBpqvgKf7qyuTCXtFJv3VQFF8ShTduo"; 

  svitoglyad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlgX1+zwpoZCOsQJf5NIUC5f/NAt17W8Bzoyo3Pj64K";
  mriya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDHJUdm2lPorUs+od+WIJtM8zBv286ggYZZjGe8WhFI";
in
{
  "hosts/legion5/secrets/root-password.age".publicKeys = [ legion5 ];
  "hosts/svitoglyad/secrets/root-password.age".publicKeys = [ svitoglyad mriya ];

  "users/alva/secrets/password.age".publicKeys = [ legion5 ];
  "users/mriya/secrets/password.age".publicKeys = [ svitoglyad mriya ];

  "secrets/shared/networks.age".publicKeys = [ mriya ]; # alva removed
}

# Generate host ssh key pair
# sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
# Generate user ssh key pair leave empty passphrase
# ssh-keygen -t ed25519
