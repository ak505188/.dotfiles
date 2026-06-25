-- lua/plugins/lint.lua
-- Asynchronous linting via nvim-lint. Drop into your lua/plugins/ directory.
-- nvim-lint runs standalone linters (the ones your LSP servers don't cover)
-- and reports through Neovim's native diagnostics.

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Map filetypes to the linters that should run on them. The linter names
    -- come from :help nvim-lint-available-linters. The binaries must be on
    -- your PATH — install them via Mason (:MasonInstall eslint_d luacheck ...)
    -- or your system package manager.
    lint.linters_by_ft = {
      lua = { "luacheck" },
      python = { "ruff" },
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      markdown = { "markdownlint" },
      json = { "jsonlint" },
      yaml = { "yamllint" },
      dockerfile = { "hadolint" },
    }

    -- Example of customizing a built-in linter's arguments. luacheck's default
    -- config complains about the global `vim`; this whitelists it.
    lint.linters.luacheck.args = {
      "--globals", "vim",
      "--formatter", "plain",
      "--codes",
      "--ranges",
      "-",
    }

    -- Trigger linting on the events that matter. Using a dedicated augroup so
    -- re-sourcing your config doesn't stack duplicate autocmds.
    local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })

    -- Resolve a linter's command to the string Neovim will try to spawn.
    -- A linter's `cmd` may be a plain string or a function returning one.
    local function linter_cmd(name)
      local linter = lint.linters[name]
      if type(linter) == "function" then
        linter = linter()
      end
      if type(linter) ~= "table" then
        return nil
      end
      local cmd = linter.cmd
      if type(cmd) == "function" then
        cmd = cmd()
      end
      return cmd
    end

    -- Run only the linters for this buffer whose binary is actually on PATH.
    -- This is what stops the ENOENT error: try_lint() with no args would try
    -- to spawn every configured linter, including ones you haven't installed.
    local function lint_buffer()
      if not vim.bo.modifiable then
        return
      end

      local names = lint.linters_by_ft[vim.bo.filetype] or {}
      local available = {}
      for _, name in ipairs(names) do
        local cmd = linter_cmd(name)
        if cmd and vim.fn.executable(cmd) == 1 then
          table.insert(available, name)
        end
      end

      if #available > 0 then
        lint.try_lint(available)
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = lint_buffer,
    })

    -- Optional: a manual trigger.
    vim.keymap.set("n", "<leader>l", lint_buffer, { desc = "Lint current buffer" })
  end,
}
