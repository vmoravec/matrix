module Matrix
  class Mkcloud < Runner
    LOG_TAG = "MKCLOUD"
    COMMAND = "mkcloud"
    SCRIPT_DIR = "automation/scripts/"

    attr_reader :bin, :log

    def initialize
      super do
        @log = BaseLogger.new(
          LOG_TAG,
          path: Matrix.root.join(LOG_DIR, "mkcloud.log")
        )
        @bin = Matrix.config["vendor_dir"] + SCRIPT_DIR + COMMAND
        @command =
          if gate.localhost?
            LocalCommand.new(logger: log, capture: false)
          else
            abort "mkcloud is supported running only on localhost"
          end
      end
    end

    def exec! action
      environment = config["mkcloud"].inject("") do |env, config_pair|
        key, value = config_pair
        env << "#{key}=#{value} "
      end
      @environment = environment
      super(action)
    end

  end
end
