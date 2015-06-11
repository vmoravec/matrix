module Matrix
  class Mkcloud < Runner
    LOG_TAG = "MKCLOUD"
    COMMAND = "mkcloud"
    SCRIPT_DIR = "automation/scripts/"
    MANDATORY_CONF_KEYS = %w(
      cloud
      cloudpv
      virtualcloud
      cloudsource
      net_public
      net_fixed
      net_admin
      adminnetmask
      networkingplugin
    )

    include Utils::User

    attr_reader :bin_path, :log

    def initialize
      super
      @log = BaseLogger.new(LOG_TAG)
      @command = LocalCommand.new(LOG_TAG, runner: self)
      @bin_path = Matrix.config["vendor_dir"] + SCRIPT_DIR + COMMAND
    end

    def binpath
      Matrix.root.join(Matrix.config["vendor_dir"], SCRIPT_DIR, COMMAND)
    end

    def exec! action
      command.exec!(
        "#{sudo} #{bin_path} #{action}"
      )
    end

    def update_mkcloud_config
      log.info "Updating story config: cloud => #{story.name}"
      config["cloud"] = story.name
      config["cloudpv"] = detect_loop_device(story.name) || find_available_loop_device
      config["cloudbr"] = story.name + "-br"
      config["virtualcloud"] = story.name
      config
    end

    def validate_mkcloud_config! config
      MANDATORY_CONF_KEYS.each do |key|
        if !config.keys.include?(key)
          abort "Invalid mkcloud config, missing '#{key}' value"
        end
      end
      config
    end

  end
end
