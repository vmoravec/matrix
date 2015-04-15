module Matrix
  module Utils
    module Mkcloud
      LOSETUP_BIN = "/sbin/losetup"
      MODPROBE_BIN = "/sbin/modprobe"
      TEMP_DIR = "tmp/"
      MANDATORY_CONF_KEYS = %w(
        cloud
        cloudpv
        virtualcloud
        cloudsource
        net_public
        net_fixed
        net_admin
        adminnetmask
        networkingplugin
      )

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
        command.exec!("mkfs -t ext4 #{file}")
      end

      def losetup *args
        command.exec!("#{sudo + LOSETUP_BIN} #{args.join(' ')}")
      end

      def sudo
        Matrix.user.root? ? "" : "sudo "
      end

      def sudo?
        !Matrix.user.root?
      end

      def detect_config! story_name, env
        validate_base!

        story_name = story_name || ENV["story"]
        if story_name.nil?
          abort "Story name not detected, mkcloud can't continue.." +
                " Try with story=NAME "
        end

        story_config, story_name = detect_story_config!(story_name, env)

        update_config(story_config, story_name)

        validate_mkcloud_config!(story_config)
        [ story_config, story_name ]
      end

      def detect_story_config! name, config
        case config
        when nil
          story = matrix.config["story"][name]
          if story && story["mkcloud"]
            [ story["mkcloud"], name ]
          else
            abort "Config for story '#{name}' not detected"
          end
        when Hash
          story = config["mkcloud"]
          if story
            [ story, name ]
          else
            abort "Story configuration not found"
          end
        end
      end

      def story_file name
        Matrix.root.join(TEMP_DIR, name + ".img").to_s
      end

      alias_method :story_image, :story_file

      def update_config config, story_name
        log(:matrix).info "Updating story config: cloud => #{story_name}"
        config["cloud"] = story_name
        config["cloudpv"] = detect_loop_device(story_name) || find_available_loop_device
        config["cloudbr"] = story_name + "-br"
        config["virtualcloud"] = story_name
        config
      end

      def detect_loop_device story_name
        losetup("-j", story_file(story_name)).output.split(":").first
      end

      def find_available_loop_device
        losetup("-f").output.strip
      end

      def detach_story_image story_name
        device = detect_loop_device(story_name)
        return unless device

        losetup("-d", device)
      end

      def validate_base!
        if !Dir.exist?(matrix.config["vendor_dir"] + Matrix::Mkcloud::SCRIPT_DIR)
          abort "Missing automation repository. Try `rake git:automation:clone`"
        end
      end

      def validate_mkcloud_config! config
        MANDATORY_CONF_KEYS.each do |key|
          if !config.keys.include?(key)
            abort "Invalid mkcloud config, missing '#{key}' value"
          end
        end
        config
      end

    end
  end
end
