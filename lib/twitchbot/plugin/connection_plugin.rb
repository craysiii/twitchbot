require_relative '../plugin'

module Twitchbot
  # Plugin to handle any PING messages from the server and keep the connection
  # alive
  class ConnectionPlugin
    include Twitchbot::Plugin

    # Display to the user that the connection has been opened
    def open(handler)
      puts '! Connection established' if handler.bot.debug
    end

    # Display to the user any messages that have been received as well as Listen
    # for any PING messages and respond with PONG
    #
    #   > PING :tmi.twitch.tv
    def message(handler)
      if handler.bot.debug
        handler.messages.each do |line|
          puts "> #{line.raw}"
        end
      end

      handler.send_raw('PONG :tmi.twitch.tv') if handler.message.ping?
    end

    # Display to the user that the connection has encountered an error
    def error(handler)
      puts '! Error occurred' if handler.bot.debug
    end

    # Display to the user that the connection has been closed and return failure
    def close(handler)
      puts '! Connection closed' if handler.bot.debug
      exit false
    end
  end
end
