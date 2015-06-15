namespace :virtsetup do
  desc "Configure loop device"
  task :configure_loop_device do
    virtsetup.configure_loop_device
  end

  desc "Create image"
  task :configure_image do
    virtsetup.configure_image
  end

  desc "Detach image file"
  task :detach_image do
    virtsetup.detach_image
  end

  desc "Detect loop device"
  task :detect_loop_device do
    virtsetup.detect_loop_device
  end

  desc "Enable kernel module 'loop'"
  task :modprobe_loop do
    virtsetup.modprobe_loop
  end
end
