namespace :mkcloud do
  desc "Cleanup leftovers from last run"
  task :cleanup, [:story_name, :env] do |_, args|
    with_utils do
      mkcloud.exec! :cleanup, detect_config!(args[:story_name], args[:env]).first
    end
  end

  desc "Prepare the environment for cloud installation"
  task :prepare, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      create_image(story.name, story.config["lvm_size"])
      configure_loop_device
      log(:matrix).info "Preparing story '#{story.name}' with config:"
      log(:matrix).info story.config.to_yaml
      mkcloud.exec! :prepare, story.config
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
end
