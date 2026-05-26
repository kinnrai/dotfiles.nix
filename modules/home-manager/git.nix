{ userHome, ... }:

let
  userName = "kinnrai";
  userEmail = "me@kinnrai.com";
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGFYbXgap+CmxxYRjrV8VEEkTSyTKCoNgkAYDojQbdS personal";
in
{
  programs.git = {
    enable = true;

    signing = {
      key = signingKey;
      format = "ssh";
    };

    ignores = [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"

      # Linux
      "*~"
      ".fuse_hidden*"

      # Windows
      "Thumbs.db"
      "Desktop.ini"
      "$RECYCLE.BIN/"

      # used for local config
      ".env.local"
      "mise.local.toml"
    ];

    settings = {
      user = {
        name = userName;
        email = userEmail;
      };

      gpg.ssh.allowedSignersFile = "${userHome}/.ssh/allowed_signers";

      commit = {
        gpgSign = true;
        verbose = true;
      };

      pull.rebase = true;

      init.defaultBranch = "master";

      push.autoSetupRemote =true;
    };
  };
}
