let
  mediaRules = [
    {
      mime = "{audio,video,image}/*";
      run = "mediainfo";
    }
    {
      mime = "application/{subrip,x-subrip}";
      run = "mediainfo";
    }
    {
      url = "*.{srt,ass,ssa,vtt}";
      run = "mediainfo";
    }
  ];

  gitFetchers = [
    {
      url = "*";
      run = "git";
      group = "git";
    }
    {
      url = "*/";
      run = "git";
      group = "git";
    }
  ];

in
{
  mgr.show_hidden = true;

  preview = {
    image_delay = 0;
    max_width = 1000;
    max_height = 1000;
  };

  plugin = {
    prepend_fetchers = gitFetchers;

    prepend_preloaders = mediaRules;

    prepend_previewers =
      mediaRules
      ++ [
        {
          url = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=$t "$1"'';
        }
        {
          url = "*/";
          run = ''piper -- eza -TL=2 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
        }
      ];
  };
}
