namespace :mkcloud do
  desc "Cleanup leftovers from last run"
  task :cleanup, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      mkcloud.exec! :cleanup, story.config
      detach_story_image(story.name)
    end
  end

  desc "Prepare the environment for cloud installation"
  task :prepare, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      create_image(story.name, story.config["lvm_size"])
      configure_loop_device(story.name)
      story.config["cloudpv"] = detect_loop_device(story.name)
      log(:matrix).info "Preparing story '#{story.name}' with config:"
      log(:matrix).info story.config.to_yaml
      mkcloud.exec! :prepare, story.config
    end
  end

  desc "Setup admin node"
  task :setupadmin, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      mkcloud.exec! :setupadmin, story.config
    end
  end

  desc "Install crowbar"
  task :installcrowbar, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      mkcloud.exec!(
        "addupdaterepo runupdate prepareinstcrowbar instcrowbar",
        story.config
      )
    end
  end

  def with_utils
    include Matrix::Utils::Mkcloud
    yield
  end

  Story = Struct.new(:config, :name)

  def detect_config args
    with_utils do
      yield Story.new(*detect_config!(args[:story_name], args[:env]))
    end
  end

  def configure_loop_device story_name
    device_info = detect_loop_device(story_name)
    if device_info
      abort "Image #{story_file(story_name)} is already attached to #{device_info}"
    else
      losetup(find_available_loop_device, story_file(story_name))
    end
  end
end
