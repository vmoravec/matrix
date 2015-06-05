require "json"

module Matrix
  class Tracker
    attr_reader :name, :type, :runners, :features, :success, :start_at, :end_at
    attr_accessor :error

    # Runner attributes
    attr_accessor :timeout
    attr_accessor :stage
    attr_accessor :command
    attr_accessor :environment

    def initialize type, name
      @name = name
      @type = type
      @features = []
      @runners = []
      @start_at = Time.now
    end

    def end_now
      @end_at = Time.now
    end

    def success!
      end_now
      @success = true
    end

    def failure! error
      end_now
      @error = error
      @success = false
    end

    def data
      output = {
        type: type,
        name: name,
        success: success,
        start_at: start_at,
        end_at: end_at
      }

      output.merge!(
        timeout: timeout,
        stage: stage,
        command: command,
        features: features.map(&:data)
      ) if type == :runner

      output.merge!(runners: runners.map(&:data)) if type == :story
      output.merge!(error: error) unless success
      output
    end

    def to_json
      data.to_json
    end

    def dump!
      return if Matrix.dryrun?

      path = Matrix.root.join(Matrix::LOG_DIR, "story.json")
      File.delete(path) if File.exist?(path)
      File.write(path, to_json)
    end
  end
end
