namespace :cct do
  desc "Load Cct tasks"
  task :tasks => :load_cct do
    invoke_feature("feature:admin:services")
  end

  task :load_cct do
    cct.load_tasks!
  end
end
