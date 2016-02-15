$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require "cangkul"
server = Cangkul::Server.new
server.run
