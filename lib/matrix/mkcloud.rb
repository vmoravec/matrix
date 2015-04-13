module Matrix
  class Mkcloud < LocalCommand
    COMMAND  = "mkcloud"

    attr_reader :bin_path

    def initialize
      @log = BaseLogger.new("MKCLOUD")
      @bin_path = Matrix.config["vendor_dir"] + "automation/scripts/"
    end

    def exec! action, env
      command = bin_path + COMMAND
      env = env[:env]
      puts env.inspect
      #TODO export the environment variables from env
      super("sudo #{env.map {|c| "#{c[0]}=#{c[1]}" }.join(" ")} #{command} #{action}")
    end
  end
end
