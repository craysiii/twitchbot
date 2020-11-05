module Twitchbot
  # Class responsible for keeping track of channel attributes such as channel
  # state and users in the channel
  #
  # TODO: Implement channel states e.g. r9k, emote-only, sub-only, slow
  # TODO: Capture channel id from tags
  class Channel
    # @return [String] Name of the channel we have joined
    attr_reader :name
    # @return [Hash] Mapping of user objects according to their username
    attr_accessor :users

    def initialize(name)
      @name = name
      @users = {}
    end
  end

  def to_s
    @name
  end
end
