{:capture} = require "command"

(root) ->
  df = capture("df -h -P -l #{root}")\split("\n")[2]
  usage = df\gsub("%s+", " ")\split(" ")
  _, _, _, avail, use = unpack usage
  avail, tonumber(use\match("%d+"))

