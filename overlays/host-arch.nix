# Bind the shared helper to a host's architecture without changing stdenv.
arch: _: _: {
  optimizeForArch = args: import ../lib/optimize-for-arch.nix ({ inherit arch; } // args);
}
