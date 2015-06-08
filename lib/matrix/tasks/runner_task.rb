require 'timeout'

module Matrix
  class RunnerTask
    DEFAULT_TIMEOUT = "5 minutes"

    attr_reader :features, :runner_name, :log, :environment, :story
    attr_reader :ignore_features
    attr_reader :target, :runner_params
    attr_reader :tracker

    def initialize params, story
      @ignore_features = ENV["features"] == "false" ? true : false
      @story = story
      @runner_name, @runner_params = params.to_a.first
      @tracker = Tracker.new(:runner, runner_name)
      @log = Matrix.logger

      return if ignore_features?
      return if runner_params.nil?
    end

    alias_method :name, :runner_name

    def invoke
      extract_params.each do |params|
        story.tracker.runners << tracker
        current_runner(params) do
          update_tracker(params)
          invoke_runner(params)
          invoke_features(params)
          tracker.success!
        end
      end
    end

    private

    def invoke_runner params
      event = params["stage"] || runner_name
      time = params["timeout"].to_s || DEFAULT_TIMEOUT
      wait_for(event, max: time) do
        Rake::Task[runner_name].invoke
      end
    rescue => err
      log_error(err)
      tracker.failure!("Runner failed: #{err.message}")
      story.abort!(self, err)
    end

    def handle_cucumber_exit feature_tracker, feature_name
      log.error("Feature failed, exiting..")
      feature_tracker.failure!("Feature failed")
      tracker.failure!("Feature '#{feature_name}' failed")
      story.abort!(
        feature_tracker,
        OpenStruct.new( # replicate an exception object
          message: "Feature #{feature_name} failed",
          backtrace: []
        ),
        dump_json: true
      )
    end

    def invoke_features params
      extract_features(params).each do |feature_name|
        feature_tracker = Tracker.new(:feature, feature_name)
        tracker.features << feature_tracker
        begin
          # Catch the exit of cucumber feature rake task in case it fails and
          # finish the story with all trackers gracefuly
          Kernel.at_exit { handle_cucumber_exit(feature_tracker, feature_name) }
          FeatureTask.new(story, feature_name).invoke
          feature_tracker.success!
        rescue => err
          log_error(err)
          feature_tracker.failure!(err.message)
          tracker.failure!("Feature '#{feature_name}' failed: #{err.message}")
          story.abort!(feature_tracker, err)
        end
      end unless ignore_features?
    end

    def ignore_features?
      ignore_features
    end

    def update_tracker params
      tracker.stage = params["stage"]
      tracker.timeout = params["timeout"]
    end

    def log_error err
      log.error(err.message)
      log.error(err.backtrace.join("\n"))
    end

    def extract_params
      case runner_params
      when Hash
        [ runner_params ]
      when Array
        runner_params
      when nil
        [ {} ]
      else
        raise "#{runner_params.class} not allowed for runner params"
      end
    end

    def current_runner params
      Matrix.current_runner = [ self, params ]
      log.debug("Matrix.current_runner has been set for '#{runner_name}' " +
               "and story '#{story.name}'")
      yield
      log.debug("Setting current_runner to nil")
      Matrix.current_runner = nil
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
      Timeout.timeout(timeout_time) { yield }
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
