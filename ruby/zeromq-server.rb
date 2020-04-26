require 'bundler/setup'
require 'ffi-rzmq'
require 'json'

def ack(m, n)
  if m == 0
    n + 1
  elsif n == 0
    ack(m-1, 1)
  else
    ack(m-1, ack(m, n-1))
  end
end

def fib(n)
  if n < 2
    n
  else
    fib(n-1) + fib(n-2)
  end
end

def fac(n)
  (1..n).reduce(1, :*)
end

puts "Starting AckFibFac Server..."

context = ZMQ::Context.new
socket  = context.socket(ZMQ::REP)
socket.bind("tcp://*:5555")

loop do
  request = ''
  socket.recv_string(request)

  puts "Received request. Data: #{request.inspect}"
  req_json = JSON.parse(request)
  req_fn   = req_json["fn"]

  if req_fn == "fib"
    socket.send_string(fib(req_json["n"].to_i).to_s)
  elsif req_fn == "fac"
    socket.send_string(fac(req_json["n"].to_i).to_s)
  elsif req_fn == "ack"
    socket.send_string(ack(req_json["m"].to_i, req_json["n"].to_i).to_s)
  else
    raise NotImplementedError
  end
end
