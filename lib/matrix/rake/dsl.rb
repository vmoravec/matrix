module Rake
  module DSL
    def matrix
      Matrix
    end

    def mkcloud
      @mkcloud ||= Matrix::Mkcloud.new
    end

    def command
      Matrix.command
    end

  end
end
