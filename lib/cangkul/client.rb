require "socket"
require "cangkul"

module Cangkul
  class Client
    def initialize
      @socket = TCPSocket.open(*Config.client.values)
      print "Enter Your ID : "
      @socket.puts "#{gets.chomp}"
    end

    def run
      listener
      sender
      @sender.join
      @listener.join
    end

    def listener
      @listener = Thread.new do
        loop do
          message = @socket.gets
          puts message if message
        end
      end
    end

    def sender
      @sender = Thread.new do
        loop do
          message = gets.chomp
          @socket.puts message
        end
      end
    end
  end
end
