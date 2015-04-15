namespace :cct do
  desc "Load Cct tasks"
  task :tasks => :load_cct do
    features = Rake.application.tasks.select {|task| task.name.match(/\Afeature:\w+/) }
    features.each do |task| puts "rake #{task.name}             #{task.comment}" end
  end

  task :load_cct do
    Rake::TaskManager.record_task_metadata = true
    cct.load_tasks!
  end

  task :admin do
    cct.load_tasks!
    Matrix::FeatureTask.invoke_feature("feature:admin:services", "default")
  end
end
