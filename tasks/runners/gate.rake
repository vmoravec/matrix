namespace :gate do
  desc "Prepare libvirt domain for crowbar"
  task :prepare_admin_domain do
    story = Matrix::Story.new
    puts story.runners
    abort "END"
  end
end
