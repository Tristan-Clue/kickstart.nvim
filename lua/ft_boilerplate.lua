-- ft_boilerplate.lua
-- Place this file in: ~/.config/nvim/lua/ft_boilerplate.lua
-- Then add to your init.lua:
--   require("ft_boilerplate")
--
-- Keybind: <F1> inserts 42 header (your existing plugin handles this).
--          <F2> inserts the file-type boilerplate (hpp/cpp template).
--          You can also map both to one key — see the combo section below.

local M = {}

-- ─── Helpers ────────────────────────────────────────────────────────────────

--- Returns the filename without extension, e.g. "MyClass" from "MyClass.cpp"
local function get_stem()
  return vim.fn.expand '%:t:r'
end

--- Returns the file extension, e.g. "cpp" from "MyClass.cpp"
local function get_ext()
  return vim.fn.expand '%:e'
end

--- Capitalises every character (used for include guards)
local function upper(s)
  return s:upper()
end

-- ─── HPP Template ───────────────────────────────────────────────────────────

local function hpp_lines(name)
  local U = upper(name)
  return {
    '#ifndef ' .. U .. '_HPP',
    '# define ' .. U .. '_HPP',
    '',
    'class ' .. name,
    '{',
    '\tprivate:',
    '',
    '\tprotected:',
    '',
    '\tpublic:',
    '\t\t' .. name .. '();',
    '\t\t' .. name .. '(const ' .. name .. '& other);',
    '\t\t' .. name .. '&\toperator=(const ' .. name .. '& other);',
    '\t\t~' .. name .. '();',
    '};',
    '',
    '#endif',
  }
end

-- ─── CPP Template ───────────────────────────────────────────────────────────

local function cpp_lines(name)
  return {
    '#include "' .. name .. '.hpp"',
    '',
    '// CATEGORY:\tConstructor / Copy Constructor / Deconstructor',
    '',
    name .. '::' .. name .. '()',
    '{',
    '}',
    '',
    name .. '::' .. name .. '(const ' .. name .. '& other)',
    '{',
    '\t(void)other;',
    '}',
    '',
    name .. '& ' .. name .. '::operator=(const ' .. name .. '& other)',
    '{',
    '\tif (this != &other)',
    '\t{',
    '\t}',
    '\treturn (*this);',
    '}',
    '',
    name .. '::~' .. name .. '()',
    '{',
    '}',
    '',
    '// CATEGORY:\tMember Functions',
    '',
  }
end

-- ─── Core inserter ──────────────────────────────────────────────────────────

--- Inserts lines at the end of the buffer (after header content already there).
local function append_lines(lines)
  local buf = vim.api.nvim_get_current_buf()
  local last = vim.api.nvim_buf_line_count(buf)
  vim.api.nvim_buf_set_lines(buf, last - 1, last, false, lines)
end

-- ─── Public entry point ─────────────────────────────────────────────────────

function M.insert_boilerplate()
  local name = get_stem()
  local ext = get_ext()

  if ext == 'hpp' then
    append_lines(hpp_lines(name))
    print('[ft_boilerplate] HPP template inserted for: ' .. name)
  elseif ext == 'cpp' then
    append_lines(cpp_lines(name))
    print('[ft_boilerplate] CPP template inserted for: ' .. name)
  else
    vim.notify('[ft_boilerplate] Not a .cpp or .hpp file — skipping.', vim.log.levels.WARN)
  end
end

-- ─── Keybind setup ──────────────────────────────────────────────────────────
--
-- Option A — Boilerplate only on <F2>:
-- vim.keymap.set('n', '<F2>', M.insert_boilerplate, {
--  desc = 'Insert 42 cpp/hpp boilerplate',
--  silent = true,
-- })

-- Option B — Combo key: <F1> fires 42 stdheader THEN the boilerplate.
-- Uncomment the block below and remove the <F2> mapping above if you want
-- a single key that does both. Make sure your stdheader plugin is loaded
-- before this file.
--
vim.keymap.set('n', '<F1>', function()
  local ext = get_ext()
  -- Trigger your existing 42 header (adjust the command to whatever
  -- your stdheader plugin exposes, e.g. a lua call or a vim command):
  vim.cmd 'Stdheader' -- if it's a :Stdheader command
  -- vim.fn["stdheader#insert"]()  -- if it's a vimscript function
  if ext == 'hpp' or ext == 'cpp' then
    M.insert_boilerplate()
  end
end, { desc = '42 header + boilerplate', silent = true })

return M
