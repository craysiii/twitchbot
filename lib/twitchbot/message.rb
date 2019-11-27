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

      if message?
        @payload.slice! 0, 1
        @channel = @handler.bot.channel
        /bits=(?<bits>\d+)/ =~ @tags
        @bits = bits.nil? ? 0 : bits.to_i
        /display-name=(?<display_name>\w+)/ =~ @tags
        /user-id=(?<user_id>[a-zA-Z0-9\-]+)/ =~ @tags
        /badges=(?<badges>[a-zA-Z\/,0-9\-]+)/ =~ @tags
        badges = badges || ''
        /:(?<user>\w+)/ =~ @sender
        if @channel.users.key? user
          @channel.users[user].update_attributes display_name, user_id, badges
        else
          @channel.users[user] = User.new user, display_name, user_id, badges
        end
        @user = @channel.users[user]
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

    # Method to respond to the IRC message target with a private message
    def respond(message)
      @handler.bot.message_queue.push("PRIVMSG #{@target} :#{message}")
    end

    # Method to determine if the IRC message is a PING challenge
    def ping?
      @raw.start_with? 'PING'
    end
  end
end