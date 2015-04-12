module Matrix
  class Cct
    NAME = "cct"

    extend Forwardable

    def_delegators :@cct, :setup, :load_tasks!

    attr_reader :gem_dir

    def initialize verbose, log_path
      @gem_dir = Pathname.new(Gem::Specification.find_by_name(NAME).gem_dir)
      @cct = ::Cct.setup(gem_dir, verbose: verbose, log_path: log_path)
    end
  end
end
