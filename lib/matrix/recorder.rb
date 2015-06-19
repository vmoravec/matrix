module Matrix
  class Recorder
    class << self
      attr_accessor :match
      attr_accessor :summary
    end

    attr_reader :buffer

    def initialize
      @buffer = []
    end

    def capture line
      buffer << line if line.match(self.class.match)
    end

    def dump_data
      raise NotImplementedError
    end
  end
end
