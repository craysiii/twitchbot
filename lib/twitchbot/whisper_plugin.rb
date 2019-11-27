module Twitchbot
  module WhisperPlugin

    COMMANDS = {}

    # Method that can be overriden to react to the eventmachine +:open+ event
    def open(handler) end

    def message(handler)
      handler.messages.each do |message|
        if message.whisper?
          # TODO: Extract this block from WhisperPlugin and MessagePlugin
          prefix = handler.bot.command_prefix
          _, _command, arguments = message.payload.partition(
              /#{Regexp.escape prefix}\S+/
          )
          command = _command.delete prefix
          commands = COMMANDS[self.class]
          if !command.nil? && !commands[command].nil?
            send(commands[command], message, arguments.lstrip)
          end
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