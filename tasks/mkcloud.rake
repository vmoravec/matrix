namespace :mkcloud do
  desc "Cleanup leftovers from last run"
  task :cleanup, [:story_name, :env] do |_, args|
    with_utils do
      mkcloud.exec! :cleanup, detect_config!(args[:story_name], args[:env]).first
    end
  end

  desc "Prepare the environment for cloud installation"
  task :prepare, [:story_name, :env] do |_, args|
    with_utils do
      config, story_name = detect_config!(args[:story_name], args[:env])
      create_image(story_name, config["lvm_size"])
      log(:matrix).info "Preparing story '#{story_name}' with config:"
      log(:matrix).info config.to_yaml
      mkcloud.exec! :prepare, config
    end
  end

  def with_utils
    include Matrix::Utils::Mkcloud
    yield
  end
end
