desc "Start console"
task :console do
  require 'irb'

  ARGV.clear
  Matrix.update_logger(Cct::BaseLogger.new('console', stdout: true))
  matrix.log.info "Starting console (irb session)" 

  IRB.start(__FILE__)
end
