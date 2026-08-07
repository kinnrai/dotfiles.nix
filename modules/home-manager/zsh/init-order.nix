{ lib }:

# Keep custom Zsh initialization phases relative to Home Manager's generated
# .zshrc stages. Smaller values run earlier; the module-system default is 1000.
# Home Manager currently initializes completion at 570, ordinary plugins at
# 900, history at 910, and syntax highlighting at 1200. Recheck these anchors
# when updating Home Manager rather than relying on module import order.
{
  # Configure completion immediately before Home Manager runs compinit (570).
  completionStyles = lib.mkOrder 550;

  # Install completion frontends after compinit and before Home Manager loads
  # zsh-autosuggestions (700); fzf-tab must wrap the Fzf widgets last.
  fzfWidgets = lib.mkOrder 580;
  completionOverrides = lib.mkOrder 590;
  fzfTab = lib.mkOrder 600;
  editingFixups = lib.mkOrder 610;

  # Extend plugins after ordinary plugins (900) and history setup (910).
  autosuggestionExtensions = lib.mkOrder 920;

  # Environment integrations use the general 1000 phase. Run dynamic
  # completion discovery afterwards, then finalize suggestions before syntax
  # highlighting wraps all widgets (1200).
  completionSync = lib.mkOrder 1180;
  autosuggestionStrategy = lib.mkOrder 1190;
}
