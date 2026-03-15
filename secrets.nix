let
  # /persist/etc/ssh/ssh_host_ed25519_key.pub
  legion5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrM4Uwdlat/DoCCNm/HVJNtb15Z2MBhgoauKnFt8dUJ";
  # /persist/home/alva/.ssh/id_ed25519.pub
  alva = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPa1If2ZLO/5SiBpqvgKf7qyuTCXtFJv3VQFF8ShTduo"; 

  svitoglyad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFlgX1+zwpo2COsQJF5NIUC5f/NAt17W8Bzoyo3Pj64K";
  # mriya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBR1Pcfk8DC+iT+vaZDFS7QGwILpDQk/DwvVYVlpful";
in
{
  "hosts/legion5/secrets/root-password.age".publicKeys = [ legion5 alva ];
  "hosts/svitoglyad/secrets/root-password.age".publicKeys = [ svitoglyad ]; # temporaly removed

  "users/alva/secrets/password.age".publicKeys = [ legion5 alva ];
  "users/mriya/secrets/password.age".publicKeys = [ svitoglyad ]; # temporaly removed mriya

  "shared/networks.age".publicKeys = [ alva ]; # same
}

# Generate keys
# sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" - host's ssh key pair
# ssh-keygen -t ed25519 - user's ssh key pair
