{:floor} = math
uv = require "uv"

math.round = (num, dp) ->
  m = 10 ^ (dp or 0)
  floor( num * m + 0.5 ) / m

pattern_escapes = {
  "(": "%(",
  ")": "%)",
  ".": "%.",
  "%": "%%",
  "+": "%+",
  "-": "%-",
  "*": "%*",
  "?": "%?",
  "[": "%[",
  "]": "%]",
  "^": "%^",
  "$": "%$",
  "\0": "%z"
}

escape_pattern = (str) -> str\gsub(".", pattern_escapes)

string.split = (str, delim) ->
  return {} if str == ""
  str ..= delim
  delim = escape_pattern(delim)
  [m for m in str\gmatch("(.-)"..delim)]

string.trim = (str) ->
  (str\gsub("^%s*(.-)%s*$", "%1"))

table.index_of = (t, v) ->
  for i = 1, #t
    return i if t[i] == v
  nil

table.merge = (t1, t2) ->
  res = {k, v for k, v in pairs t1}
  for k, v in pairs t2
    res[k] = v
  res

table.empty = (t) ->
  unless next(t)
    return true
  false

export *

sleep = (ms) ->
  thread, main = coroutine.running!
  assert not main, "Error cannot suspend main thread"
  t = uv.new_timer!
  uv.timer_start t, ms, 0, -> coroutine.resume thread
  coroutine.yield!
