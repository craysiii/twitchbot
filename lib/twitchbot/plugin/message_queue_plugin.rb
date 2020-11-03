require_relative '../timed_plugin'

module Twitchbot
  # Plugin to handle sending messages to the server that have been queued from
  # any plugins running.
  #
  # TODO: Implement different levels of rate limiting according to bot status e.g. :mod, :verified, :trusted
  class MessageQueuePlugin
    include Twitchbot::TimedPlugin

    # The most privileged bot can only send 7200 messages every 30 seconds
    register method: :send_message, interval: (30 / 7200.0)
    # Pull a message from the message queue if any are available and send to the
    # server
    def send_message(handler)
      queue = handler.bot.message_queue
      unless queue.empty?
        message = queue.pop
        puts "< #{message}" if handler.bot.debug
        handler.connection.send message
      end
    end
  end
end
