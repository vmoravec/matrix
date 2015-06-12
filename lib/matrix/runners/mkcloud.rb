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
        @command = LocalCommand.new(logger: log)
        @bin = Matrix.config["vendor_dir"] + SCRIPT_DIR + COMMAND
      end
    end

    def update_mkcloud_config
      log.info "Updating story config: cloud => #{story.name}"
      config["cloud"] = story.name
      config["cloudpv"] = detect_loop_device(story.name) || find_available_loop_device
      config["cloudbr"] = story.name + "-br"
      config["virtualcloud"] = story.name
      config
    end

    def cleanup
      exec! "echo hell"
    end

  end
end
