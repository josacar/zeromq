require "zeromq"
require "json"
require "big"

module Zeromq::Server
  VERSION = "0.1.0"
  NotImplementedError < Exception

  def self.ack(m, n)
    if m == 0
      n + 1
    elsif n == 0
      ack(m-1, 1)
    else
      ack(m-1, ack(m, n-1))
    end
  end

  def self.fib(n) : Int32
    if n < 2
      n.to_i32
    else
      fib(n-1) + fib(n-2)
    end
  end

  def self.fac(n) : BigInt
    (BigInt.new(1)..BigInt.new(n)).product
  end

  def self.start
    context = ZMQ::Context.new
    server = context.socket(ZMQ::REP)
    server.bind("tcp://127.0.0.1:6666")


    loop do
      request = ""
      request = server.receive_string

      puts "Received request. Data: #{request.inspect}"
      req_json = JSON.parse(request)
      req_fn = req_json["fn"]

      if req_fn == "fib"
        server.send_string(fib(req_json["n"].as_i).to_s)
      elsif req_fn == "fac"
        server.send_string(fac(req_json["n"].as_i).to_s)
      elsif req_fn == "ack"
        server.send_string(ack(req_json["m"].as_i, req_json["n"].as_i).to_s)
      else
        raise NotImplementedError.new("wadus")
      end
    end
  end
end

Zeromq::Server.start
