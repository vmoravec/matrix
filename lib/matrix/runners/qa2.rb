module Matrix
  class Qa2
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
  end
end
