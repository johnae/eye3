uv = require "uv"
{:round} = math

cpu_stats = ->
  cpus = {}
  for cpu in *uv.cpu_info!
    {:irq, :user, :idle, :sys, :nice} = cpu.times
    non_idle = user+nice+sys+irq
    total = idle+non_idle
    cpus[#cpus + 1] = {:idle, :total}
  cpus

total = 0
idle = 0

-> 
  prev_total, prev_idle = total, idle
  stats = cpu_stats!
  {:total, :idle} = stats[1]
  round(((total-prev_total)-(idle-prev_idle))/(total-prev_total)*100,2)
