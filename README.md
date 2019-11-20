# Twitchbot

A plugin-based framework for creating Twitch chat bots, written in Ruby and based on `EventMachine` and `Faye::WebSocket`.

Notes:
* Plugins are first class citizens
* Helper functions implemented to gate-keep commands
* Bot can currently only join one channel (it might stay that way)
* Read the source until I get all the documentation completed

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'twitchbot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install twitchbot

## Getting Started

Require Twitchbot

    require 'twitchbot'
    
Create Plugins

    # MessagePlugin, which listens for the registered command preceeded by the Bot command_prefix
    class HiPlugin
      include Twitchbot::MessagePlugin
    
      register command: 'hi', method: :say_hi
    
      def say_hi(message, arg)
        message.respond 'Hello world!'
      end
    end
    
    # TimedPlugin, which fires off the registered command periodically
    class ShoutOutPlugin
      include Twitchbot::TimedPlugin
    
      register method: :social, interval: 15 # Time in seconds
    
      def social(handler)
        handler.send_channel('Hello! Check my social media out!')
      end
    end
    
    # Plugin, which listens for registered commands according to the raw IRC command
    class PutsPlugin
        include Twitchbot::Plugin
        
        register command: 'PRIVMSG', method: :put_string
        
        def put_string(handler)
            handler.messages.each do |message|
                puts message
            end
        end
    end
    
Create and start `Bot`

    bot = Twitchbot::Bot.new do |bot|
      bot.username = 'bot_name'
      bot.password = 'oauth:password'
      bot.channel = 'channel_name'
      bot.plugins = [HiPlugin, ShoutOutPlugin, PutsPlugin]
      bot.debug = true
      # bot.command_prefix = '$' # Default is '!'
    end
    
    bot.start

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/craysiii/twitchbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
