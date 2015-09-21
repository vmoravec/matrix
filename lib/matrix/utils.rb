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

        if options[:sleep]
          sleep_period, sleep_units = options[:sleep].split
          sleep_time = convert_to_seconds(sleep_period, sleep_units)
        end

        timeout_time = convert_to_seconds(period, period_units)
        log.info("Setting timeout to '#{event}' to max #{options[:max]}")
        Timeout.timeout(timeout_time) do
          if options[:sleep]
            (timeout_time / sleep_time).times do
              yield
              if options[:sleep]
                log.info("Waiting for '#{event}', sleeping for more #{options[:sleep]}")
                sleep(sleep_time)
              end
            end
          else
            yield
          end
        end
      rescue Timeout::Error
        message = "Failed to make #{event}, timeout after #{options[:max]}"
        log.error(message)
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
