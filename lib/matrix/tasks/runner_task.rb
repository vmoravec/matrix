module Matrix
  class RunnerTask
    attr_reader :features, :feature_tasks, :runner_name, :log, :environment, :story_name
    attr_reader :ignore_features

    # @params [String, Array<String, Hash|String|nil, Hash>]
    #
    #   @Example:
    #
    #   ["mkcloud:cleanup", {"features" => {"admin" => nil}}, {"mkcloud"=> {...}}]
    def initialize story_name, config
      @ignore_features = !!ENV["ignore_features"]
      @story_name = story_name
      @log = Matrix.logger
      @runner_name, features, @environment = config
      return if ignore_features?

      @features = transform_features(features)
      @feature_tasks = @features.map do |feature|
        FeatureTask.new(*feature.concat([story_name]))
      end
    end

    def invoke
      current_runner { Rake::Task[runner_name].invoke }
      feature_tasks.each(&:invoke) unless ignore_features?
    end

    def ignore_features?
      ignore_features
    end

    private

    def current_runner
      set_current_runner
      yield
      log.info("Setting current_runner to nil")
      Matrix.config.current_runner = nil
    end

    def set_current_runner
      Matrix.config.current_runner = [
        story_name,
        environment
      ]
      log.info("Matrix.config.current_runner has been set for '#{runner_name}' " +
               "and story '#{story_name}'")
    end

    def transform_features features
      case features
      when nil, String
        {}
      when Hash
        verify_features(features["features"])
      when Array
        fail "Features' node in a story must be a hash, not a list"
      else
        {}
      end
    end

    def verify_features feats
      case feats
      when nil, String, Array
        {}
      when Hash
        feats
      end
    end

    def log_warning data
      log.warn("Features must be a hash, ignoring #{data.inspect}")
    end
  end
end
