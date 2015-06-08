module Rake
  module DSL
    def matrix
      Matrix
    end

    def mkcloud
      @mkcloud ||= Matrix::Mkcloud.new
    end

    def virtsetup
      @virtsetup ||= Matrix::Virtsetup.new
    end

    def gate
      @gate ||= Matrix::Gate.new
    end

    def command
      Matrix.command
    end

    def targets
      Matrix.targets
    end

  end
end
