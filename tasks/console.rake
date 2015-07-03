desc "Start console"
task :console do
  require 'irb'
  require 'ap'

  ARGV.clear
  Matrix.update_logger(Cct::BaseLogger.new('console', stdout: true))
  matrix.logger.info "Starting console (irb session)" 

  IRB.start(__FILE__)
end
