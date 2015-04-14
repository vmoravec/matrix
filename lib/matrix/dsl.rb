module Rake
  module DSL
    def log tag=nil
      if tag && tag == :matrix
        Matrix.logger
      else
        Cct.logger
      end
    end

    def matrix
      Matrix
    end

    def cct
      Matrix.cct
    end

    def mkcloud
      @mkcloud ||= Matrix::Mkcloud.new
    end

    def command
      Matrix.command
    end

  end
end
