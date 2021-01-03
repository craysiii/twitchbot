require_relative 'user'

module Twitchbot
  # Class responsible for parsing messages created in [EventHandler]
  #
  # TODO: Clean this up because its ugly
  # TODO: Parse message-id
  class Message
    # @return [Integer] Number of bits that have been included in a message
    attr_reader :bits
    # @return [User] User that the message was sent by
    attr_reader :user
    # @return [Channel] Channel that the message was sent to
    attr_reader :channel
    # @return [String] IRC command of the raw IRC message
    attr_reader :command
    # @return [String] Raw IRC message received
    attr_reader :raw
    # @return [String] Sender of the IRC message
    attr_reader :sender
    # @return [String] Target of the IRC message
    attr_reader :target
    # @return [String] Content of the IRC message
    attr_reader :payload
    # @return [EventHandler] EventHandler associated with the IRC message
    attr_reader :handler

    def initialize(handler, raw_message)
      @handler = handler
      @raw = raw_message
      msg = @raw.dup
      @tags = msg.slice! /^\S+/ if tagged?

      msg.lstrip!
      /^(?<sender>:\S+) (?<command>\S+)( (?<target>\S+))?( (?<payload>.+))?$/ =~ msg
      @sender = sender
      @command = command
      @target = target
      @payload = payload

      @channel = @handler.bot.channel

      unless received_host?
        if message? || whisper?
          @payload.slice! 0, 1
          @display_name = @tags[/display-name=(\w+)/, 1]
          @user_id = @tags[/user-id=(?<user_id>\d+)/, 1]
          /:(?<user>\w+)/ =~ @sender
          if @channel.users.key? user
            @channel.users[user].update_attributes @display_name, @user_id
          else
            @channel.users[user] = User.new user, @display_name, @user_id
          end
          @user = @channel.users[user]
        end

        if message?
          /bits=(?<bits>\d+)/ =~ @tags
          @bits = bits.nil? ? 0 : bits.to_i
          /badges=(?<badges>[a-zA-Z\/,0-9\-]+)/ =~ @tags
          @user.update_badges badges || ''
        end

        # Grab broadcaster status even though twitch doesn't inject it in the tags
        # in a whisper
        if whisper?
          if @user.name.downcase.eql? @handler.bot.channel.name.downcase
            @user.update_badges 'broadcaster/1'
          end
        end
      end
    end

    # Method to determine if the IRC message includes any tags from the +:twitch.tv/tags+ capability
    def tagged?
      @raw.start_with? '@'
    end

    # Method to determine if the IRC message is an actual message to the [Channel] by a [User]
    def message?
      @command.eql? 'PRIVMSG'.freeze
    end

    # Method to determine if the IRC message is a whisper to the bot
    def whisper?
      @command.eql? 'WHISPER'.freeze
    end

    # Method to determine if the IRC message is a received host message from Twitch
    def received_host?
      message? && target.downcase.eql?(@handler.bot.channel.name.downcase) &&
        /:\w+ is now hosting you./.match?(@payload)
    end

    # Method to respond to the IRC message target with a private message
    def respond(message)
      send_channel message if message?
      send_whisper @user, message if whisper?
    end

    # Method to send a message to the joined [Channel]
    def send_channel(message)
      @handler.send_channel message
    end

    # Method to send a whisper to the specified [User]
    def send_whisper(user, message)
      @handler.send_whisper user, message
    end

    # Method to send a raw IRC message to the server
    def send_raw(message)
      @handler.send_raw message
    end

    # Method to determine if the IRC message is a PING challenge
    def ping?
      @raw.start_with? 'PING'
    end
  end
end
