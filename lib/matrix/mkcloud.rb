module Matrix
  class Mkcloud < LocalCommand
    include Utils::User

    COMMAND    = "mkcloud"
    SCRIPT_DIR = "automation/scripts/"

    attr_reader :bin_path, :log

    def initialize
      @log = BaseLogger.new("MATRIX", verbose: true, path: Matrix.log_path)
      @bin_path = Matrix.config["vendor_dir"] + SCRIPT_DIR
    end

    def exec! action, env
      command = bin_path + COMMAND
      super("#{sudo} #{env.map {|c| "#{c[0]}=#{c[1]}" }.join(" ")} #{command} #{action}")
    end

  end
end
