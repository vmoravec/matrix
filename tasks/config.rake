desc "Show configuration"
namespace :config do
  desc "Main configuration data"
  task :main do
    require "awesome_print"
    config = {}
    keys = matrix.config.content.keys.take_while {|key| !["story", "targets"].include?(key) }
    keys.each {|key| config[key] = matrix.config[key] }
    ap config
  end

  desc "Targets configuration"
  task :targets do
    require "awesome_print"
    ap matrix.config["targets"]
  end

  task :all do
    require "awesome_print"
    story = ENV["story"]
    result = story ? filter_story(story) : matrix.config.content
    ap result
  end

  def filter_story story
    abort "No configuration found for any stories" if matrix.config["story"].nil?

    result = matrix.config["story"][story]
    abort "No data found for story '#{story}'" if result.nil?

    puts "Showing config for story '#{story}':"
    result
  end
end

desc "Show all configuration data"
task :config => "config:all" do
end
