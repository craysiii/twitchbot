require_relative '../plugin'

module Twitchbot
  # Plugin to handle displaying debug information such as raw messages received
  # as well as connection events e.g. open, close, error
  class DebugPlugin
    include Twitchbot::Plugin

    # Display to the user that the connection has been opened
    def open(handler)
      puts '! Connection established' if handler.bot.debug
    end

    # Display to the user any raw messages that have been received from the
    # server
    def message(handler)
      if handler.bot.debug
        handler.messages.each do |line|
          puts "> #{line.raw}"
        end
      end
    end

    # Display to the user that the connection has encountered an error
    def error(handler)
      puts '! Error occurred' if handler.bot.debug
    end

    # Display to the user that the connection has been closed
    def close(handler)
      puts '! Connection closed' if handler.bot.debug
    end
  end
end
