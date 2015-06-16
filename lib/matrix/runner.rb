module Matrix
  class Runner
    include Utils::User

    attr_reader :bin
    attr_reader :command
    attr_reader :config
    attr_reader :environment
    attr_reader :gate
    attr_reader :log
    attr_reader :options
    attr_reader :story
    attr_reader :tracker

    def initialize
      @story = Matrix.current_story || Story.new
      story.finalize!
      @log = Matrix.logger
      @gate = story.current_target.gate
      @config = story.config
      @tracker = story.tracker.runners.last
      yield
      raise "Command not defined for runner #{self.class.name}" unless command
    end

    def exec! action
      action = "#{bin} #{action}" if bin
      action = "#{environment} #{action}" if environment
      action = sudo(action).join if command.is_a?(LocalCommand)

      command_details =
        case command
        when LocalCommand
          "#{Matrix.user.login}@#{Matrix.hostname} -> `#{action}`"
        when RemoteCommand
          remote_host = command.gateway ? command.target.ip : command.options.ip
          "#{command.options.user}@#{remote_host} -> `#{action}`"
        end

      #FIXME if a runner execs multiple commands, only the last one is stored
      tracker.command = command_details if tracker

      puts " $ #{command_details}"

      log.info("Running command #{command_details}")
      command.exec!(action)
    end
  end
end

require "matrix/runners/mkcloud"
require "matrix/runners/virtsetup"
require "matrix/runners/gate"
require "matrix/runners/qa_crowbarsetup"
require "matrix/runners/void"
