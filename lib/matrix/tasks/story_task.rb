require 'rake/tasklib'

module Matrix
  class StoryTask < ::Rake::TaskLib
    attr_reader :name, :config, :runners, :log, :targets

    def initialize name, config
      @name = name
      @config = config
      @targets = config.keys
      @verbose = Matrix.verbose?
      @log = Matrix.logger
      log.debug("Using this story configuration: #{config.inspect}")
      define_tasks
    end

    private

    def run_story target
      main_config = config[target].reject {|k,v| k == "runners"}
      runners.map {|runner| RunnerTask.new(name, target, runner << main_config)}.each(&:invoke)
    end

    def fail!
      abort "Target for story '#{name}' not provided" unless current_target
    end

    def target_present
      raise "Target for story '#{name}' not provided" unless current_target
      raise "No runners defined for story '#{name}'" if runners.nil?
      yield
    end

    def runners target
      config[target]["runners"]
    end

    def define_tasks
      namespace :story do
        namespace name do
          config.keys.each do |target|
            task :run  do
              run_story(target)
            end

            # Not using task desc on purpose
            task :config do
              require "awesome_print"
              ap filter_story(name)
            end

            # Not showing task desc on purpose
            task :runners do
              puts runners.keys
            end

            # Not showing task desc on purpose
            task :targets do
              puts targets
            end

            # Not showing task desc on purpose
            task :stages do
              stages = []
              current_stage = nil
              runners.each_pair do |runner_name, children|
                if (children.nil? || children.empty?) && current_stage.nil?
                  stages << { "No stage" => [ runner_name, { features:{} } ] }
                  next
                end

                if (children.nil? || children.empty?) && current_stage
                  stages << { current_stage => [ runner_name, {features: {}} ] }
                  warn_on_missing_features(current_stage, runner_name)
                  next
                end

                if (children.nil? || children.empty?)
                  stages << {"No stage" => [ runner_name, {features: {}} ] }
                  current_stage = nil
                  next
                end

                if children.has_key?("stage") && children["stage"].nil?
                  stages << {"No stage" => [ runner_name, { features: children["features"] || {}} ]}
                  current_stage = nil
                  next
                end

                if children["stage"]
                  stages << {children["stage"] => [ runner_name, {features: children["features"] || {}} ] }
                  current_stage = children["stage"]
                  warn_on_missing_features(current_stage, runner_name, children)
                  next
                end
              end
              puts stages.inspect
            end

            # Not showing task desc on purpose
            task :features do
              runners(target).each_pair do |runner, features|
                puts runner
                next if features.nil?

                features = resolve_features(features)
                next if features.nil? || features.empty?
                puts features
              end
            end

            desc config[target]["desc"]
            task target => "story:#{name}:#{target}:run"
          end
        end
      end

      # Nested method
      def filter_story story, target
        abort "No configuration found for any stories" if matrix.config["story"].nil?

        result = matrix.config["story"][story][target]
        abort "No configuration found for story '#{story}'" if result.nil?

        puts "Showing config for story '#{story}' and target '#{target}':"
        result
      end

      # Nested method
      def warn_on_missing_features stage_name, runner_name, nodes={}
        log.warn(
        "Stage '#{stage_name}' in runner '#{runner_name}' has no features"
        ) unless nodes["features"]
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
