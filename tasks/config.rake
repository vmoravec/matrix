desc "Show configuration"
namespace :config do
  desc "Main configuration data"
  task :main do
    config = {}
    keys = matrix.config.content.keys.take_while {|key| !["story", "targets"].include?(key) }
    keys.each {|key| config[key] = matrix.config[key] }
    ap_print(config)
  end

  desc "Targets configuration"
  task :targets do
    ap_print(matrix.config["targets"])
  end

  task :all do
    ap_print do
      story = ENV["story"]
      result = story ? filter_story(story) : matrix.config.content
      ap result
    end
  end

  desc "Development config"
  task :devel do
    ap_print(matrix.config.devel)
  end

  desc "Proposals configs"
  task :proposals do
    ap_print(config_runner.proposals)
  end

  def filter_story story
    abort "No configuration found for any stories" if matrix.config["story"].nil?

    result = matrix.config["story"][story]
    abort "No data found for story '#{story}'" if result.nil?

    puts "Showing config for story '#{story}':"
    result
  end

  def ap_print object=nil
    require "awesome_print"
    if object
      ap object
      return
    end

    if block_given?
      yield
    end
  end
end

desc "Show all configuration data"
task :config => "config:all"
