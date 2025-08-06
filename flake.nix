{
	description = "Personal Website";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

		utils.url = "github:numtide/flake-utils";

		hugo-poison-theme = {
			url = "github:lukeorth/poison";
			flake = false;
		};
	};

	outputs = { self, nixpkgs, utils, hugo-poison-theme, ...}:
	utils.lib.eachDefaultSystem (system:
	let
		pkgs = import nixpkgs {
			inherit system;
		};
	in {
		packages = rec {
			published = pkgs.stdenv.mkDerivation {
				name = "taugoust.com";
				src = self;

				buildPhase = ''
					mkdir -p themes/poison
					cp -r ${hugo-poison-theme}/* themes/poison
					${pkgs.hugo}/bin/hugo
				'';

				installPhase = "cp -r public $out";
			};

			drafts = published.overrideAttrs (old: {
				buildPath = ''
					mkdir -p themes/poison
					cp -r ${hugo-poison-theme}/* themes/poison
					${pkgs.hugo}/bin/hugo -D
				'';
			});

			default = published;
		};

		apps.default = utils.lib.mkApp {
			drv = pkgs.hugo;
		};

		devShells.default = pkgs.mkShell {
			buildInputs = [ pkgs.hugo ];
		};
	});
}

