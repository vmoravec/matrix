require 'rake/tasklib'

module Matrix
  class StoryTask < ::Rake::TaskLib
    attr_reader :name, :data

    def initialize name, data
      @name = name
      @data = data
      @verbose = Matrix.verbose?
      define_tasks
    end

    private

    def run_task name
      data["runners"]
      .map {|runner| RunnerTask.new(runner << data["mkcloud"]) }
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
            puts data["runners"].keys
          end

          # Not showing task desc on purpose
          task :features do
            data["runners"].each_pair do |runner, features|
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

        desc data["desc"]
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
