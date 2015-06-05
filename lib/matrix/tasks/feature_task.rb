module Matrix
  class FeatureTask
    class << self
      def cct_loaded?
        @cct_loaded
      end

      def load_cct!
        return if cct_loaded?

        Rake::TaskManager.record_task_metadata = true
        Matrix.cct.load_tasks!
        @cct_loaded = true
      end

      # Cucumber features run in a forked process created by the cucumber rake task
      # Set the environment variables to let it work properly according to our needs
      def invoke_feature task_name, story
        cct_config = story.config["cct"]
        if cct_config.nil?
          abort "Cct config not found. You need to specify it in `config/cct.yml` file " +
                "or in a separate 'cct' section in a story configuration yaml file"
        end

        ENV["cct_log_path"] = Matrix.root.join(Matrix::LOG_DIR, ::Cct::LOG_FILENAME).to_s
        Dir.chdir(Matrix.cct.gem_dir) do
          ENV["cct_config"] = cct_config.to_yaml
          Rake::Task[task_name].invoke
        end
      end
    end

    PREFIX = "feature"

    attr_reader :feature, :name, :log, :story

    def initialize story, feature_name
      @story = story
      @log = Matrix.logger
      @name = feature_name
      @feature = "#{PREFIX}:#{feature_name}"
      self.class.load_cct!
    end

    def invoke
      log.info("Invoking task '#{feature}' from matrix...")
      self.class.invoke_feature(feature, story)
    end

  end
end
