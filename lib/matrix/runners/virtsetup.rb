module Matrix
  class Virtsetup < Runner

    LOG_TAG = "VIRTSETUP"
    LOSETUP_BIN = "/sbin/losetup"
    MODPROBE_BIN = "/sbin/modprobe"
    TEMP_DIR = "tmp/"
    IMAGE = "story_image.img"

    include Utils::User

    attr_reader :environment, :command
    attr_reader :image_file, :image_size

    def initialize
      @command = LocalCommand.new(LOG_TAG)
      @image_file = Matrix.root.join(TEMP_DIR, IMAGE).to_s
      @image_size = environment["mkcloud"]["lvm_size"]
    end

    def detach_story_image
      device = detect_loop_device
      return unless device

      losetup("-d", device)
    end

    def detect_loop_device
      losetup("-j", image_file).output.split(":").first
    end

    def modprobe_loop
      command.exec!(*sudo("modprobe loop"))
    end

    def create_image
      if File.exist?(image_file)
        puts "Creating new filesystem in `#{image_file}"
        create_filesystem
      else
        puts "Creating image file in `#{image_file}"
        command.exec!("qemu-img create -f raw #{image_file} #{image_size}")
        create_filesystem
      end
      environment["mkcloud"]["cloudpv"] = detect_loop_device
    end

    def create_filesystem
      command.exec!("#{sudo} mkfs -t ext4 #{image_file}")
    end

    def losetup *args
      command.exec!("#{sudo + LOSETUP_BIN} #{args.join(' ')}")
    end


    def find_available_loop_device
      losetup("-f").output.strip
    end

    def configure_loop_device
      device_info = detect_loop_device
      if device_info
        abort "Image #{image_file} is already attached to #{device_info}"
      else
        losetup(find_available_loop_device, image_file)
      end
    end
  end
end
