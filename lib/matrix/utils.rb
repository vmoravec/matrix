module Matrix
  module Utils
    module User
      def sudo *args
        sudo_result = Matrix.user.root? ? "" : "sudo "
        return sudo_result if args.empty?

        sudo_result.empty? ? args : args.unshift(sudo_result)
      end

      def sudo?
        !Matrix.user.root?
      end
    end

    module Runner
      def runner_config
        if Matrix.config["current_runner"].nil?
          include StoryDetection

          story_name = ENV["story"]
          fail "Story not detected. Try to provide environment variable story=STORY_NAME"

          config = detect_story(story_name)
          Matrix.config["current_runner"] = config
        end

        yield Matrix.config["current_runner"]
      end
    end

    #TODO there is mkcloud specific stuff here, remove that
    module StoryDetection
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
    end

    module Validations
      def validate_base!
        if !Dir.exist?(matrix.config["vendor_dir"] + Matrix::Mkcloud::SCRIPT_DIR)
          abort "Missing automation repository. Try `rake git:automation:clone`"
        end
      end
    end
  end
end
