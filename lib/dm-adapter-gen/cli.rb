require 'thor'
require 'bundler/cli'

SOURCE_PATH = File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

# Add our own templates paths so we can override Bundlers templates
Bundler::CLI.class_eval do
  def self.source_paths_for_search
    [SOURCE_PATH, self.source_root]
  end
end

module DataMapper
  class CLI < Thor
    include Thor::Actions

    # Code inspired and mostly stolen from Bundler: https://github.com/carlhuda/bundler/blob/1-0-stable/lib/bundler/cli.rb
    desc "adapter", "Creates a skeleton for creating a DataMapper adapter"
    def adapter(name)
      adapter_name = "dm-#{name.downcase}-adapter"
      target = File.join(Dir.pwd, adapter_name)
      constant_name = "#{name.capitalize}Adapter"

      target = File.join(Dir.pwd, adapter_name)

      filename = "#{name.downcase}_adapter"
      constant_name = "#{name.capitalize}Adapter"

      git_author_name = `git config user.name`.chomp
      git_author_email = `git config user.email`.chomp
      author_name = git_author_name.empty? ? "TODO: Write your name" : git_author_name
      author_email = git_author_email.empty? ? "TODO: Write your email address" : git_author_email
      FileUtils.mkdir_p(File.join(target, 'lib', 'datamapper', 'adapters', name))
      
      opts = {:name => adapter_name, :constant_name => constant_name, :filename => filename, :author_name => author_name, :author_email => author_email}

      template(File.join("newadapter/Gemfile.tt"),                   File.join(target, "Gemfile"),                        opts)
      template(File.join("newadapter/Rakefile.tt"),                  File.join(target, "Rakefile"),                       opts)
      template(File.join("newadapter/gitignore.tt"),                 File.join(target, ".gitignore"),                     opts)
      template(File.join("newadapter/newadapter.gemspec.tt"),        File.join(target, "#{adapter_name}.gemspec"),        opts)
      template(File.join("newadapter/lib/newadapter.rb.tt"),         File.join(target, "lib/#{adapter_name}.rb"),         opts)
      template(File.join("newadapter/lib/newadapter/version.rb.tt"), File.join(target, "lib/#{adapter_name}/version.rb"), opts)
      template(File.join("newadapter/spec/adapter_spec.rb.tt"),      File.join(target, "spec/adapter_spec.rb"),           opts)
      
      template(File.join("newadapter/lib/datamapper/adapters/newadapter.rb.tt"), File.join(target, "lib/datamapper/adapters/#{filename}.rb"), opts)


      say "Initializating git repo in #{target}"  
      Dir.chdir(target) { `git init`; `git add .` }
    end
    
    def self.source_root
      SOURCE_PATH
    end

  end
end
