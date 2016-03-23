default_sink = ""
round = math.round
{:capture, :execute_sync} = require "command"

update = (pulse) ->
  out = capture "pacmd dump"
  default_sink = out\match 'set%-default%-sink ([^\n]+)'
  return false unless default_sink
  pulse.default_sink = default_sink
  for sink, value in out\gmatch 'set%-sink%-volume ([^%s]+) (0x%x+)'
    if sink == default_sink
      pulse.volume = tonumber(value) / 65536
  for sink, value in out\gmatch 'set%-sink%-mute ([^%s]+) (%a+)'
    if sink == default_sink
      pulse.mute = value == "yes"

volume = (pulse, vol) ->
  if vol > 1
    vol = 1
  if vol < 0
    vol = 0
  vol = round vol * 65536
  execute_sync "pacmd set-sink-volume #{default_sink} #{vol}"

toggle_mute = (pulse) ->
  if pulse.mute
    execute_sync "pacmd set-sink-mute #{default_sink} 0"
  else
    execute_sync "pacmd set-sink-mute #{default_sink} 1"

->
  pulse = {}
  {
    volume: (v) -> volume pulse, v
    toggle_mute: -> toggle_mute pulse
    update: -> update pulse
    info: pulse
  }
