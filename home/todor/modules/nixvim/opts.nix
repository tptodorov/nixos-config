# home/todor/modules/nixvim/opts.nix
{
  opts = {
    # Line numbers
    number = true;
    relativenumber = true;

    # Tabs and indentation
    tabstop = 2;
    shiftwidth = 2;
    expandtab = true;
    autoindent = true;

    # Line wrapping
    wrap = false;

    # Search settings
    ignorecase = true;
    smartcase = true;

    # Cursor line
    cursorline = true;

    # Appearance
    termguicolors = true;
    background = "dark";
    signcolumn = "yes";

    # Backspace
    backspace = "indent,eol,start";

    # Clipboard
    clipboard = "unnamedplus";

    # Split windows
    splitright = true;
    splitbelow = true;

    # Mouse
    mouse = "a";

    # File handling
    swapfile = false;
    backup = false;
    undofile = true;
  };
}