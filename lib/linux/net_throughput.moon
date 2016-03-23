{:rshift} = require "bit"
{:round} = math
S = require "syscall"
nl = S.nl
C = require "syscall.linux.constants"
{:UNIVERSE} = C.RT_SCOPE

interfaces = ->
  ifaces = nl.getlink!
  routes = nl.routes "inet", "unspec"
  default = ([route for route in *routes when route.rtmsg.rtm_scope == UNIVERSE])[1]
  default_output = nil
  if default
    default_output = default.output
  ifaces, default_output

interface_stats = (iface) ->
  return unless iface and iface.stats
  return iface.stats.rx_bytes, iface.stats.tx_bytes

(opts={}) ->
  setmetatable {
    rx: 0,
    tx: 0,
    up: false,
    rx_rate: 0,
    tx_rate: 0,
    receive_rate: 0
    transmit_rate: 0
    rx_unit: "K",
    tx_unit: "K",
    stamp: os.time!,
    error: nil
  }, __call: (tbl) ->
    ifaces, default = interfaces!
    interface = opts.interface or default
    unless interface and ifaces[interface]
      return nil, "No such interface '#{interface}'"

    tbl.rx_unit = "K"
    tbl.tx_unit = "K"
    iface = ifaces[interface]
    {rx: orx,tx: otx, stamp: ostamp} = tbl
    rx, tx = interface_stats iface
    unless rx and tx and orx and otx
      for k,v in pairs(tbl)
        if type(v) == "number"
          tbl[k] = 0
      tbl.up = false

    tbl.up = true
    tbl.rx = rx
    tbl.tx = tx
    stamp = os.time!
    elapsed = stamp - ostamp
    tbl.stamp = stamp
    rx_diff = rx - orx 
    tx_diff = tx - otx
    rx_rate = rx_diff / elapsed
    tx_rate = tx_diff / elapsed
    rx_kib = rshift rx_rate, 10
    tx_kib = rshift tx_rate, 10
    if rx_rate > 1048576
      rx_kib /= 1024
      tbl.rx_unit = "M"
    if tx_rate > 1048576
      tx_kib /= 1024
      tbl.tx_unit = "M"
    r = round rx_kib, 1
    t = round tx_kib, 1
    tbl.interface = interface
    tbl.receive_rate = r
    tbl.transmit_rate = t
    true

  --stats = {}
  --t = uv.new_timer!
  --uv.timer_start t, 1000, 1000, ->
  --  ifaces, default = interfaces!
  --  interface = opts.interface or default
  --  unless interface and ifaces[interface]
  --    return stats, "No such interface"

  --  iface = ifaces[interface]

  --  {rx: orx,tx: otx} = stats
  --  rx, tx = interface_stats iface
  --  stats.rx = rx
  --  stats.tx = tx
  --  unless rx and tx and orx and otx
  --    for k,v in pairs(stats)
  --      if type(v) == "number"
  --        stats[k] = 0
  --    stats.up = false
  --    return
  --  stats.up = true
  --  rx_diff = rx - orx
  --  tx_diff = tx - otx
  --  rx_rate = rx_diff
  --  tx_rate = tx_diff
  --  rx_kib = rshift rx_rate, 10
  --  tx_kib = rshift tx_rate, 10
  --  stats.rx_kib = rx_kib
  --  stats.tx_kib = tx_kib
  --  rlabel = "K"
  --  tlabel = "K"
  --  if rx_rate > 1048576
  --    rx_kib /= 1024
  --    rlabel = "M"
  --  if tx_rate > 1048576
  --    tx_kib /= 1024
  --    tlabel = "M"
  --  r = round rx_kib, 1
  --  t = round tx_kib, 1
  --  stats.interface = interface
  --  stats.receive_rate = "#{r}#{rlabel}"
  --  stats.transmit_rate = "#{t}#{tlabel}"
  --stats
