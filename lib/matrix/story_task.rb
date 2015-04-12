require 'rake/tasklib'

module Matrix
  class StoryTask
    attr_reader :name, :data
    def initialize name, data
      @name = name
      @data = data
    end

    #TODO: look here for more https://github.com/rspec/rspec-core/blob/master/lib/rspec/core/rake_task.rb
    class ProxTask < ::Rake::TaskLib
      include ::Rake::DSL
    end
  end
end
