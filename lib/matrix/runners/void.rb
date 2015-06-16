module Matrix
  class Void < Runner

    def initialize
      super do
        @command = LocalCommand.new
      end
    end

  end
end
