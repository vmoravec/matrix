module Matrix
  class FeatureTask
    class << self
      def cct_loaded?
        @cct_loaded
      end

      def load_cct!
        Rake::Task.tasks.each(&:reenable)
        return if cct_loaded?

        Rake::TaskManager.record_task_metadata = true
        Matrix.cct.load_tasks!
        @cct_loaded = true
      end

      # Cucumber features run in a forked process created by the cucumber rake task
      # Set the environment variables to let it work properly according to our needs
      def invoke_feature task_name, story
        update_cct_config(story)
        ENV["cct_log_path"] = Matrix.root.join(Matrix::LOG_DIR, ::Cct::LOG_FILENAME).to_s
        ENV["nocolors"] = "true"
        Dir.chdir(Matrix.cct.gem_dir) do
          Rake::Task[task_name].invoke
        end
      end

      private

      def update_cct_config story
        cct_config = {
          "admin_node" => story.current_target.admin_node.credentials,
          "control_node" => story.current_target.control_node
        }
        cct_config.merge!("cucumber" => Matrix.config["cucumber"])
        ENV["cct_config"] = cct_config.to_yaml
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
