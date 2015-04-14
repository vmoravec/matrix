module Matrix
  module Utils
    module Mkcloud
      LOSETUP_BIN = "/sbin/losetup"
      MODPROBE_BIN = "/sbin/modprobe"
      TEMP_DIR = "tmp/"
      MANDATORY_CONF_KEYS = %w(
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

      def create_image filename, size
        path = Matrix.root.join(TEMP_DIR, "#{filename}.img")
        if File.exist?(path)
          puts "Creating new filesystem in `#{path}"
          check_filesystem(path)
        else
          puts "Creating image file in `#{path}"
          command.exec!("qemu-img create -f raw #{path} #{size}")
          check_filesystem(path)
        end
      end

      def check_filesystem file
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

      def validate_mkcloud_config! config
        MANDATORY_CONF_KEYS.each do |key|
          if !config.keys.include?(key)
            abort "Invalid mkcloud config, missing '#{key}' value"
          end
        end
        config
      end

      def detect_config! story_name, env
        validate_else!

        story_name = story_name || ENV["story"]
        if story_name.nil?
          abort "Story name not detected, mkcloud can't continue.." +
                " Try with story=NAME "
        end

        story_config, story_name = detect_story_config!(story_name, env)

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
            abort "Config for story '#{name}' not detected, mkcloud can't run"
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

      def validate_else!
        if !Dir.exist?(matrix.config["vendor_dir"] + Matrix::Mkcloud::SCRIPT_DIR)
          abort "Missing automation repository. Try `rake git:automation:clone`"
        end
      end
    end
  end
end
