local status_ok, ls = pcall(require, "luasnip")
if not status_ok then return end

local types = require "luasnip.util.types"

ls.config.set_config {
  -- This tells LuaSnip to remember to keep around the last snippet.
  -- You can jump back into it even if you move outside of the selection
  history = true,

  -- This one is cool cause if you have dynamic snippets, it updates as you type!
  updateevents = "TextChanged,TextChangedI",

  -- Autosnippets:
  enable_autosnippets = true,

  -- Crazy highlights!!
  -- #vid3
  -- ext_opts = nil,
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { " <- Current Choice", "NonTest" } },
      },
    },
  },
}
local s = ls.s

local fmt = require("luasnip.extras.fmt").fmt

local i = ls.insert_node

local t = ls.text_node
-- local rep = require("luasnip.extras").rep
local c = ls.choice_node
local f = ls.function_node

local same = function(index)
  return f(function(arg)
    return arg[1]
  end, { index })
end

-- <c-l> is my expansion key
-- this will expand the current item or jump to the next item within the snippet.
vim.keymap.set({ "i", "s" }, "<c-l>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  elseif ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

-- <c-j> is my jump backwards key.
-- this always moves to the previous item within the snippet
vim.keymap.set({ "i", "s" }, "<c-b>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

ls.add_snippets(nil, {
  all = {
    s("wow", fmt("[[example:{},function:{}]]", { i(1), same(1) })),
    -- trigger, content
    s("curtime", f(function()
      return os.date "%D - %H:%M"
    end)
    ),
    s("choice", c(1, { t "hello", t "world", t "last" }))
  },
  go = {
    s("main", fmt("func main() {{\n\t{}\n}}", i(1))),
    s("func", fmt(
      [[
      func {}({}) {}{{
        {}
      }}
    ]] ,
      { i(1), i(2), i(3), i(4) })),
    s("test", fmt(
      [[
      func Test{}(t *testing.T) {{
        {}
      }}
    ]] , { i(1), i(2) }))
  },
  lua = {
    s(
      "req",
      fmt([[local {} = require "{}"]], {
        f(function(import_name)
          local parts = vim.split(import_name[1][1], '.', true)
          return parts[#parts] or ""
        end, { 1 }),
        i(1),
      }))
  }
})


-- IMPLEMENT This

local ts_locals = require "nvim-treesitter.locals"
local ts_utils = require "nvim-treesitter.ts_utils"

local get_node_text = vim.treesitter.get_node_text

vim.treesitter.set_query(
  "go",
  "LuaSnip_Result",
  [[ [
    (method_declaration result: (_) @id)
    (function_declaration result: (_) @id)
    (func_literal result: (_) @id)
  ] ]]
)
