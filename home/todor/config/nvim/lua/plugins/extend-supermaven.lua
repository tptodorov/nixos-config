return {
  {
    {
      "supermaven-inc/supermaven-nvim",
      config = function()
        require("supermaven-nvim").setup({
          keymaps = {
            accept_suggestion = "<Tab>",
            reject_suggestion = "<C-q>",
            clear_suggestion = "<C-]>",
            accept_word = "<C-j>",
          },
        })
      end,
    },
  },
}
