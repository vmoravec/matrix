namespace :stories do
  task :all do
    Matrix.build_story_tasks!
    Rake.application.options.show_tasks = :tasks
    Rake.application.options.show_task_pattern = /story/
    Rake.application.display_tasks_and_comments
  end
end

desc "List all stories"
task :stories => "stories:all"
