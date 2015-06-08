module Matrix
  class StoryManager
    attr_reader :story_name, :current_target, :config, :targets, :target_error

    def initialize name: nil, current_target: nil, config: nil
      @story_name = name   || ENV["story"]
      abort "Missing story name, don't know where to start" unless story_name

      @config = config || Matrix.config["story"][story_name]
      abort "Config for story '#{story_name}' missing" if self.config.nil? || self.config.empty?

      @targets = self.config.keys.reject {|k| k == "desc"}.map do |target|
        Matrix.targets.find(target)
      end.flatten
      @current_target = current_target || find_target(ENV["target"])
      abort "Target not found for story '#{story_name}'" unless self.current_target
    end

    def find_target target_name
      targets_available = "Targets available: \n#{Matrix.targets.only(targets.map(&:name))}"
      if target_name.nil? || target_name.to_s.empty?
        missing_target = "No target provided for story '#{story_name}'. "
        @target_error = Proc.new { abort missing_target + targets_available }
        return
      end

      target = targets.find {|t| t.name == target_name }
      if target.nil?
        not_found = "Target '#{target_name}' not found for story '#{story_name}'. "
        @target_error = Proc.new { abort not_found + targets_available }
        return
      end

      target
    end

    def verify!
      target_error.call
    end
  end
end
