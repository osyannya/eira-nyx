let
  legion5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrM4Uwdlat/DoCCNm/HVJNtb15Z2MBhgoauKnFt8dUJ"; # legion5 /etc/ssh/ssh_host_ed25519_key.pub
  alva = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPa1If2ZLO/5SiBpqvgKf7qyuTCXtFJv3VQFF8ShTduo"; # alva ~/.ssh/id_ed25519.pub

  svitoglyad = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKS4qHEbcFCDIKBu9eJNZz01dOkAIoaQTK32Jfu/qXwM"; # svitoglyad
  mriya = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBR1Pcfk8DC+iT+vaZDFS7QGwILpDQk/DwvVYVlpful"; # mriya
in
{
  "hosts/legion5/root-password.age".publicKeys = [ legion5 alva ];
  "hosts/svitoglyad/root-password.age".publicKeys = [ svitoglyad mriya ];

  "users/alva/password.age".publicKeys = [ legion5 alva ];
  "users/mriya/password.age".publicKeys = [ svitoglyad mriya ];

  "shared/networks.age".publicKeys = [ alva mriya ];
}

# sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N "" - host's ssh key pair
# ssh-keygen -t ed25519 - user's ssh key pair
