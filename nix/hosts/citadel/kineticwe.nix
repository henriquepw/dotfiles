{ inputs, pkgs, ... }:
{
  # Sessão "KineticWE" (kwin-we + shell Noctalia) selecionável no ly, ao lado do
  # KDE. nixosModules.default aplica a overlay aditiva (kineticwe/kwin-we/
  # noctalia) e registra a sessão Wayland. O KDE segue default e intocado.
  imports = [ inputs.kineticwe.nixosModules.default ];

  programs.kineticwe.enable = true;

  # O launcher da sessão (start-kineticwe) é baked no flake: ele faz `exec noctalia`
  # como processo foreground do compositor e NÃO ativa graphical-session.target.
  # Por isso o vicinae.service (WantedBy=graphical-session.target) nunca sobe nessa
  # sessão. Injetamos, logo antes do noctalia, a importação do ambiente wayland pro
  # systemd --user e o start do serviço já configurado (mesmo do KDE). Rodando como
  # filho do compositor, o WAYLAND_DISPLAY existe e o import propaga pro systemd.
  # O `exec noctalia` (payload de startup do compositor) fica em
  # .start-kineticwe-wrapped porque o wrapProgram do pacote roda antes do nosso
  # postInstall e transforma start-kineticwe num wrapper. Patcheamos o script real.
  programs.kineticwe.package = pkgs.kineticwe.overrideAttrs (old: {
    postInstall = (old.postInstall or "") + ''
      substituteInPlace "$out/bin/.start-kineticwe-wrapped" \
        --replace-fail 'exec ${pkgs.noctalia}/bin/noctalia' \
      'systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY 2>/dev/null || true
      systemctl --user start --no-block vicinae.service 2>/dev/null || true
      exec ${pkgs.noctalia}/bin/noctalia'
    '';
  });
}
