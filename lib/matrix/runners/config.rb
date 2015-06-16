module Matrix
  class ConfigRunner < Runner
    def initialize
      @native = true
      super
    end

    def proposals
      config["proposals"]
    end
  end
end
