require 'rake/tasklib'

module Matrix
  class StoryTask < ::Rake::TaskLib
    attr_reader :name, :config

    def initialize name, config
      @name = name
      @config = config
      @verbose = Matrix.verbose?
      define_tasks
    end

    private

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
            puts config["runners"].keys
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
