require "pathname"
require "net/ssh"
require "net/ssh/gateway"

require "cct"
require "matrix/version"
require "matrix/errors"
require "matrix/base_logger"
require "matrix/cct"
require "matrix/admin_node"
require "matrix/target"
require "matrix/config"
require "matrix/utils"
require "matrix/local_command"
require "matrix/remote_command"
require "matrix/rake/dsl"
require "matrix/tasks/story_task"
require "matrix/tasks/runner_task"
require "matrix/tasks/feature_task"
require "matrix/runners/mkcloud"
require "matrix/runners/virtsetup"

module Matrix
  LOG_TAG = "MATRIX"
  LOG_FILENAME = "matrix.log"
  LOG_DIR = "log/"

  class << self
    attr_reader :root, :user, :logger, :config, :hostname, :log_path, :cct, :command
    attr_reader :targets

    def configure root_dir, logger: nil, verbose: false, log_path: nil
      @verbose = verbose == true
      @root = Pathname.new(root_dir)
      @config = Config.new
      @user = LocalUser.new
      @hostname = `hostname -f 2>&1`.strip rescue "(unknown)"
      @log_path = log_path || root.join(LOG_DIR, LOG_FILENAME)
      @logger = logger || BaseLogger.new(
        LOG_TAG, verbose: verbose?, path: @log_path
      ).base
      @command = LocalCommand.new("MATRIX", logger: @logger)
      @cct = Matrix::Cct.new(verbose?,root.join(LOG_DIR, ::Cct::LOG_FILENAME).expand_path)
      @targets = Targets.new(config)
      self
    end

    def verbose?
      @verbose
    end

    def update_logger base_logger
      @logger = base_logger.base
    end

    def build_story_tasks!
      config["story"].each {|story| StoryTask.new(*story) }
    end

    def load_tasks subdir=nil
      path = subdir ? "/tasks/#{subdir}/*.rake" : "/tasks/*.rake"
      Rake::TaskManager.record_task_metadata = true
      Dir.glob(root.to_s + path).each do |task|
        load task
      end
    end
  end

  class LocalUser  < ::Cct::LocalUser; end
end


