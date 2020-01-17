require 'faye'
require 'faye/redis'

require File.expand_path('../config/initializers/faye.rb',__FILE__)
Faye::WebSocket.load_adapter('thin')

class ServerAuth
  def incoming(message, callback)
    # Let non-subscribe messages through
    if message['channel'] !~ %r{^/meta/}
    	if message['ext']['auth_token'] != FAYE_TOKEN
    		message['error'] = 'Invalid subscription authentication token'
    	end
    end
    callback.call(message)
  end
end

# faye_server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 45)

faye_server = Faye::RackAdapter.new(
  :mount   => '/faye',
  :timeout => 20,
  :engine  => {
    :type  => Faye::Redis,
    :host  => '127.0.0.1',
    :port  => 6379
  }
)

faye_server.add_extension(ServerAuth.new)
run faye_server
