module Twitchbot
  # Class responsible for keeping track of a user attributes such as their
  # display name, id, any badges they have, and implementing helper functions
  # to determine if different qualities of the user
  class User
    # @return [String] Server ID for the user
    attr_reader :id
    # @return [Hash] Collection of known badges for the user
    attr_reader :badges

    def initialize(name, display_name = nil, id = nil, badges = nil)
      @name = name
      @display_name = display_name
      @id = id
      @badges = badges.nil? ? nil : process_badges(badges)
    end

    # Method to update the main attributes of a user
    def update_attributes(display_name, id, badges)
      @display_name = display_name
      @user_id = id
      @badges = process_badges(badges)
    end

    # Method to grab the best representation of a user
    def name
      @display_name || @name
    end

    # Method to determine if the user is a moderator of the channel
    def mod?
      @badges.key? 'moderator'
    end

    # Method to determine if the user is a subscriber to the channel
    def sub?
      @badges.key? 'subscriber'
    end

    # Method to determine if the user has Twitch Prime
    def prime?
      @badges.key? 'premium'
    end

    # Method to determine if the user has ever donated to the channel
    def donator?
      @badges.key? 'bits'
    end

    # Method to determine if the user is a channel founder
    def founder?
      @badges.key? 'founder'
    end

    # Method to determine if the user is on the leaderboard for subscriber gifts
    def sub_gift_leader?
      @badges.key? 'sub-gift-leader'
    end

    # Method to determine if the user is on the leaderboard for bit gifts
    def bits_leader?
      @badges.key? 'bits-leader'
    end

    # Method to process the string representation of badges into a Hash so that
    # we can query it for specific badges and levels of the badges
    def process_badges(badges)
      badge = {}
      badges.split(',').each do |_badge|
        type, value = _badge.split '/'
        badge[type] = value.to_i
      end
      badge
    end

    def to_s
      name
    end
  end
end