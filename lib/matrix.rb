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
require "matrix/story"
require "matrix/tasks/story_task"
require "matrix/tasks/runner_task"
require "matrix/tasks/feature_task"
require "matrix/recorder"
require "matrix/runner"

module Matrix
  LOG_TAG = "MATRIX"
  LOG_FILENAME = "matrix.log"
  LOG_DIR = "log/"

  class << self
    attr_reader :root, :user, :logger, :config, :hostname, :log_path, :cct, :command
    attr_reader :targets

    attr_accessor :current_story

    def configure root_dir, logger: nil, verbose: false, log_path: nil
      @verbose = verbose == true
      @dryrun = !!ENV["dryrun"]
      @root = Pathname.new(root_dir)
      @config = Config.new
      @user = LocalUser.new
      @hostname = set_hostname
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

    def dryrun?
      @dryrun
    end

    def update_logger base_logger
      @logger = base_logger.base
    end

    def build_story_tasks!
      config["story"].each {|story| StoryTask.new(*story) }
    end

    def load_tasks subdir=nil
      #path = subdir ? "/tasks/**/*.rake" : "/tasks/*.rake"
      path = "/tasks/**/*.rake"
      Rake::TaskManager.record_task_metadata = true
      Dir.glob(root.to_s + path).each do |task|
        load task
      end
    end

    private

    def set_hostname
      hostname = `hostname -f`
      return hostname if $?.exitstatus.zero?

      "localhost"
    end
  end

  class LocalUser
    extend Forwardable

    def_delegators :@info, :uid, :gid

    attr_reader :login, :name, :homedir

    def initialize
      if Process.uid.zero?
        @login = "root"
        @name = "root"
        @homedir = "/root/"
      else
        @login = Etc.getlogin
        @info = Etc.getpwnam(login)
        @name = detect_name
        @homedir = @info.dir
      end
    end

    def root?
      Process.uid.zero?
    end

    private

    def detect_name
      name = @info.gecos.split(',').first
      name.to_s.empty? ? login : name
    end
  end
end


