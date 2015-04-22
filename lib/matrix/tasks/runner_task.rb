module Matrix
  class RunnerTask
    attr_reader :features, :feature_tasks, :runner_name, :log, :config, :story_name
    attr_reader :ignore_features

    # @param [Array<string, Hash|String|nil, Hash>]
    #   @Example:
    #   ["mkcloud:cleanup", {"features" => {"admin" => nil}}, {"mkcloud"=> {...}}]
    def initialize story_name, config
      @ignore_features = !!ENV["ignore_features"]
      @story_name = story_name
      @log = Matrix.logger
      @runner_name = config.first
      @config = config[2]
      return if ignore_features?

      @features = detect_features(config[1])
      @feature_tasks = features.map {|feature| FeatureTask.new(*feature.concat([story_name])) }
    end

    def invoke
      Rake::Task[runner_name].invoke(story_name, config)
      feature_tasks.each(&:invoke) unless ignore_features?
    end

    def ignore_features?
      ignore_features
    end

    private

    def detect_features config
      case config
      when nil, String
        {}
      when Hash
        verify_features(config["features"])
      when Array
        fail "Features' node in a story must be a hash, not a list"
      else
        {}
      end
    end

    def verify_features feats
      case feats
      when nil, String, Array
        log_warning(feats)
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
