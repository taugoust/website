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
	in rec {
		packages = rec {
			published = pkgs.stdenv.mkDerivation {
				name = "taugoust.com";
				src = self;

				buildPhase = ''
					mkdir -p themes/poison
					cp -r ${hugo-poison-theme}/. themes/poison
					${pkgs.hugo}/bin/hugo
				'';

				installPhase = ''
					cp -r public $out
					cp -r themes $out
					cp hugo.toml $out
				'';
			};

			drafts = published.overrideAttrs (old: {
				buildPhase = ''
					mkdir -p themes/poison
					cp -r ${hugo-poison-theme}/. themes/poison
					${pkgs.hugo}/bin/hugo -D
				'';
			});

			default = drafts;
		};

		apps.default = utils.lib.mkApp {
			drv = pkgs.writeShellScriptBin "pages" "${pkgs.python312}/bin/python3 -m http.server 8000 -d ${packages.default}";
		};

		devShells.default = pkgs.mkShellNoCC {
			buildInputs = [ pkgs.hugo ];

			# Link theme
			shellHook = ''
				mkdir -p themes
				ln -snf "${hugo-poison-theme}" themes/poison
			'';
		};
	});
}

