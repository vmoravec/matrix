module Matrix
  class Virtsetup

    LOSETUP_BIN = "/sbin/losetup"
    MODPROBE_BIN = "/sbin/modprobe"
    TEMP_DIR = "tmp/"

    include Utils::Runner
    include Utils::User

    def detach_story_image
      runner_config do |config|
        device = detect_loop_device(config.story_name)
        return unless device

        losetup("-d", device)
      end
    end

    def detect_loop_device story_name
      losetup("-j", story_file(story_name)).output.split(":").first
    end

    def modprobe_loop
      command.exec!(*sudo("modprobe loop"))
    end

    def story_file name
      Matrix.root.join(TEMP_DIR, name + ".img").to_s
    end

    def command
      LocalCommand.new(logger: Matrix.logger)
    end

    def create_image story_name, size
      path = story_file(story_name)
      if File.exist?(path)
        puts "Creating new filesystem in `#{path}"
        create_filesystem(path)
      else
        puts "Creating image file in `#{path}"
        command.exec!("qemu-img create -f raw #{path} #{size}")
        create_filesystem(path)
      end
      path
    end

    def create_filesystem file
      command.exec!("#{sudo} mkfs -t ext4 #{file}")
    end

    def losetup *args
      command.exec!("#{sudo + LOSETUP_BIN} #{args.join(' ')}")
    end

    alias_method :story_image, :story_file

    def find_available_loop_device
      losetup("-f").output.strip
    end

  end
end
