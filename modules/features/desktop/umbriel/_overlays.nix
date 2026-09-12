final: prev: {
  # nixpkgs still ships v0.8.2, which closes Steam/GTK popups instantly because
  # override-redirect windows steal focus and get unfocus-closed right away.
  # Fixed upstream in add2795 ("never focus override-redirect popups"), not yet tagged/released.
  # https://github.com/Supreeeme/xwayland-satellite/issues/468
  # https://github.com/noctalia-dev/umbriel/issues/105
  xwayland-satellite = prev.xwayland-satellite.overrideAttrs (
    old:
    let
      version = "0.8.2-unstable-2026-09-09";
      src = final.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xwayland-satellite";
        rev = "add2795134593faafce60e404a0a75df68e9ee0c";
        hash = "sha256-0TxfMgqW0/BLD4M942c5DCKYrtPvzsPJwvdcco4LQUM=";
      };
    in
    {
      inherit version src;
      cargoDeps = final.rustPlatform.fetchCargoVendor {
        inherit src;
        name = "xwayland-satellite-${version}";
        hash = "sha256-s1gl9eR6Mt2QLrhfcowstPFjzwE/lz4PJhJzWYHoIHg=";
      };
    }
  );
}
