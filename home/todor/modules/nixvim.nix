# home/todor/modules/nixvim.nix
{
  imports = [
    ./nixvim/globals.nix
    ./nixvim/opts.nix
    ./nixvim/keymaps.nix
    ./nixvim/plugins.nix
    ./nixvim/colorscheme.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraConfigLua = ''
      vim.opt.fillchars = { eob = " " }
    '';
  };
}