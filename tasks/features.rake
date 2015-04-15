namespace :features do
  task :cct_features => :load_cct do
    Rake.application.options.show_tasks = :tasks
    Rake.application.options.show_task_pattern = /feature:/
    Rake.application.display_tasks_and_comments
  end

  task :load_cct do
    Rake::TaskManager.record_task_metadata = true
    cct.load_tasks!
  end

end

desc "Show all features from cucumber testsuite"
task :features => "features:cct_features"
