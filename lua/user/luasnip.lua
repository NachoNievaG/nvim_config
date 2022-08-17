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

local snippet = ls.s
local snippet_from_nodes = ls.sn
local fmt = require("luasnip.extras.fmt").fmt
local d = ls.dynamic_node
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


local shortcut = function(val)
  if type(val) == "string" then
    return { t { val }, i(0) }
  end

  if type(val) == "table" then
    for k, v in ipairs(val) do
      if type(v) == "string" then
        val[k] = t { v }
      end
    end
  end

  return val
end

local make = function(tbl)
  local result = {}
  for k, v in pairs(tbl) do
    table.insert(result, (snippet({ trig = k, desc = v.desc }, shortcut(v))))
  end

  return result
end


-- Treesitter
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
--

local transform = function(text, info)
  if text == "int" then
    return t "0"
  elseif text == "error" then
    if info then
      info.index = info.index + 1

      return c(info.index, {
        t(string.format('fmt.Errorf("%s", %s)', info.func_name, info.err_name)),
        t(info.err_name),
      })
    else
      return t "err"
    end
  elseif text == "bool" then
    return t "false"
  elseif text == "string" then
    return t '""'
  elseif string.find(text, "*", 1, true) then
    return t "nil"
  end

  return t(text .. "{}")
end

local handlers = {
  ["parameter_list"] = function(node, info)
    local result = {}

    local count = node:named_child_count()
    for idx = 0, count - 1 do
      table.insert(result, transform(get_node_text(node:named_child(idx), 0), info))
      if idx ~= count - 1 then
        table.insert(result, t { ", " })
      end
    end

    return result
  end,

  ["type_identifier"] = function(node, info)
    local text = get_node_text(node, 0)
    return { transform(text, info) }
  end,
}

local function go_result_type(info)
  local cursor_node = ts_utils.get_node_at_cursor()
  local scope = ts_locals.get_scope_tree(cursor_node, 0)

  local function_node
  for _, v in ipairs(scope) do
    if v:type() == "function_declaration" or v:type() == "method_declaration" or v:type() == "func_literal" then
      function_node = v
      break
    end
  end

  local query = vim.treesitter.get_query("go", "LuaSnip_Result")
  for _, node in query:iter_captures(function_node, 0) do
    if handlers[node:type()] then
      return handlers[node:type()](node, info)
    end
  end
end

local go_ret_vals = function(args)
  return snippet_from_nodes(
    nil,
    go_result_type {
      index = 0,
      err_name = args[1][1],
      func_name = args[2][1],
    }
  )
end


--

-- <c-l> is my expansion key
-- this will expand the current item or jump to the next item within the snippet.
vim.keymap.set({ "i", "s" }, "<c-l>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<c-;>", function()
  if ls.choice_active() then
    ls.change_choice(1)
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
    snippet("wow", fmt("[[example:{},function:{}]]", { i(1), same(1) })),
    -- trigger, content
    snippet("curtime", f(function()
      return os.date "%D - %H:%M"
    end)
    ),
    snippet("choice", c(1, { t "hello", t "world", t "last" }))
  },
  lua = {
    snippet(
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

ls.add_snippets(
  "go",
  make {
    main = {
      t { "func main() {", "\t" },
      i(0),
      t { "", "}" },
    },

    ef = {
      i(1, { "val" }),
      t ", err := ",
      i(2, { "f" }),
      t "(",
      i(3),
      t ")",
      i(0),
    },

    efi = {
      i(1, { "val" }),
      ", ",
      i(2, { "err" }),
      " := ",
      i(3, { "f" }),
      "(",
      i(4),
      ")",
      t { "", "if " },
      same(2),
      t { " != nil {", "\treturn " },
      d(5, go_ret_vals, { 2, 3 }),
      t { "", "}" },
      i(0),
    },

    -- TODO: Fix this up so that it actually uses the tree sitter thing
    ie = { "if err != nil {", "\treturn err", i(0), "}" },
  }
)
ls.add_snippets("go", {
  snippet("f", fmt("func {}({}) {} {{\n\t{}\n}}", { i(1, "name"), i(2), i(3), i(0) })),
})
