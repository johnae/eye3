uv = require "uv"
{:capture, :execute, :execute_sync} = require "command"

blocks = {}
named_blocks = {}

data_block = (block) ->
  color = block.color
  label = block.label
  name = block.name
  separator_block_width = block.separator_block_width
  full_text = "#{label}#{block.text}"
  {:color, :label, :full_text, :name, :separator_block_width, short_text: block.text}

new_block = (name, setup) ->
  block_conf = {label: "", color: "#FFFFFF", text: "", :name, separator_block_width: 15}
  block = setmetatable block_conf, __call: (block, name, setup) ->
    env = setmetatable {
      :execute
      :execute_sync
      :capture
      label: (lbl) ->
        if lbl
          block_conf.label = lbl
        block_conf.label
      color: (clr) ->
        if clr
          block_conf.color = clr
        block_conf.color
      text: (txt) ->
        if txt
          block_conf.text = txt
        block_conf.text
      separator_block_width: (sbw) ->
        sbw = assert tonumber(sbw), "separator_block_width must be a number"
        if sbw
          block_conf.separator_block_width = sbw
        block_conf.separator_block_width
    }, __index: _G

    event_handler = (f) ->
      setfenv f, env
      -> coroutine.wrap(f)!

    block_conf.updater = -> nil
    block_conf.left_click = -> nil
    block_conf.middle_click = -> nil
    block_conf.right_click = -> nil
    block_conf.scroll_up = -> nil
    block_conf.scroll_down = -> nil
    block_conf._interval = nil

    setup_env = setmetatable {
      interval: (iv) -> block_conf._interval = iv,
      on_update: (f) -> block_conf.updater = event_handler(f)
      on_left_click: (f) -> block_conf.left_click = event_handler(f)
      on_middle_click: (f) -> block_conf.middle_click = event_handler(f)
      on_right_click: (f) -> block_conf.right_click = event_handler(f)
      on_scroll_up: (f) -> block_conf.scroll_up = event_handler(f)
      on_scroll_down: (f) -> block_conf.scroll_down = event_handler(f)
    }, __index: env
    setfenv setup, setup_env
    setup!

    if block_conf._interval
      t = uv.new_timer!
      uv.timer_start t, block_conf._interval, block_conf._interval, block.updater
    block_conf.updater!

    blocks[#blocks + 1] = block
    named_blocks[name] = block

  block name, setup

block: new_block, :named_blocks, :blocks, :data_block
