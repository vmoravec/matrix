namespace :qa_crowbarsetup do
  desc "Test"
  task :test do
    puts qa_crowbarsetup.exec!("ls -al").output
  end
end
