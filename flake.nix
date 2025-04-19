{
  # Find /dev/input/eventX for trackpad://linuxtouchpad.org/docs/):
  # $ udevadm info /dev/input/event* | grep -E '(DEVNAME|TOUCHPAD)'
  # E: DEVNAME=/dev/input/event0
  # E: DEVNAME=/dev/input/event1
  # E: DEVNAME=/dev/input/event2
  # E: DEVNAME=/dev/input/event3 # event3 is trackpad.
  # E: ID_INPUT_TOUCHPAD=1
  # E: DEVNAME=/dev/input/event4
  # E: DEVNAME=/dev/input/event5

  description =
    "Trackpad Is Too Damn Big (TITDB) is a utility designed to customize trackpad behavior on Linux.";
  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; };
  nixConfig.bash-prompt-suffix = "[titdb]: "; # shows when inside of nix shell

  outputs = { self, nixpkgs }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64_linux"
      ];
    in {
      packages = forEachSystem (system:
        let pkgs = inputs.nixpkgs.legacyPackages.${system};
        in rec {
          default = titdb;

          titdb = pkgs.stdenv.mkDerivation {
            pname = "titdb";
            version = "0.1";
            # src = pkgs.lib.cleanSource ./.; # Not suitable as need to fetch submodules.
            src = pkgs.fetchgit {
              url = "https://github.com/tascvh/trackpad-is-too-damn-big";
              rev = "78e3e47301d0efb322645bbc7fcf4d4732bd5d7a";
              sha256 = "sha256-3KDzCpRDhuoxkj0wx759hwaK0kBG+6jS3/pY1/kdn6U=";
              # lib.fakeSha256;
              fetchSubmodules = true;
            };

            meta = {
              description =
                "Trackpad Is Too Damn Big (TITDB) is a utility designed to customize trackpad behavior on Linux.";
              homepage = "https://github.com/tascvh/trackpad-is-too-damn-big";
              license = pkgs.lib.licenses.mit;
              maintainers = [ ];
            };

            extraPackages = with pkgs; [ libevdev ];
            nativeBuildInputs = with pkgs; [ pkg-config cmake libevdev ];
            buildPhase = ''
              cmake .
              make
            '';
            installPhase = ''
              mkdir -p $out/bin
              mv ./titdb $out/bin
            '';
          };
        });

      # TODO: Fetch submodules for devshells
      devShells.default = forEachSystem (system:
        let pkgs = inputs.nixpkgs.legacyPackages.${system};
        in {
          default = nixpkgs.mkShell {
            name = "titdb";

            inputsFrom = [ self.packages.${system}.titdb ];

            buildInputs = with pkgs; [ pkg-config cmake libevdev ];
            packages = with pkgs; [ libevdev ];

          };
        });

    };
}
