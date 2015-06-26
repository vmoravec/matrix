module Matrix
  class MkcloudRunner < Runner
    LOG_TAG = "MKCLOUD"
    COMMAND = "mkcloud"
    SCRIPT_DIR = "automation/scripts/"

    attr_reader :bin, :log

    def initialize recorder: nil, logger: nil
      @recorder = recorder
      super do
        @log = logger || BaseLogger.new(
          LOG_TAG,
          path: Matrix.root.join(LOG_DIR, "mkcloud.log")
        )
        @bin = Matrix.config["vendor_dir"] + SCRIPT_DIR + COMMAND
        @command =
          if gate.localhost?
            LocalCommand.new(logger: log, capture: false, recorder: recorder)
          else
            abort "mkcloud is supported running only on localhost"
          end
      end
    end

    def exec! action
      environment = config["mkcloud"].inject("") do |env, config_pair|
        key, value = config_pair
        value.to_s.empty? ? env : env << "#{key}=#{value} "
      end
      @environment = environment
      super(action)
    end

    def cleanup
      virsetup = VirsetupRunner.new
      exec!(:cleanup) if virsetup.detect_loop_device
      virsetup.detach_image
    end

  end
end
