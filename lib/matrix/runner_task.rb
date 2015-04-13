module Matrix
  class RunnerTask
    attr_reader :features, :feature_tasks, :runner_name, :log, :config

    # @param [Array<string, nil|String|Hash>]
    #   @Example:
    #   ["mkcloud:cleanup", {"features" => {"admin" => nil}}]
    def initialize config
      @log = Matrix.logger
      @runner_name = config.first
      @features = detect_features(config[1])
      @config = config[2]
      @feature_tasks = features.map {|feature| FeatureTask.new(*feature) }
    end

    def invoke
       Rake::Task[runner_name].invoke(config)
      feature_tasks.each(&:invoke)
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