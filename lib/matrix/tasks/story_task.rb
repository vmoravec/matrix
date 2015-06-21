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

    def abort! task, error, dump_json: false, type: nil
      message = "Story failed at task '#{type ? type.to_s + ":" : nil}#{task.name}'"
      message << "\n" << error.backtrace.join("\n") if Matrix.verbose?
      story.tracker.failure!(message)
      story.tracker.dump! if dump_json

      log.error("Aborting story #{story.name} due to error in task #{task.name}")
      abort message << "\nError: #{error.message}"
    end

    private

    def run_story
      log.info("Launching story '#{story.name}:#{story.desc}' for target '#{story.current_target.name}'")
      runner_tasks = StoryFilters.new.runners.each do |runner_options|
        story.runner_options = runner_options
        RunnerTask.new(story)
      end

      runner_tasks.each {|runner| runner.invoke }
      success_message = "Story '#{story.name}' has finished successfuly " +
                        "on target '#{story.target.name}'"
      log.info(success_message)
      puts success_message
      story.tracker.success!
    rescue => e
      story.tracker.failure!(e.message)
      raise
    ensure
      story.tracker.dump!
    end

    def define_tasks
      namespace :story do
        namespace story.name do
          task :run  do
            story.finalize!
            run_story
          end

          # Not using task desc on purpose
          task :config do
            story.finalize!
            require "awesome_print"
            puts "Showing config for story '#{story.name}' and target '#{story.current_target.name}':"
            ap filter_story(story.name)
          end

          # Not showing task desc on purpose
          task :runners do
            story.finalize!
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

      class StoryFilters
        FILTERS = %w( start stop )

        attr_reader :filters

        def initialize
          @filters = FILTERS.map do |filter|
            next unless ENV[filter]

            Filter.new(filter, ENV[filter])
          end.compact
        end

        def present?
          !filters.empty?
        end

        def runners
          all_runners = story.runners.map {|r| r.to_a.first.first } # get only the runner name
          started = all_runners.drop_while {|r| r !=  list(:start).runners.first }
          filtered = started - list(:stop).runners
          story.runners.select {|r| filtered.include?(r.to_a.first.first) }
        end

        def list name
          filters.find {|f| f.name == name.to_s } || []
        end

        class Filter < Struct.new(:name, :value)
          def runners
            case name
            when "start"
              extract_started_runners
            when "stop"
              extract_stopped_runners
            end
          end

          private

          def extract_started_runners
            started = false
            story.runners.map do |runner|
              runner_name, _ = runner.to_a.first
              if runner_name == filter.value
                started = true
              end

              runner_name if started
            end.compact
          end

          def extract_stopped_runners
            stopped = false
            story.runners.map do |runner|
              runner_name, _ = runner.to_a.first
              if filter.value == runner_name
                stopped = true
                next
              end
              runner_name if stopped
            end.compact
          end
        end

      end
    end
  end
end
