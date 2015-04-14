require "pathname"

require "cct"
require "matrix/version"
require "matrix/cct"
require "matrix/config"
require "matrix/dsl"
require "matrix/story_task"
require "matrix/runner_task"
require "matrix/feature_task"
require "matrix/utils"

#FIXME hackish mockish
LocalUser = ::Cct::LocalUser
BaseLogger = ::Cct::BaseLogger
LocalCommand = ::Cct::LocalCommand

require "matrix/mkcloud"

module Matrix
  LOG_TAG = "MATRIX"
  LOG_FILENAME = "matrix.log"
  LOG_DIR = "log/"

  class << self
    attr_reader :root, :user, :logger, :config, :hostname, :log_path, :cct, :command

    def setup root_dir, logger: nil, verbose: false, log_path: nil
      @verbose = verbose == true
      @root = Pathname.new(root_dir)
      @config = Config.new
      @user = LocalUser.new
      @hostname = `hostname -f 2>&1`.strip rescue "(uknown)"
      @log_path = log_path || root.join(LOG_DIR, LOG_FILENAME)
      @logger = logger || BaseLogger.new(
        LOG_TAG, verbose: verbose?, path: @log_path
      ).base
      @command = LocalCommand.new("MATRIX", logger: @logger)
      @cct = Matrix::Cct.new(verbose?,root.join(LOG_DIR, ::Cct::LOG_FILENAME).expand_path)
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
  end
end
