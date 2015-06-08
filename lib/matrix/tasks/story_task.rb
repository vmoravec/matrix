require 'rake/tasklib'
require "matrix/tracker"

module Matrix
  class StoryTask < ::Rake::TaskLib
    attr_reader :log, :story

    def initialize name, config
      @story = Story.new(name: name, config: config)
      story.task = self
      @log = Matrix.logger
      define_tasks
    end

    def abort! task, error, dump_json: false
      message = "Story failed at task '#{task.name}': #{error.message}"
      message << "\n" << error.backtrace.join("\n") if Matrix.verbose?
      story.tracker.failure!(message)
      story.tracker.dump! if dump_json

      log.error("Aborting story #{story.name} due to error in task #{task.name}")
      abort "#{message} \nStory '#{story.name}' for target '#{story.current_target.name}' has no happyend."
    end

    private

    def run_story
      log.info("Launching story '#{story.name}:#{story.desc}' for target '#{story.current_target.name}'")
      runner_tasks = story.runners.map do |runner|
        RunnerTask.new(runner, story)
      end

      runner_tasks.each do |runner|
        adapt_config do
          runner.invoke
        end
      end
      story.tracker.success!
    rescue => e
      story.tracker.failure!(e.message)
      raise
    ensure
      story.tracker.dump!
    end

    def adapt_config
      @original_config = @config
      @config = story.config[current_target.name]
      yield
      @config = @original_config
    end

    def define_tasks
      namespace :story do
        namespace story.name do
          task :run  do
            story.target_error.call
            run_story
          end

          # Not using task desc on purpose
          task :config do
            story.target_error.call
            require "awesome_print"
            puts "Showing config for story '#{story.name}' and target '#{story.current_target.name}':"
            ap filter_story(story.name)
          end

          # Not showing task desc on purpose
          task :runners do
            story.target_error.call
            puts story.runners.inspect
          end

          # Not showing task desc on purpose
          task :targets do
            puts Matrix.targets.only(story.targets.map(&:name))
          end
        end

        # Define the main task to run a story
        desc story.desc
        task story.name => "story:#{story.name}:run"
      end

      # Nested method
      def filter_story story
        abort "No configuration found for any stories" if matrix.config["story"].nil?

        result = matrix.config["story"][story.name][story.current_target.name]
        abort "No configuration found for story '#{story.name}'" if result.nil?

        result
      end
    end
  end
end
