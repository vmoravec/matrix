module Matrix
  class Runner
    attr_reader :story, :runner_params
    attr_reader :command
    attr_reader :config
    attr_reader :tracker

    def initialize
      if Matrix.current_runner.nil?
        raise "Current runner task does not exists, something is wrong.."
      end

      runner_task, @runner_params = Matrix.current_runner
      @story = runner_task.story
      @tracker = runner_task.tracker
      @config = story.config
    end

    alias_method :params, :runner_params
  end
end
