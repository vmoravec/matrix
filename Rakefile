#!/bin/env rake

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require "matrix"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

Matrix.setup(__dir__, verbose: verbose)

Rake::TaskManager.record_task_metadata = true

Dir.glob(__dir__ + "/tasks/**/*.rake").each { |task| load(task) }

Matrix.build_story_tasks!
