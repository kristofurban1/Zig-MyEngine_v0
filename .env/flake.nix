{
  description = "MachEngine Env with nvim integration, using zigup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { nixpkgs, ... }: 
		let 
			system = "x86_64-linux";
			pkgs = import nixpkgs { inherit system; };
		in 
		{
			devShells.${system}.default = pkgs.mkShell {
				buildInputs = [
					pkgs.zls
					pkgs.vimPlugins.nvim-treesitter-parsers.zig
				];



				shellHook = ''
					bash -c "zigup 0.15.1"

					export NIX_SHELL_NVIM=$PROJECT/.env/nvim.lua
					export NIX_SHELL_TS_ZIG=${pkgs.vimPlugins.nvim-treesitter-parsers.zig}/parser/zig.so
				'';
			};
		};
  
}
