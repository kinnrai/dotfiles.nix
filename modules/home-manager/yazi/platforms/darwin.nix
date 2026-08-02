{ pkgs }:

{
  extraPackages = [ ];

  fetchers = [
    {
      url = "*";
      run = "mactag";
      group = "mactag";
    }
    {
      url = "*/";
      run = "mactag";
      group = "mactag";
    }
  ];

  keymap = [
    {
      on = "<C-p>";
      run = "shell -- qlmanage -p %s";
      desc = "Preview selected files with Quick Look";
    }
    {
      on = [
        "b"
        "a"
      ];
      run = "plugin mactag-actions add";
      desc = "Tag selected files";
    }
    {
      on = [
        "b"
        "r"
      ];
      run = "plugin mactag-actions remove";
      desc = "Untag selected files";
    }
  ];

  plugins.mactag = {
    package = pkgs.yaziPlugins.mactag;
    setup = true;
    settings = {
      keys = {
        r = "Red";
        o = "Orange";
        y = "Yellow";
        g = "Green";
        b = "Blue";
        p = "Purple";
      };
      colors = {
        Red = "#ee7b70";
        Orange = "#f5bd5c";
        Yellow = "#fbe764";
        Green = "#91fc87";
        Blue = "#5fa3f8";
        Purple = "#cb88f8";
      };
      order = 500;
    };
  };

  plugins.mactag-actions = pkgs.writeTextDir "main.lua" (builtins.readFile ../lua/mactag-actions.lua);
}
