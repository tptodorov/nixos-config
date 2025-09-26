return {
  {
    "stevanmilic/neotest-scala",
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "stevanmilic/neotest-scala",
    },
    opts = {
      adapters = {
        --   ["neotest-golang"] = {
        --     go_test_args = { "-v", "-race", "-count=1", "-timeout=60s" },
        --     dap_go_enabled = true,
        --   },
        ["stevanmilic/neotest-scala"] = {
          -- Command line arguments for runner
          -- Can also be a function to return dynamic values
          args = { "--no-color" },
          -- Runner to use. Will use bloop by default.
          -- Can be a function to return dynamic value.
          -- For backwards compatibility, it also tries to read the vim-test scala config.
          -- Possibly values bloop|sbt.
          runner = "bloop",
          -- Test framework to use. Will use utest by default.
          -- Can be a function to return dynamic value.
          -- Possibly values utest|munit|scalatest.
          framework = "utest",
        },
      },
    },
  },
}
