require 'erb'
require 'yaml'

module Matrix
  class Config
    DIR = "config/"
    STORIES_DIR = "stories/"
    DEFAULT_FILE = 'default.yml'
    DEFAULT_STORY = 'default.yml'
    EXT = '.yml'

    attr_reader :content

    attr_reader :files

    attr_reader :dir

    attr_reader :raw

    attr_accessor :current_runner

    def initialize
      @dir = Matrix.root.join(DIR)
      @files = []
      @raw = ""
      @content = load_default_config
      load_story_configs
      #TODO: Still missing
      load_env_config
    end

    def [](config_value)
      return content[config_value] if content[config_value]

      fail "Your current config does not include root element '#{config_value}'"
    end

    def merge! filename
      filename << EXT unless filename.to_s.match(/.#{EXT}$/)
      config_file = dir.join(filename)
      files << config_file
      @content = content.deep_merge!(load_content(config_file))
    end

    private

    def load_default_config
      default_config = dir.join(DEFAULT_FILE)
      if !File.exist?(default_config)
        abort "Default config file in '#{default_config}' not found"
      end
      files << default_config
      content = load_content(default_config.to_s)
      content["vendor_dir"] = "vendor/"
      content
    end

    # Assuming the default config file is already loaded in #content
    def load_story_configs
      load_default_story
      content['stories'].reject {|s| s == DEFAULT_STORY }.each do |story|
        files << dir.join(STORIES_DIR, story).to_s
        load_raw_story(story)
      end
      content.deep_merge!(validate_yaml(raw))
    end

    def load_default_story
      default_file = dir.join(STORIES_DIR, DEFAULT_STORY)
      raw << File.read(default_file).to_s
      files << default_file
      validate_yaml(raw)
    end

    def validate_yaml string
      YAML.load(ERB.new(raw).result)
    end

    def load_raw_story file
      #FIXME ruby 2.2 added #slise_after into Enumerable; use like: slice_after(/story:/).entries.last
      story = File.read(dir.join(STORIES_DIR, file)).lines.slice_before(/story:/).entries
      #FIXME Remove this when slice_after has been added
      abort "Node 'story:' not found in config file '#{file}'" if story.empty?

      #FIXME Remove this when slice_after has been added
      story = story.first[1..-1]

      raw << story.join if story
    end

    #TODO: this has several parts because the basic configs are loaded differently from
    #      the stories' configs. The yaml/json data might be loaded from a provided param
    #      at the beginning as a whole, then split into the 'main' part and the 'story' part
    #      and proceed when it's needed during the config build time.
    def load_env_config
      return
      env_config = ENV["config"]
      return if env_config.to_s.empty?

      env_config = YAML.load(env_config)
      content.deep_merge!(env_config)
    end

    def load_devel_config
      devel_config = dir.join(DEVELOPMENT_FILE)
      return unless File.exist?(devel_config)

      merge!(devel_config)
      autoload_config_files
    end

    def load_content file
      ::YAML.load(ERB.new(File.read(file)).result) || {}
    rescue Errno::ENOENT
      abort "Configuration file '#{file}' not found"
    end

    def autoload_config_files
      return unless content['autoload_config_files']

      content['autoload_config_files'].each do |config_file|
        config_file << EXT unless config_file.to_s.match(/.#{EXT}$/)
        next if config_file.to_s.match(/\A#{DEFAULT_FILE}$/)

        if !File.exist?(dir.join( config_file))
          abort "Configuration file #{config_file} does not exist".red
        end

        merge!(config_file)
      end
    end

  end
end

