require 'json'

module Matrix
  class TempestRunner < Runner
    extend Forwardable

    def_delegators :@mkcloud, :exec!

    def initialize
      @type = :delegated
      @mkcloud = MkcloudRunner.new(
        recorder: TempestRecorder.new
      )
    end

    def run
      exec! "testsetup"
    end
  end

  class TempestRecorder < Recorder
    OK = "ok"
    FAILED = "FAILED"
    RESULT = /\.{3}\s+(#{OK}|#{FAILED})$/
    FULL = /(tempest\.\w+\.\w+)\.(.+)/

    self.match   = /(tempest\.(\w+)\.(\w+))/
    self.summary = /Ran \d+ tests in .+/

    attr_reader :results

    def initialize
      super
      @results = {
        ok:     Hash.new {|hash, key| hash[key] = [] },
        failed: Hash.new {|hash, key| hash[key] = [] }
      }
    end

    def parse
      buffer.each do |record|
        res = record.rstrip.match(RESULT)
        next if res.nil?

        case res.captures.first
        when OK
          save_record(:ok, record)
        when FAILED
          save_record(:failed, record)
        end
      end
    end

    def save_record type, record
      tempest_results = record.match(FULL)
      return if tempest_results.nil?

      namespace, details = tempest_results.captures
      results[type][namespace] << details
    end

    def dump_data
      parse
      puts results.to_json
    end
  end
end
