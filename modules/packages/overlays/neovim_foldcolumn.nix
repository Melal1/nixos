self: super: {
  neovim = super.neovim.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./patches/neovim_foldcolumn.patch ];
    patchFlags = ["-p0"];
  });
}

