module Matrix
  class RunnerTask
    attr_reader :features, :runner_name, :log, :environment, :story
    attr_reader :ignore_features
    attr_reader :target, :runner_params
    attr_reader :tracker

    def initialize params, story
      @ignore_features = ENV["features"] == "false" ? true : false
      @story = story
      @runner_name, @runner_params = params.to_a.first
      @tracker = Tracker.new(runner_name, :runner)
      @log = Matrix.logger

      return if ignore_features?
      return if runner_params.nil?
    end

    alias_method :name, :runner_name

    def invoke
      expand_params.each do |params|
        #TODO Add handling for tracker errors and so on!
        story.tracker.runners << tracker
        current_runner(params) do
          update_tracker(params)
          begin
            Rake::Task[runner_name].invoke
          rescue => err
            tracker.failure!(err.message)
            story.abort!(self, err)
          end
          extract_features(params).each do |feature_name|
           #FeatureTask.new(story, feature_name).invoke
          end unless ignore_features?
        end
      end
    end

    def ignore_features?
      ignore_features
    end

    private

    def update_tracker params
      tracker.stage = params["stage"]
      tracker.timeout = params["timeout"]
    end

    def expand_params
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
      Matrix.config.current_runner = [ self, params ]
      log.info("Matrix.config.current_runner has been set for '#{runner_name}' " +
               "and story '#{story.name}'")
      yield
      log.info("Setting current_runner to nil")
      Matrix.config.current_runner = nil
    end

    def extract_features params
      case params
      when Hash
        params["features"] || []
      when nil
        []
      else
        abort "Runner config must be a Hash or nil, got #{params.class}"
      end
    end

  end
end
