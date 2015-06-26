namespace :virsetup do
  desc "Setup for virtual deployment ready"
  task :configure do
    virsetup.configure
  end

  desc "Detach image file"
  task :detach_image do
    virsetup.detach_image
  end

  desc "Detect loop device"
  task :detect_loop_device do
    virsetup.detect_loop_device
  end

  desc "Enable kernel module 'loop'"
  task :modprobe_loop do
    virsetup.modprobe_loop
  end

  desc "Create image"
  task :create_image do
    virsetup.create_image
  end
end
