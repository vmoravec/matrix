module Matrix
  class LocalCommandFailed < StandardError
    def initialize result
      super("#{result.output.strip}\nHost: #{result.host}")
    end
  end
end
