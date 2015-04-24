module Matrix
  class Mkcloud

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
    include Utils::StoryDetection

    attr_reader :bin_path, :log, :story_name, :environment

    def initialize
      @story_name, @environment = detect_configuration
      update_mkcloud_config
      @log = BaseLogger.new(LOG_TAG)
      @command = LocalCommand.new(LOG_TAG)
      @bin_path = Matrix.config["vendor_dir"] + SCRIPT_DIR + COMMAND
    end

    def exec! action
      return
      command.exec!(
        "#{sudo} #{env.map {|c| "#{c[0]}=#{c[1]}" }.join(" ")} #{bin_path} #{action}"
      )
    end

    def update_mkcloud_config
      log.info "Updating story config: cloud => #{story_name}"
      config["cloud"] = story_name
      config["cloudpv"] = detect_loop_device(story_name) || find_available_loop_device
      config["cloudbr"] = story_name + "-br"
      config["virtualcloud"] = story_name
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
