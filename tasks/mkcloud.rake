namespace :mkcloud do
  desc "Cleanup leftovers from last run"
  task :cleanup do
    mkcloud.exec! :cleanup
  end

  desc "Prepare the environment for cloud installation"
  task :prepare do
      mkcloud.exec! :prepare, story.config
    end
  end

  desc "Install controller node"
  task :install_control_node do
    mkcloud.exec! :install_control_node, matrix.config["current_story"]
  end

  desc "Enable modprobe"
  task :modprobe_loop do
    virtsetup.modprobe_loop
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

  desc "Set up & install controller and compute nodes"
  task :installnodes, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      mkcloud.exec!(
        "setupcompute instcompute",
        story.config
      )
    end
  end

  desc "Install default proposal"
  task :installproposal, [:story_name, :env] do |_, args|
    detect_config(args) do |story|
      mkcloud.exec!(
        "proposal",
        story.config
      )
    end
  end

  desc "Show the full path to mkcloud script"
  task :binpath do
    puts Matrix.root.join(
      matrix.config["vendor_dir"],
      Matrix::Mkcloud::SCRIPT_DIR,
      Matrix::Mkcloud::COMMAND
    )
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
