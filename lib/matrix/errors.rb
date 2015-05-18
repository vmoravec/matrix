module Matrix
  class LocalCommandFailed < StandardError
    def initialize result
      super("#{result.output.strip}\nHost: #{result.host}")
    end
  end

  class SshConnectionError < StandardError
    def initialize options={}
      message = "SSH connection to #{options[:ip]} failed\n#{options[:message]}"
      message << "\nTimeout #{options[:timeout]} seconds" if options[:timeout]
      super(message)
    end
  end

  class ValidationError < StandardError
    def initialize klass, messages=[]
      message = "for #{klass} "
      message << messages.shift
      message << messages.join(", ")
      super(message)
    end
  end

  class RemoteCommandFailed < StandardError
    def initialize command, result
      super("`#{command}` failed.\n#{result.output}Host: #{result.host}")
    end
  end

end
