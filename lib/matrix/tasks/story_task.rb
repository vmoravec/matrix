require 'rake/tasklib'

module Matrix
  class StoryTask < ::Rake::TaskLib
    attr_reader :name, :config, :runners

    def initialize name, config
      @name = name
      @config = config
      Matrix.logger.debug("Using this story configuration: #{config.inspect}")
      @runners = config["runners"]
      @stages = detect_stages
      @verbose = Matrix.verbose?
      define_tasks
    end

    private

    def detect_stages
      runners.map do |name, attributes|
        #Stage.new(name,

      end
    end

    def current_stage
    end

    def run_task name
      config["runners"]
      .map {|runner| RunnerTask.new(name, runner << config) }
      .each(&:invoke)
    end

    def define_tasks
      namespace :story do
        namespace name do
          task :run  do
            run_task(name)
          end

          # Not showing task desc on purpose
          task :runners do
            puts runners.keys
          end

          # Not showing task desc on purpose
          task :stages do
            stages = {}
            current_stage = nil
            current_runners = []
            config["runners"].each_pair do |key, values|
              next if values.nil?#&& current_stage.nil?
              next unless values["stage"]

              current_stage = values["stage"] if current_stage != values["stage"]
              current_runners = [] if key != current_stage

              current_runner = key
              #current_runners << current_runner

              if values.is_a?(Hash) && values["features"]
                abort "Missing stage name at #{key}" unless values["stage"]
              #puts values.inspect
              end
              current_stage = values["stage"] if values["stage"] || current_stage
              current_runners << key if current_stage

              stages[current_stage] = current_runners
            end
            puts stages.inspect
          end

          # Not showing task desc on purpose
          task :features do
            config["runners"].each_pair do |runner, features|
              puts runner
              next if features.nil?

              features = resolve_features(features)
              if features.nil?
                next
              elsif features.empty?
                next
              end
              puts features
            end
          end
        end

        desc config["desc"]
        task name => "story:#{name}:run"
      end

      # Nested method
      def resolve_features features
        case features
        when String
          nil
        when Hash
          feats = features["features"]
          return if feats.nil?
          return if feats.empty?
          resolve_scenarios(feats)
        end
      end

      # Nested method
      def resolve_scenarios features
        scenarios = ""
        features.each_pair do |feature_name, scenars|
          scenes = "#{scenars.map {|s| "    - #{s}"}.join("\n")}\n" if scenars
          scenarios << "  #{feature_name}\n#{scenes}"
        end
        scenarios
      end
    end

  end
end
