module Matrix
  module Utils
    module User
      def sudo *args
        sudo_result = Matrix.user.root? ? "" : "sudo "
        return sudo_result if args.empty?

        sudo_result.empty? ? args : args.unshift(sudo_result)
      end

      def sudo?
        !Matrix.user.root?
      end
    end

    module Helpers

      def wait_for event, options
        period, period_units = options[:max].split
        timeout_time = convert_to_seconds(period, period_units)
        log.info("Setting timeout for '#{event}' to #{options[:max]}")
        Timeout.timeout(timeout_time) do
          yield
        end
      rescue Timeout::Error
        message = "Stage '#{event}' was not reached due to expired timeout (#{options[:max]})"
        raise message
      end

      def convert_to_seconds period, units
        case units
        when /minute/
          period.to_i * 60
        when /second/
          period.to_i
        # when no units are specified, expect seconds were meant
        when nil
          period.to_i
        else
          raise "Only minutes or seconds are allowed for timeout specification"
        end
      end

    end
  end
end
