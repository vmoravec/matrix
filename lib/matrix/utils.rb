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

    module Validations
      def validate_base!
        if !Dir.exist?(matrix.config["vendor_dir"] + Matrix::Mkcloud::SCRIPT_DIR)
          abort "Missing automation repository. Try `rake git:automation:clone`"
        end
      end
    end
  end
end
