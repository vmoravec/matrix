desc "Show configuration"
task :config do
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
