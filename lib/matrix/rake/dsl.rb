module Rake
  module DSL
    def matrix
      Matrix
    end

    def story
      @story ||= Matrix::Story.new
    end

    def mkcloud
      @mkcloud ||= Matrix::MkcloudRunner.new
    end

    def virsetup
      @virsetup ||= Matrix::VirsetupRunner.new
    end

    def gate
      @gate ||= Matrix::GateRunner.new
    end

    def qa_crowbarsetup
      @qa_crowbar ||= Matrix::QaCrowbarSetupRunner.new
    end

    def crowbar
      @crowbar ||= Matrix::CrowbarRunner.new
    end

    def void
      @void ||= Matrix::Void.new
    end

    def config_runner
      @config_runner ||= Matrix::ConfigRunner.new
    end

    def admin_vm
      @admin_vm ||= Matrix::AdminVmRunner.new
    end

    def tempest
      @tempest ||= Matrix::TempestRunner.new
    end

    def command
      Matrix.command
    end

    def targets
      Matrix.targets
    end

    def log
      Matrix.logger
    end

    def wait_for event, options
      period, period_units = options[:max].split
      sleep_period, sleep_units = options[:sleep].split if options[:sleep]
      timeout_time = convert_to_seconds(period, period_units)
      sleep_time = convert_to_seconds(sleep_period, sleep_units)
      log.info("Setting timeout to '#{event}' to max #{options[:max]}")
      timeout(timeout_time) do
        (timeout_time / sleep_time).times do
          yield
          if options[:sleep]
            log.info("Waiting for '#{event}', sleeping for more #{options[:sleep]}")
            sleep(sleep_time)
          end
        end
      end
    rescue Timeout::Error
      message = "Failed to make #{event}, tiemout after #{options[:max]}"
      log.error(message)
      raise message
    end

    def convert_to_seconds period, units
      case units
      when /minute/
        period.to_i * 60
      when /second/
        period.to_i
      when nil
        0
      else
        raise "Only minutes or seconds are allowed"
      end
    end

  end
end
