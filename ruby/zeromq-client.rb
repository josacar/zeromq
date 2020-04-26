# require 'bundler/inline'
require 'bundler/setup'

# gemfile do
#   source 'https://rubygems.org'

#   gem 'ffi-rzmq'
# end

require 'ffi-rzmq'
require 'json'
require 'benchmark'

context_crystal = ZMQ::Context.new

puts "Connecting to the AckFibFac Crystal Server..."
requester_crystal = context_crystal.socket(ZMQ::REQ)
requester_crystal.connect("tcp://localhost:6666")

context_ruby = ZMQ::Context.new

puts "Connecting to the AckFibFac Ruby Server..."
requester_ruby = context_ruby.socket(ZMQ::REQ)
requester_ruby.connect("tcp://localhost:5555")

loop do
  n = rand(4) + 1
  m = rand(4) + 1
  request = {fn: "ack", m: m, n: n}

  reply = ''
  elapsed_crystal = Benchmark.realtime do
    puts "Crystal: Computing #{request[:fn]}(#{m})(#{n})"
    requester_crystal.send_string request.to_json

    requester_crystal.recv_string(reply)
  end

  puts "Crystal (#{elapsed_crystal}): #{request[:fn]}(#{m})(#{n}): #{reply}"

  reply = ''
  elapsed_ruby = Benchmark.realtime do
    puts "Ruby: Computing #{request[:fn]}(#{m})(#{n})"
    requester_ruby.send_string request.to_json

    requester_ruby.recv_string(reply)
  end
  puts "Ruby (#{elapsed_ruby}): #{request[:fn]}(#{m})(#{n}): #{reply}"

  sleep 1
end
