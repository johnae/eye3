uv = require "uv"
{:remove} = table

--capture = (cmd, raw) ->
--  f = assert io.popen(cmd, 'r')
--  s = assert f\read '*a'
--  f\close!
--  return s if raw
--  s = s\gsub '^%s+',''
--  s = s\gsub '^%s+$',''
--  s = s\gsub '[\n\r]+',' '
--  s

capture = (cmdline, opts={}) ->
  thread, main = coroutine.running!
  assert not main, "Error can't suspend main thread"
  args = cmdline\split ' '
  cmd = remove args, 1
  stdin = uv.new_pipe false
  stdout = uv.new_pipe false
  unless opts.args
    opts.args = args if args
  unless opts.stdio
    opts.stdio = {stdin, stdout}
  local handle
  handle, _ = uv.spawn cmd, opts, (code, signal) -> uv.close(handle)
  uv.read_start stdout, (err, chunk) ->
    uv.close stdout
    if err
      coroutine.resume thread, err
    else
      coroutine.resume thread, chunk
  uv.shutdown stdin, -> uv.close stdin
  coroutine.yield!

execute_sync = capture

execute = (cmdline, opts={}) ->
  args = cmdline\split ' '
  cmd = remove args, 1
  o = {:args}
  o.args = opts.args if opts.args
  local stdin
  if opts.input
    stdin = uv.new_pipe false
    o.stdio = {stdin}
  local handle
  handle, _ = uv.spawn cmd, o, (code, signal) -> uv.close(handle)
  if opts.input
    uv.write stdin, opts.input
    uv.shutdown stdin, -> uv.close stdin

:capture, :execute, :execute_sync
