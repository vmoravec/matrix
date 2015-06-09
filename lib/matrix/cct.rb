module Matrix
  class Cct
    NAME = "cct"

    extend Forwardable

    def_delegators :@cct, :setup, :load_tasks!, :config

    attr_reader :gem_dir

    def initialize verbose, log_path
      config = Matrix.config["cucumber"]
      ENV["cct_config"] = {"cucumber" => enhance_config(config)}.to_yaml
      @gem_dir = Pathname.new(Gem::Specification.find_by_name(NAME).gem_dir)
      @cct = ::Cct.setup(gem_dir, verbose: verbose, log_path: log_path)
    end

    private

    def enhance_config config
      config["formats"].each_with_index do |format, index|
        format.each_pair do |name, path|
          config["formats"][index] = { name => Matrix.root.join(path).to_s }
        end
      end
      config
    end
  end
end
