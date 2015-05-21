namespace :target do
  namespace :qa2 do
    task :gate do
      puts "SSH to gate qa2"
    end
  end

  desc "Test availability of qa2 cluster"
  task :qa2 => "qa2:gate"
end

desc "List all targets"
task :targets do
  puts Matrix.targets.map(&:name)
end
