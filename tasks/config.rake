desc "Show configuration"
task :config do
  require "awesome_print"

  ap Matrix.config.content
end
