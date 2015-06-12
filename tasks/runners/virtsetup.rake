namespace :virtsetup do
  desc "Detach image file"
  task :detach_image do
    virtsetup.detach_image
  end

  desc "Create image"
  task :create_image do
    virtsetup.create_image
  end

  desc "Enable kernel module 'loop'"
  task :modprobe_loop do
    virtsetup.modprobe_loop
  end

  desc "Configure loop device"
  task :configure_loop_device do
    virtsetup.configure_loop_device
  end

  desc "Clear all loop devices"
  task :detach_all do
    include Matrix::Utils::User

    command.exec!("#{sudo} losetup -D")
  end
end
