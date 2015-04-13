require 'rake/tasklib'

module Matrix
  class StoryTask < ::Rake::TaskLib
    include ::Rake::DSL

    attr_reader :name, :data

    def initialize name, data
      @name = name
      @data = data
    end

  end
end
