local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
  return
end

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }

  if server.name == "jsonls" then
    local jsonls_opts = require("user.lsp.settings.jsonls")
    opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
  end

  if server.name == "tsserver" then
    local tss_opts = require("user.lsp.settings.typescript")
    opts = vim.tbl_deep_extend("force", tss_opts, opts)
  end

  if server.name == "sumneko_lua" then
    local sumneko_opts = require("user.lsp.settings.sumneko_lua")
    opts               = vim.tbl_deep_extend("force", sumneko_opts, opts)
  end

  if server.name == "pyright" then
    local pyright_opts = require("user.lsp.settings.pyright")
    opts = vim.tbl_deep_extend("force", pyright_opts, opts)
  end

  if server.name == "gopls" then
    local gopls = require("user.lsp.settings.gopls")
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      pattern = { "*.go" },
      callback = function()
        gopls.go_org_import(3000)
      end
    })
  end
  server:setup(opts)
end)

-- vim.lsp.buf.formatting_sync is deprecated. Use vim.lsp.buf.format
