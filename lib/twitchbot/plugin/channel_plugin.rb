require_relative '../plugin'
require_relative '../user'

module Twitchbot
  # Plugin to handle joining the specified channel, as well as maintaining a
  # list of users who have joined or left the channel
  #
  # TODO: Handle 353 and 366 (NAMES list)
  class ChannelPlugin
    include Twitchbot::Plugin

    register command: 'CAP', method: :join_channel
    # Listen for the response from AuthPlugin#request_caps and request to join
    # the channel
    #
    #   > :tmi.twitch.tv CAP * ACK :twitch.tv/tags twitch.tv/commands twitch.tv/membership
    def join_channel(message)
      message.send_raw "JOIN ##{message.channel.name}"
    end

    register command: 'JOIN', method: :process_join
    # Listen for any JOIN commands and add the user to the channel user list
    #
    #   > :<user>!<user>@<user>.tmi.twitch.tv JOIN #<channel>
    def process_join(message)
      channel = message.channel
      /:(?<sender>\w+)/ =~ message.raw
      channel.users[sender] = User.new sender unless channel.users.key? sender
    end

    register command: 'PART', method: :process_part
    # Listen for any PART commands and remove the user from the channel user
    # list
    #
    #   > :<user>!<user>@<user>.tmi.twitch.tv PART #<channel>
    def process_part(message)
      channel = message.channel
      /:(?<sender>\w+)/ =~ message.raw
      channel.users.delete sender if channel.users.key? sender
    end
  end
end

