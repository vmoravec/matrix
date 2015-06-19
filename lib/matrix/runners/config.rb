module Matrix
  class ConfigRunner < Runner
    def initialize
      @type = :native
      super
    end

    def proposals
      config["proposals"]
    end
  end
end
