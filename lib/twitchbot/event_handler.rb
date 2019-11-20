require_relative 'message'

module Twitchbot
  # Class responsible for handling the eventmachine event that is provided
  # whenever an event is fired
  class EventHandler
    # @return [Bot] The bot that the channel is a member of
    attr_reader :bot
    # @return [Array] The different messages received
    attr_reader :messages
    # @return [Faye::WebSocket::Client] The WebSocket client instance
    attr_reader :connection

    def initialize(event, connection, bot)
      @connection = connection
      @bot = bot

      if event.respond_to? :data
        @chunks = event.data.split "\n"
        @messages = []
        @chunks.each do |chunk|
          @messages << Message.new(self, chunk.chomp)
        end
      end
    end

    # Add a raw message to the message queue
    def send_raw(message)
      @bot.message_queue.push(message)
    end

    # Add a formatted channel message to the message queue
    def send_channel(message)
      @bot.message_queue.push("PRIVMSG ##{bot.channel.name} :#{message}")
    end

    # Add a whisper to the specified user to the message queue
    def send_whisper(user, message)
      @bot.message_queue.push("PRIVMSG jtv :/w #{user} :#{message}")
    end

    # Method that provides a shortcut to grab the first message in an event
    # handler. We can typically use this after authenticating, but there is no
    # guarantee that twitch will not send multiple 'messages' in a single
    # +:message+ event
    def message
      @messages.first
    end
  end
end
