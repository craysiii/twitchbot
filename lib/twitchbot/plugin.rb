module Twitchbot
  # Base Plugin module that listens for IRC commands and calls the associated
  # method of the class that includes it
  module Plugin

    # The commands that are registered to this base module via classes that
    # include it
    #
    # Example state during runtime:
    #   { AuthPlugin: { '376': :request_caps }, ChannelPlugin: { 'CAP': :join_channel, 'JOIN': :process_join, 'PART': :process_part } }
    COMMANDS = {}

    # Method that can be overriden to react to the eventmachine +:open+ event
    def open(handler) end

    # Method that reacts to the eventmachine +:message+ event and processes each
    # message in the {EventHandler}, calling the appropriate method if available.
    #
    # It is not recommended to override this method unless you plan on handling
    # all logic for reacting to methods yourself.
    def message(handler)
      handler.messages.each do |message|
        command = message&.command
        # Grab all registered methods of the including class
        commands = COMMANDS[self.class]
        if !command.nil? && !commands[command].nil?
          # Call the including class method and pass the EventHandler to it
          send(commands[command], message)
        end
      end
    end

    # Method that can be overriden to react to the eventmachine +:error+ event
    def error(handler) end

    # Method that can be overriden to react to the eventmachine +:close+ event
    def close(handler) end

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
          COMMANDS[klass][params[:command]] = params[:method]
        end
      end
    end
  end
end
