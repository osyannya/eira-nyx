let
  # /persist/etc/ssh/ssh_host_ed25519_key.pub
  legion5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrM4Uwdlat/DoCCNm/HVJNtb15Z2MBhgoauKnFt8dUJ";
  # /persist/home/alva/.ssh/id_ed25519.pub
  alva = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPa1If2ZLO/5SiBpqvgKf7qyuTCXtFJv3VQFF8ShTduo"; 

  svitoglyad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlgX1+zwpoZCOsQJf5NIUC5f/NAt17W8Bzoyo3Pj64K";
  mriya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICDHJUdm2lPorUs+od+WIJtM8zBv286ggYZZjGe8WhFI";
in
{
  "hosts/legion5/secrets/root-password.age".publicKeys = [ legion5 alva ];
  "hosts/svitoglyad/secrets/root-password.age".publicKeys = [ svitoglyad mriya ];

  "users/alva/secrets/password.age".publicKeys = [ legion5 alva ];
  "users/mriya/secrets/password.age".publicKeys = [ svitoglyad mriya ];

  "secrets/shared/networks.age".publicKeys = [ alva mriya ];
}

# Generate host ssh key pair
# sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
# Generate user ssh key pair leave empty passphrase
# ssh-keygen -t ed25519
