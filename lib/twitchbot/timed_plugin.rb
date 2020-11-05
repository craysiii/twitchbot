require 'eventmachine'

module Twitchbot
  # Base Plugin module that registers methods that should be called periodically
  module TimedPlugin

    COMMANDS = {}

    # Method that reacts to the eventmachine +:open+ event and creates a new
    # eventmachine periodic timer for each plugin of this type
    #
    # It is not recommended to override this method unless you plan on handling
    # all logic for managing timed plugins yourself
    def open(handler)
      COMMANDS[self.class].each do |method, params|
        # Schedule initial timer
        EM::Timer.new(params[:offset]) do
          send(method, handler)
        end
        # Schedule future timers
        EM::Timer.new(params[:offset]) do
          EM::PeriodicTimer.new(params[:interval]) do
            send(method, handler)
          end
        end
      end
    end

    # Method that can be overriden to react to the eventmachine +:message+ event
    def message(event) end

    # Method that can be overriden to react to the eventmachine +:error+ event
    def error(event) end

    # Method that can be overriden to react to the eventmachine +:close+ event
    def close(event) end

    # Define a class method called register on each class that includes this
    # module, which allows the user to add methods to the +COMMANDS+ constant
    #
    #   def self.register(command:, method:)
    #     COMMANDS[base] = {} if COMMANDS[base].nil?
    #     COMMANDS[base][params[:command]] = params[:method]
    #   end
    def self.included(klass)
      klass.instance_eval do
        define_singleton_method 'register' do |params|
          COMMANDS[klass] = {} if COMMANDS[klass].nil?
          COMMANDS[klass][params[:method]] = {}
          COMMANDS[klass][params[:method]][:interval] = params[:interval]
          COMMANDS[klass][params[:method]][:offset] = params.key?(:offset) ? params[:offset] : 0
        end
      end
    end
  end
end
