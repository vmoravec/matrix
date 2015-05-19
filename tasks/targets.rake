namespace :target do
  namespace :qa2 do
    task :gate do
      puts "SSH to gate qa2"
    end
  end

  desc "Test availability of qa2 gate"
  task :qa2 => "qa2:gate"
end
