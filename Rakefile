#!/bin/env rake

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

require "matrix"

Matrix.configure(__dir__, verbose: verbose)
Matrix.load_tasks
Matrix.build_story_tasks!
