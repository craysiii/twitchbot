require 'eventmachine'
require 'faye/websocket'

require_relative 'event_handler'
require_relative 'channel'
require_relative 'plugin/auth_plugin'
require_relative 'plugin/connection_plugin'
require_relative 'plugin/channel_plugin'
require_relative 'plugin/message_queue_plugin'

module Twitchbot
  # Main Bot class that we pass all bot account information to, as well as any
  # plugins that should be used
  class Bot
    # @return [String] Username of the bot account
    attr_accessor :username
    # @return [String] Password of the bot account
    attr_accessor :password
    # @return [Channel] The channel that the bot is connected to
    attr_accessor :channel
    # @return [Array] The plugins that are in use by the bot
    attr_accessor :plugins
    # @return [Boolean] Whether the bot should display debug info to STDOUT
    attr_accessor :debug
    # @return [Array] The array of messages that are to be sent to the server
    attr_accessor :message_queue
    # @return [String] The prefix to use when defining and parsing commands e.g. +!+
    attr_accessor :command_prefix

    # The connection URL for Twitch
    DEFAULT_URL = 'wss://irc-ws.chat.twitch.tv'.freeze
    # The built-in plugins to be used
    DEFAULT_PLUGINS = [ConnectionPlugin,
                       MessageQueuePlugin,
                       AuthPlugin,
                       ChannelPlugin
                      ].freeze
    # The events that eventmachine  dispatches to any plugins in use
    DEFAULT_EVENTS = %i[error close open message].freeze

    # Create a new Bot instance, passing a block to set the necessary
    # attributes to have the bot function
    def initialize
      @username = ''
      @password = ''
      @channel = ''
      @plugins = []
      @message_queue = Queue.new
      @command_prefix = '!'

      yield self

      @channel = Channel.new(@channel)
    end

    # Start the event loop, initiate the websocket client, and register the
    # plugins with eventmachine
    def start
      EM.run do
        connection = Faye::WebSocket::Client.new DEFAULT_URL
        plugins = (DEFAULT_PLUGINS + @plugins).flatten.map! &:new
        DEFAULT_EVENTS.each do |default_event|
          connection.on(default_event) do |em_event|
            handler = EventHandler.new em_event, connection, self
            plugins.each do |plugin|
              plugin.send(default_event, handler)
            end
          end
        end
      end
    end
  end
end
