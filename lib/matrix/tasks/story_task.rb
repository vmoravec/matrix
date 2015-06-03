require 'rake/tasklib'
require "matrix/tracker"

module Matrix
  class StoryTask < ::Rake::TaskLib
    attr_reader :story_name, :config, :runners, :log, :targets, :current_target,
                :target_error, :tracker

    def initialize name, config
      @target_error = Proc.new {}
      @story_name = name
      @tracker = Tracker.new(story_name, :story)
      @targets = config.keys.reject {|k| k == "desc"}.map do |target|
        Matrix.targets.find(target)
      end.flatten
      @current_target = find_target(ENV["target"])
      @config = config
      @verbose = Matrix.verbose?
      @log = Matrix.logger
      define_tasks
    end

    def runners
      config[current_target.name]["runners"] || []
    end

    alias_method :name, :story_name

    private

    def run_story
      runner_tasks = runners.map do |runner|
        RunnerTask.new(runner, self)
      end

      runner_tasks.each do |runner|
        begin
          runner.invoke
        rescue => e
          tracker.failure!(e.message)
          abort "Runner '#{runner.name}' failed: #{e.message}" +
                "\nStory '#{story_name}' on target '#{current_target.name}' has failed."
        end
      end
      tracker.success!
    rescue => e
      tracker.failure!(e.message)
      raise
    ensure
      tracker.dump!
    end

    def find_target target_name
      targets_available = "Targets available: \n#{Matrix.targets.only(targets.map(&:name))}"
      if target_name.nil? || target_name.to_s.empty?
        missing_target = "No target provided for story '#{story_name}'. "
        @target_error = Proc.new { abort missing_target + targets_available }
        return
      end

      target = targets.find {|t| t.name == target_name }
      if target.nil?
        not_found = "Target '#{target_name}' not found for story '#{story_name}'. "
        @target_error = Proc.new { abort not_found + targets_available }
        return
      end

      target
    end

    def define_tasks
      namespace :story do
        namespace story_name do
          task :run  do
            target_error.call
            run_story
          end

          # Not using task desc on purpose
          task :config do
            target_error.call
            require "awesome_print"
            puts "Showing config for story '#{story_name}' and target '#{current_target.name}':"
            ap filter_story(story_name)
          end

          # Not showing task desc on purpose
          task :runners do
            target_error.call
            puts runners.inspect
          end

          # Not showing task desc on purpose
          task :targets do
            puts Matrix.targets.only(targets.map(&:name))
          end
        end

        # Define the main task to run a story
        desc config["desc"]
        task story_name => "story:#{story_name}:run"
      end

      # Nested method
      def filter_story story
        abort "No configuration found for any stories" if matrix.config["story"].nil?

        result = matrix.config["story"][story][current_target.name]
        abort "No configuration found for story '#{story_name}'" if result.nil?

        result
      end
    end
  end
end
