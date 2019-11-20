require_relative '../plugin'

module Twitchbot
  # Plugin to handle any PING messages from the server and keep the connection
  # alive
  class PingPlugin
    include Twitchbot::Plugin

    # Listen for any PING messages and respond with PONG
    #
    #   > PING :tmi.twitch.tv
    def message(handler)
      handler.send_raw('PONG :tmi.twitch.tv') if handler.message.ping?
    end
  end
end
