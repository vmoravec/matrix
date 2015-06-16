require 'timeout'

module Matrix
  class RunnerTask
    DEFAULT_TIMEOUT = "1 minute"

    attr_reader :features, :runner_name, :log, :environment, :story
    attr_reader :ignore_features
    attr_reader :target, :runner_options

    def initialize story
      @story = story
      @ignore_features = ENV["features"] == "false" ? true : false
      @runner_name, @runner_options = story.runner_options.to_a.first
      @log = Matrix.logger
    end

    alias_method :name, :runner_name

    def invoke
      extract_options.each do |params|
        tracker = Tracker.new(:runner, runner_name)
        story.tracker.runners << tracker
        update_tracker(tracker, params)
        current_story(params) do
          invoke_runner(tracker, params)
          invoke_features(tracker, params)
          tracker.success!
        end
      end
      success_message = "Runner '#{runner_name}' has finished successfuly"
      log.info(success_message)
    end

    private

    def current_story params
      Matrix.current_story = story
      log.debug("Matrix.current_story has been set for '#{runner_name}' " +
               "and story '#{story.name}'")
      yield
      log.debug("Setting current_story to nil")
      Matrix.current_story = nil
    end

    def invoke_runner tracker, params
      event = params["stage"] || "(no target description was given)"
      time = params["timeout"].to_s || DEFAULT_TIMEOUT
      puts ">> Invoking `#{runner_name}` with timeout #{time} to make '#{event}'"
      wait_for(event, max: time) do
        Rake::Task[runner_name].invoke
        Rake::Task[runner_name].reenable
      end
      puts
    rescue => err
      log_error(err)
      puts
      tracker.failure!("Runner failed: #{err.message}")
      story.task.abort!(self, err)
    end

    def handle_cucumber_exit feature_tracker, tracker, feature_name
      return if $?.success?

      log.error("Feature failed, exiting..")
      tracker.failure!("Feature '#{feature_name}' failed")
      feature_tracker.failure!("Feature failed")
      story.tracker.failure!("Feature '#{feature_name}' failed")
      story.task.abort!(
        feature_tracker,
        OpenStruct.new( # replicate an exception object
          message: "Feature #{feature_name} failed",
          backtrace: []
        ),
        dump_json: true,
        type: :feature
      )
    end

    def invoke_features tracker, params
      extract_features(params).each do |feature_name|
        feature_tracker = Tracker.new(:feature, feature_name)
        tracker.features << feature_tracker
        begin
          # Catch the exit of cucumber feature rake task and in case it failed
          # finish the story with all trackers gracefuly
          Kernel.at_exit { handle_cucumber_exit(feature_tracker, tracker, feature_name) }
          puts ">> Invoking `feature:#{feature_name}`"
          print " $ #{Matrix.user.login}@#{Matrix.hostname} -> "
          FeatureTask.new(story, feature_name).invoke
          puts
          feature_tracker.success!
        rescue => err
          puts
          log_error(err)
          feature_tracker.failure!(err.message)
          tracker.failure!("Feature '#{feature_name}' failed: #{err.message}")
          story.task.abort!(feature_tracker, err)
        end
      end unless ignore_features?
    end

    def ignore_features?
      ignore_features
    end

    def update_tracker tracker, params
      tracker.stage = params["stage"]
      tracker.timeout = params["timeout"]
    end

    def log_error err
      log.error(err.message)
      log.error(err.backtrace.join("\n"))
    end

    def extract_options
      case runner_options
      when Hash
        [ runner_options ]
      when Array
        runner_options
      when nil
        [ {} ]
      else
        raise "#{runner_options.class} not allowed for runner options"
      end
    end

    def extract_features params
      case params
      when Hash
        params["features"] || []
      when nil
        []
      else
        abort "Runner config section must be a Hash or nil, got #{params.class}"
      end
    end

    def wait_for event, options
      period, period_units = options[:max].split
      timeout_time = convert_to_seconds(period, period_units)
      log.info("Setting timeout for '#{event}' to #{options[:max]}")
      Timeout.timeout(timeout_time) do
        yield
      end
    rescue Timeout::Error
      message = "Stage '#{event}' was not reached due to expired timeout (#{options[:max]})"
      raise message
    end

    def convert_to_seconds period, units
      case units
      when /minute/
        period.to_i * 60
      when /second/
        period.to_i
      # when no units are specified, expect seconds were meant
      when nil
        period.to_i
      else
        raise "Only minutes or seconds are allowed for timeout specification"
      end
    end

  end
end
