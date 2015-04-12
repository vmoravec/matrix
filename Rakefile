#!/bin/env rake

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require "matrix"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

Matrix.setup(__dir__, verbose: verbose)

Dir.glob(__dir__ + "/tasks/**/*.rake").each { |task| load(task) }
