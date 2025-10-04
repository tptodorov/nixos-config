# home/todor/modules/nixvim/keymaps.nix
{
  keymaps = [
    # General keymaps
    {
      mode = "i";
      key = "jk";
      action = "<ESC>";
      options = {
        desc = "Exit insert mode with jk";
      };
    }
    {
      mode = "n";
      key = "<leader>nh";
      action = ":nohl<CR>";
      options = {
        desc = "Clear search highlights";
      };
    }

    # Increment/decrement numbers
    {
      mode = "n";
      key = "<leader>+";
      action = "<C-a>";
      options = {
        desc = "Increment number";
      };
    }
    {
      mode = "n";
      key = "<leader>-";
      action = "<C-x>";
      options = {
        desc = "Decrement number";
      };
    }

    # Window management
    {
      mode = "n";
      key = "<leader>sv";
      action = "<C-w>v";
      options = {
        desc = "Split window vertically";
      };
    }
    {
      mode = "n";
      key = "<leader>sh";
      action = "<C-w>s";
      options = {
        desc = "Split window horizontally";
      };
    }
    {
      mode = "n";
      key = "<leader>se";
      action = "<C-w>=";
      options = {
        desc = "Make splits equal size";
      };
    }
    {
      mode = "n";
      key = "<leader>sx";
      action = "<cmd>close<CR>";
      options = {
        desc = "Close current split";
      };
    }

    # Tab management
    {
      mode = "n";
      key = "<leader>to";
      action = "<cmd>tabnew<CR>";
      options = {
        desc = "Open new tab";
      };
    }
    {
      mode = "n";
      key = "<leader>tx";
      action = "<cmd>tabclose<CR>";
      options = {
        desc = "Close current tab";
      };
    }
    {
      mode = "n";
      key = "<leader>tn";
      action = "<cmd>tabn<CR>";
      options = {
        desc = "Go to next tab";
      };
    }
    {
      mode = "n";
      key = "<leader>tp";
      action = "<cmd>tabp<CR>";
      options = {
        desc = "Go to previous tab";
      };
    }
  ];
}