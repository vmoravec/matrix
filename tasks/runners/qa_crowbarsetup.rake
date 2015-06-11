namespace :qa_crowbarsetup do
  desc "Test"
  task :test do
    qa_crowbarsetup.exec! "ls"
  end
end
