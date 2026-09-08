final: prev:

# TODO: Remove this overlay once the pinned nixpkgs restores the Linux-only
# guard dropped in 6bf5710 when extracting the Cython hook.
# Darwin ships precompiled extensions and uses a different app bundle layout.
# https://github.com/NixOS/nixpkgs/commit/6bf57108320b814e92d52ff7b19369ae50b86b64
prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
  jetbrains = prev.jetbrains // {
    pycharm = prev.jetbrains.pycharm.overrideAttrs (old: {
      nativeBuildInputs = prev.lib.remove prev.jetbrains.cythonDebugSpeedupsHook old.nativeBuildInputs;
    });
  };
}
