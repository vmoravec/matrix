module Matrix
  class RunnerTask
    attr_reader :features, :feature_tasks, :runner_name, :log, :environment, :story
    attr_reader :ignore_features
    attr_reader :target, :runner_params

    # @params [String, Array<String, Hash|String|nil, Hash>]
    #
    #   @Example:
    #
    def initialize params, story, target, multitask=false
      @ignore_features = !!ENV["no-features"]
      @story = story
      @target = target
      #TODO Verify and extract params
      # if they are Hash, the code below is fine
      # if they are Array, we need to add child tasks and set this task
      # as multitask when the #invoke method will trigger several tasks at once
      @runner_name, @runner_params = params.to_a.first
      @log = Matrix.logger
      return if ignore_features?
      return if runner_params.nil?

      @feature_tasks = extract_features(runner_params).map do |feature_name|
        FeatureTask.new(story, feature_name)
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
        story.name,
        environment
      ]
      log.info("Matrix.config.current_runner has been set for '#{runner_name}' " +
               "and story '#{story.name}'")
    end

    def extract_features params
      features = []
      case params
      when Hash
        feats = params["features"]
        return unless feats

        features.concat(feats)
      when Array
        params.each do |child_runner|
          feats = child_runner["features"]
          next unless feats

        end
      else
        abort "Runner config must be a Hash or an Array, got #{params.class}"
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
