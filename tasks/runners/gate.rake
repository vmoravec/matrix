namespace :gate do
  desc "Prepare libvirt domain for crowbar"
  task :prepare_admin_domain do
    man = Matrix::StoryManager.new
    puts man.inspect
    abort "END"
  end
end
