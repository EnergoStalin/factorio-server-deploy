{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    shell.url = "path:/home/alexv/Downloads/home-shell-flake.nix";
  };
  outputs = { self, nixpkgs, nixpkgs-unstable, shell }:
    let
      system = "x86_64-linux";
      name = "infrastructure";
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      upkgs = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

      pkg = {
        packages = (with pkgs; [
          terraform
        ]);
      };
    in
    {
      devShells.${system} = {
        energostalin = (shell.mkHomeShell (pkg // {
          inherit name pkgs;

          HOME_SHELL_EXEC = "zsh";
          EDITOR = "nvim";
          VISUAL = "nvim";

          zshrc = (shell.shellInit {
            homeInitHook = ''
              mkdir -p .config .local/share
              lifnot ~/.config/starship.toml .config/starship.toml
              lifnot ~/.local/share/nvim .local/share/nvim
              lifnot ~/.config/nvim .config/nvim
              lifnot ~/.config/yazi .config/yazi
              lifnot ~/.config/kitty .config/kitty
            '';

            workspaceHook = '''';
          });
        }));
      };
    };
}
