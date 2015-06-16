module Matrix
  class LocalCommand
    Result = Struct.new(:success?, :output, :exit_code, :host)

    attr_reader :log, :environment, :capture

    attr_accessor :tracker

    def initialize tag=nil, logger: nil, capture: true
      @log = logger || BaseLogger.new(tag || "LOCAL")
      @environment = {}
      @capture = capture
    end

    def exec! command_name, *args
      command = "#{command_name} #{args.join(" ")}".strip

      log.info("Running command `#{command}`")
      result = Result.new(false, "", 1000, Matrix.hostname)

      IO.popen(command, :err=>[:child, :out]) do |lines|
        lines.each do |line|
          result.output << line if capture
          log_command_output(line)
        end
      end

      result[:success?] = $?.success?
      result.exit_code = $?.exitstatus
      if !result.success?
        log.error(
          "#{result.host}: Command `#{command}` " +
          "failed with '#{result.output.strip}' " +
          "and status #{result.exit_code} "
        )
        raise LocalCommandFailed.new(result)
      end

      return result

    rescue Errno::ENOENT => e
      result.output << "Command `#{command_name}` not found"
      log.error("#{result.host}: #{result.output}")
      raise LocalCommandFailed.new(result)
    end

    def update_env env_hash
      environment.merge!(env_hash)
    end

    private

    def log_command_output line
      case line.chomp
      when /warn|cannot/i
        log.warn(line)
      when /error/i
        log.error(line)
      else
        log.info(line)
      end
    end
  end

end
