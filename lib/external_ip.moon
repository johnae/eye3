--echo -e "GET /raw HTTP/1.0\r\nHost: myexternalip.com\r\n" | nc -q 2 myexternalip.com 80
{:capture} = require "command"

->
  capture("dig TXT +short o-o.myaddr.l.google.com @ns1.google.com")\gsub('"','')\trim!

-- dig TXT +short o-o.myaddr.l.google.com @ns1.google.com

--(ip) ->
--  thread, main = coroutine.running!
--  assert not main, "Cannot suspend main thread"
--  client = uv.new_tcp!
--  uv.tcp_connect client, "78.47.139.102", 80, (err) ->
--    if err
--      coroutine.resume thread, err
--    uv.read_start client, (err, chunk) ->
--      if err
--        coroutine.resume thread, err
--      if chunk
--        lines = chunk\split "\n"
--        uv.shutdown client
--        coroutine.resume thread, lines[#lines-1]
--      else
--        uv.close client
--    uv.write client, "GET /raw HTTP/1.0\r\nHost: myexternalip.com\r\n\r\n"
--  coroutine.yield!
