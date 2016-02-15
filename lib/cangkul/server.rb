require "socket"
require "optparse"
require "cangkul"
require "json"

module Cangkul
  class Server
    def initialize
      @server   = TCPServer.open(*Config.server.values)
      @game     = Game.new(2, 2)
      @clients  = {}
    end

    def run
      loop do
        Thread.start(@server.accept) do |client|
          id = client.gets.chomp
          @game.add_player(id) do |status, messages|
            status == "ACCEPTED" ? @clients[id] = client : Thread.kill(self)
            distribute(messages)
          end

          loop do
            @game.update do |status, message|
              distribute(message)
            end
            message = client.gets
            execute(id, message.split) do |status, message|
              distribute(message)
            end
          end
        end
      end
    end

    def broadcast(message)
      @clients.each do |id, client|
        client.puts message if yield(id, client)
      end
    end

    def distribute(messages)
      @clients.each do |id, client|
        client.puts(messages[id]) if messages[id]
        client.puts(messages["other"]) if !messages[id] && messages["other"]
        client.puts(messages["all"]) if messages["all"]
      end
    end

    def execute(id, options, &block)
      opt_parser = OptionParser.new do |opts|
        opts.on("-h", "--help", "Print list of available command.") do
          messages = { id => opts }
          block.call("ERROR", messages)
        end
        opts.on("-c", "--cards", "Show your card") do
          @game.see_cards(id, &block)
        end
        opts.on("-s CARD_INDEX", "--summon CARD_INDEX", Integer, "Summon a card from your hand.") do |card_index|
          @game.summon(id, card_index, &block)
        end
        opts.on("-t", "--take", "Take a card from deck.") do
          @game.take_a_card(id, &block)
        end
      end
      opt_parser.parse(options)
    end
  end
end
