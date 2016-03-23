{:capture} = require "command"

->
  acpi = capture("acpi -b")\split('\n')
  batt = ([line for line in *acpi when line\match '^Battery'])[1]
  return unless batt
  status = batt\match ':%s(%a+),'
  status = status\lower!
  percent = tonumber batt\match(',%s(%d+)%%')
  time_remaining = batt\match ',%s(%d+:%d+):%d+%s%a+'
  {:status, :percent, :time_remaining}
