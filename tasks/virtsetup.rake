namespace :virtsetup do
  desc "Detach image file"
  task :detach_image do
    virtsetup.detach_story_image
  end

  desc "Create image"
  task :create_image do
    virtsetup.create_image
    story.config["cloudpv"] = detect_loop_device(story.name)
  end

  desc "Configure loop device"
  task :config_loop do
    virtsetup.configure_loop_device
  end
end
