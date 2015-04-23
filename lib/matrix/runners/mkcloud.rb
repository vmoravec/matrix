module Matrix
  class Mkcloud < LocalCommand
    include Utils::User

    COMMAND    = "mkcloud"
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

    attr_reader :bin_path, :log

    def initialize
      @log = BaseLogger.new("MATRIX", verbose: true, path: Matrix.log_path)
      @bin_path = Matrix.config["vendor_dir"] + SCRIPT_DIR
    end

    #TODO update & validate the config before sending the request to mkcloud
    def exec! action, env
      command = bin_path + COMMAND
      super("#{sudo} #{env.map {|c| "#{c[0]}=#{c[1]}" }.join(" ")} #{command} #{action}")
    end

    def update_config config, story_name
      log(:matrix).info "Updating story config: cloud => #{story_name}"
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
