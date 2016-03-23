-- load the core
require "vendor"
require "lib"
require "globals"
lpeg = require "lpeglj"
package.loaded.lpeg = lpeg
require "moonscript"
moonscript = require "moonscript.base"
{:capture, :execute} = require "command"
uv = require "uv"
json = require "json"
{:block, :named_blocks, :blocks, :data_block} = require "block"
{:index_of} = table

-- run whatever specified if provided the -f argument
if fi = index_of arg, "-f"
  file = arg[fi + 1]
  new_args = [a for i, a in ipairs arg when i>(fi + 1)]
  unless file
    log.error "The -f option requires an argument"
    os.exit 1
  _G.arg = new_args
  loaded_chunk = if file\match "[^.]%.lua$"
    assert loadfile(file), "Failed to load file: #{file}"
  else -- assume it's moonscript
    assert moonscript.loadfile(file), "Failed to load file: #{file}"
  loaded_chunk!
  return

encode_json = (v) -> json.encode v, false

stdout = if uv.guess_handle(1) == 'tty'
  tty = uv.new_tty 0, false
  tty
else
  p = uv.new_pipe false
  uv.pipe_open p, 1
  p

stdin = uv.new_tty 0, true

uv.write stdout, '{"version":1,"click_events":true}' .. "\n"
uv.write stdout, "[[]\n"

full_redraw = (blocks) ->
  out = {}
  for block in *blocks
    out[#out + 1] = data_block block
  uv.write stdout, ',' .. encode_json(out) .. "\n"

config_env = setmetatable {:block, :execute, :capture, :execute_sync}, __index: _G
file = _G.arg[1]
config = assert moonscript.loadfile(file), "Failed to to load '#{file}'"
config = setfenv config, config_env
coroutine.wrap(config)!

main = uv.new_timer!
uv.timer_start main, 1000, 1000, ->
  full_redraw blocks

full_redraw blocks

uv.read_start stdin, (err, line) ->
  if err
    return
  if line
    line, replaced = line\gsub "^,", ""
    status, event = pcall -> json.decode(line)
    if status
      block = named_blocks[event.name]
      switch event.button
        when 1
          block.left_click!
          full_redraw blocks
        when 2
          block.middle_click!
          full_redraw blocks
        when 3
          block.right_click!
          full_redraw blocks
        when 4
          block.scroll_up!
          full_redraw blocks
        when 5
          block.scroll_down!
          full_redraw blocks

uv.run!
