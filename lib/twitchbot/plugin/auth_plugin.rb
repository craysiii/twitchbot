require_relative '../plugin'

module Twitchbot
  # Plugin to handle authenticating the bot account and authorizing the use of
  # all available Twitch IRCv3 capabilities
  class AuthPlugin
    include Twitchbot::Plugin

    # The capabilities available to request
    CAPABILITIES = %w(
                      twitch.tv/tags
                      twitch.tv/commands
                      twitch.tv/membership
                   ).freeze

    # Send bot account credentials after the connection has opened
    def open(handler)
      handler.send_raw "PASS #{handler.bot.password}"
      handler.send_raw "NICK #{handler.bot.username}"
    end

    register command: '376', method: :request_caps
    # Listen for the last message of a successful authentication attempt and
    # request capabilities
    #
    #   > :tmi.twitch.tv 001 bot :Welcome, GLHF!
    #   > :tmi.twitch.tv 002 bot :Your host is tmi.twitch.tv
    #   > :tmi.twitch.tv 003 bot :This server is rather new
    #   > :tmi.twitch.tv 004 bot :-
    #   > :tmi.twitch.tv 375 bot :-
    #   > :tmi.twitch.tv 372 bot :You are in a maze of twisty passages, all alike.
    #   > :tmi.twitch.tv 376 bot :>
    def request_caps(message)
      message.send_raw "CAP REQ :#{CAPABILITIES.join ' '}"
    end
  end
end
