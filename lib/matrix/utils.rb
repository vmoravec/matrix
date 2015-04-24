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

    module StoryDetection
      def detect_configuration
        if Matrix.config.current_runner.nil?
          story = ENV["story"]
          if story.nil?
            raise "Story name not found. For standalone runner provide 'story=NAME'"
          end

          config = Matrix.config["story"][story]
          raise "Configuration for story '#{story}' not found" unless config

          return [ story, config.reject {|k,v| k == "runners"} ]
        end
        Matrix.config.current_runner
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
