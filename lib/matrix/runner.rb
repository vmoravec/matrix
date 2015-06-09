module Matrix
  class Runner
    attr_reader :story
    attr_reader :options
    attr_reader :command
    attr_reader :config
    attr_reader :tracker

    def initialize
      @story = Matrix.current_story || Story.new
      story.finalize!
      @config = story.config
      @tracker = story.tracker.runners.last
      yield
      raise "Command not defined for runner #{self.class.name}" unless command
    end

    def exec! action
      tracker.command = action if tracker
      command.exec!(action)
    end
  end
end
