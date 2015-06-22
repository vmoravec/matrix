namespace :log do
  desc "Remove all log files"
  task :cleanup do
    FileList["log/**/*.*"].each do |file|
      rm file
    end
  end
end
