module Matrix
  class Virtsetup < Runner

    LOG_TAG = "VIRTSETUP"
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
      @image_file = Matrix.root.join(TEMP_DIR, IMAGE).to_s
      @image_size = config["virtsetup"]["image_size"]
    end

    def configure_loop_device
      device_info = detect_loop_device
      if device_info
        message = "   Image #{image_file} is already attached to #{device_info}"
        log.warn(message)
        puts message
      else
        losetup(find_available_loop_device, image_file)
      end
    end

    def detach_image
      device = detect_loop_device
      return unless device

      losetup("-d", device)
    end

    def detect_loop_device
      result = losetup("-j", image_file).output.split(":").first
      puts result unless story.task
      result
    end

    def modprobe_loop
      exec!(*sudo("modprobe loop"))
    end

    def configure_image
      if File.exist?(image_file)
        create_filesystem
      else
        puts "   Creating image file in `#{image_file}"
        exec!("qemu-img create -f raw #{image_file} #{image_size}")
        create_filesystem
      end
      update_mkcloud_config("cloudpv" => detect_loop_device)
    end

    def update_mkcloud_config options
      options.each_pair do |key, value|
        config["mkcloud"][key] = value
      end
    end

    def create_filesystem
      puts "   Creating new filesystem in `#{image_file}"
      exec!("mkfs -t ext4 #{image_file}")
    end

    def losetup *args
      exec!("#{LOSETUP_BIN} #{args.join(' ')}")
    end


    def find_available_loop_device
      losetup("-f").output.strip
    end

  end
end
