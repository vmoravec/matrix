namespace :targets do
  task :list do
    Matrix.load_tasks("targets")
    Rake.application.options.show_tasks = :tasks
    Rake.application.options.show_task_pattern = /target:/
    Rake.application.display_tasks_and_comments
  end
end

desc "List all targets to deploy cloud on"
task :targets => "targets:list"


