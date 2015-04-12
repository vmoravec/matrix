module Rake
  module DSL
    def matrix
      Matrix
    end

    def cct
      Matrix.cct
    end

    def invoke_feature task_name
      ENV["cct_log_path"] = Matrix.root.join(Matrix::LOG_DIR, ::Cct::LOG_FILENAME).to_s

      Dir.chdir(matrix.cct.gem_dir) do
        invoke_task(task_name)
      end
    end
  end
end
