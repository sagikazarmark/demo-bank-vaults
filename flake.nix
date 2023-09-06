{
  description = "Demo: Bank-Vaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devenv.url = "github:cachix/devenv";
    garden.url = "github:sagikazarmark/nix-garden";
    garden.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devenv.shells.default = {
          packages = with pkgs; [
            kind
            kubectl
            kustomize
            kubernetes-helm

            vault
          ] ++ [
            inputs'.garden.packages.garden
          ];

          env = {
            KUBECONFIG = "${config.devenv.shells.default.env.DEVENV_STATE}/kube/config";
            KIND_CLUSTER_NAME = "demo-bank-vaults";

            HELM_CACHE_HOME = "${config.devenv.shells.default.env.DEVENV_STATE}/helm/cache";
            HELM_CONFIG_HOME = "${config.devenv.shells.default.env.DEVENV_STATE}/helm/config";
            HELM_DATA_HOME = "${config.devenv.shells.default.env.DEVENV_STATE}/helm/data";
          };

          # https://github.com/cachix/devenv/issues/528#issuecomment-1556108767
          containers = pkgs.lib.mkForce { };
        };
      };
    };
}
