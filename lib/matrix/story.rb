module Matrix
  class Story
    attr_reader :name, :current_target, :config, :targets, :target_error, :desc
    attr_reader :tracker

    attr_accessor :task, :target_error, :runner_options

    def initialize name: nil, current_target: nil, config: nil
      @name = name || ENV["story"]
      abort "Missing story name, try with story=STORY_NAME" unless self.name

      @tracker = Tracker.new(:story, name)
      @config = config || Matrix.config["story"][self.name]
      abort "Config for story '#{self.name}' missing" if self.config.nil? || self.config.empty?

      @desc = self.config["desc"]
      abort "Story description not found in config" unless self.desc

      self.target_error = Proc.new {}
      @targets = self.config.keys.reject {|t| t == "desc" }.map do |target|
        Matrix.targets.find(target)
      end.flatten

      @current_target = current_target || find_target(ENV["target"])
      if @current_target.nil?
        self.target_error = Proc.new do
          abort "Target missing for story '#{self.name}'. " +
                "Try with target=TARGET"
        end
      end

      @runner_options = {}
    end

    alias_method :target, :current_target

    def runners
      group_runners || []
    end

    def find_target target_name
      targets_available = "Targets available: \n#{Matrix.targets.only(targets.map(&:name))}"
      if target_name.nil? || target_name.to_s.empty?
        missing_target = "No target provided for story '#{name}', try with target=TARGET"
        self.target_error = Proc.new { abort missing_target + targets_available }
        return
      end
      target = targets.find {|t| t.name == target_name }
      if target.nil?
        not_found = "Target '#{target_name}' not found for story '#{name}'. "
        self.target_error = Proc.new { abort not_found + targets_available }
        return
      end

      target
    end

    def finalize!
      if @finalized && block_given?
        yield self
      end

      return if @finalized

      target_error.call
      @config = config[current_target.name]
      @finalized = true
      yield self if block_given?
    end

    alias_method :begin, :finalize!

    private


    # Configuration merging on a list of runners
    # This resolves missing deep merge strategy for arrays as hash values which
    # is case of runners
    def group_runners
      @grouped = []
      runners = config["runners"]
      runner_names = runners.map(&:keys).flatten
      grouped = runner_names.group_by {|name| name}
      runners.map do |runner_details|
        name = runner_details.keys.first
        if grouped[name].size > 1
          if @grouped.include?(name)
            next
          else
            selected = runners.select {|r| r.keys.first == name }
            base_details = selected.shift
            selected.each {|runner| base_details.deep_merge!(runner)}
            @grouped << name
            base_details
          end
        else
          runner_details
        end
      end.compact
    end

  end
end
