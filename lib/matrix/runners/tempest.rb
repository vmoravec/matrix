module Matrix
  class TempestRunner < Runner
    def initialize
      super do
        @command = RemoteCommand.new(
          #TODO
          recorder: TempestRecorder.new
        )
      end
    end
  end
end
