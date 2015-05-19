namespace :runners do
  task :list do
    Matrix.load_tasks("runners")
    Rake::TaskManager.record_task_metadata = true
    Rake.application.options.show_tasks = :tasks
    Rake.application.options.show_task_pattern = /(mkcloud|virtsetup)/ #FIXME create a Matrix.runners list
    Rake.application.display_tasks_and_comments
  end
end

desc "List of all runners"
task :runners => "runners:list"
