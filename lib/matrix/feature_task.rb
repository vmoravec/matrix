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

      def invoke_feature task_name
        ENV["cct_log_path"] = Matrix.root.join(Matrix::LOG_DIR, ::Cct::LOG_FILENAME).to_s

        Dir.chdir(Matrix.cct.gem_dir) do
          Rake::Task[task_name].invoke
        end
      end
    end

    PREFIX = "feature"

    attr_reader :feature, :scenarios, :name, :log

    def initialize feature_name, scenarios
      @log = Matrix.logger
      @name = feature_name
      @feature = "#{PREFIX}:#{name}"
      @scenarios = scenarios || []
      self.class.load_cct!
    end

    def invoke
      log.info("Invoking task '#{name}' from matrix...")
      self.class.invoke_feature(feature)
    end

  end
end
