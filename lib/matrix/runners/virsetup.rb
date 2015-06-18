module Matrix
  class VirsetupRunner < Runner

    LOG_TAG = "VIRSETUP"
    LOSETUP_BIN = "/sbin/losetup"
    MODPROBE_BIN = "/sbin/modprobe"
    TEMP_DIR = "tmp/"
    IMAGE = "story_image.img"

    attr_reader :environment, :command
    attr_reader :image_file, :image_size

    def initialize
      @log = Matrix.logger
      super do
        @command =
          if gate.localhost?
          LocalCommand.new
        else
          RemoteCommand.new(
            ip: gate.ip || gate.fqdn,
            user: gate.user
          )
        end
      end
      @image_file = Pathname.new(Matrix.root.join(TEMP_DIR, IMAGE))
      @image_size = config["virsetup"]["image_size"]
    end

    def configure
      configure_image
      configure_loop_device
      update_mkcloud_config("cloudpv" => detect_loop_device)
    end

    def configure_loop_device
      modprobe_loop
      device_info = detect_loop_device
      if device_info
        message = "   Image #{image_file} is already attached to #{device_info}"
        log.warn(message)
        puts message
      else
        losetup(find_available_loop_device, image_file.realpath)
      end
    end

    def detach_image
      device = detect_loop_device
      return unless device

      losetup("-d", device)
    end

    def detect_loop_device
      path = File.exist?(image_file) ? image_file.realpath : image_file
      result = losetup("-j", path).output.split(":").first
      puts result unless story.task
      result
    end

    def modprobe_loop
      exec!("modprobe loop")
    end

    def create_image
      message = "Creating image file in `#{image_file}"
      puts message
      log.info(message)
      exec!("qemu-img create -f raw #{image_file} #{image_size}")
    end

    def configure_image
      if File.exist?(image_file)
        create_filesystem
      else
        create_image
        create_filesystem
      end
    end

    def update_mkcloud_config options
      options.each_pair do |key, value|
        config["mkcloud"][key] = value
      end
    end

    def create_filesystem
      puts "   Creating new filesystem in `#{image_file}"
      exec!("mkfs -t ext4 #{image_file.realpath}")
    end

    def losetup *args
      exec!("#{LOSETUP_BIN} #{args.join(' ')}")
    end


    def find_available_loop_device
      losetup("-f").output.strip
    end

  end
end
