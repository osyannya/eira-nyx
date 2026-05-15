{ config, lib, pkgs, ... }:

let
  cfg = config.eira.system.users.dynamicUsers;
  hmEnabled = config.eira.system.features.home-manager.enable;

  # Themes
  styleEnabled = config.eira.system.features.stylix.enable or false;
  defaultTheme = config.eira.system.features.stylix.defaultTheme or "dracula";

  # Fallback layout
  defaultKeyboard = "us";

  # Read and parse the JSON if the dynamic engine is enabled
  registry = if cfg.enable 
    then builtins.fromJSON (builtins.readFile ../../../secrets/users.json) 
    else {};

  # Find all users in the registry that possess any of the activeTags
  usersWithTags = lib.filterAttrs (name: data:
    lib.any (tag: builtins.elem tag cfg.activeTags) (data.tags or [])
  ) registry;

  taggedUserNames = builtins.attrNames usersWithTags;

  # Combine Explicit Users and Tagged Users, remove duplicates
  masterUserList = builtins.filter (u: u != "mriya") (lib.unique (taggedUserNames ++ cfg.activeUsers));

in {
  options.eira.system.users.dynamicUsers = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the data-driven dynamic user generation engine.";
    };

    activeTags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of Team Tags authorized to exist on this machine.";
    };

    activeUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of explicit Usernames authorized to exist on this machine.";
    };
  };

  config = lib.mkIf cfg.enable {
    
    # BASE ACCOUNT PROVISIONING
    users.users = lib.genAttrs masterUserList (userName: 
      let
        userData = registry.${userName} or (throw "User '${userName}' requested by host but not found in users.json!");
      in {
        isNormalUser = true;
        uid = userData.uid;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = userData.sshKeys;
        hashedPasswordFile = lib.mkIf (
          (userData.hasSopsPassword or false) && (config.eira.system.security.sops.enable or false)
        ) config.sops.secrets."passwords/${userName}".path;
      }
    );

    sops.secrets = lib.mkIf config.eira.system.security.sops.enable (
      lib.genAttrs 
        (builtins.filter (userName: (registry.${userName} or {}).hasSopsPassword or false) masterUserList) 
        (userName: { neededForUsers = true; })
    );

    # Home manager intersection
    home-manager.users = lib.mkIf hmEnabled (
      lib.genAttrs masterUserList (userName:
        let
          userData = registry.${userName} or {};

          prefs = userData.preferences or {};
          userTheme = prefs.theme or defaultTheme;
          userKeyboard = prefs.keyboard or defaultKeyboard;
        in
          # Build dotfiles if the user has a designated hmProfile in the JSON
          lib.mkIf ((userData.hmProfile or null) != null) { 
            # Dynamically import a specific template
            imports = [ ../../../profiles/users/${userData.hmProfile} ];

            home = {
              username = userName;
              homeDirectory = "/home/${userName}";
            };

            # Inject JSON data directly into the HM state
            programs.git = {
              userName = userData.fullName;
              userEmail = userData.email;
            };

            # Themes per user
            stylix = lib.mkIf styleEnabled {
              base16Scheme = "${pkgs.base16-schemes}/share/themes/${userTheme}.yaml";
            };

            # Keyboard layout for sway
            eira.home.desktop.sway = {
              keyboardLayout = userKeyboard;
            };
          }
      )
    );
  };
}
