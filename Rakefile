require 'sshkit'
require 'sshkit/dsl'
include SSHKit::DSL # rubocop:disable Style/MixinUsage
require 'airbrussh'
SSHKit.config.output = Airbrussh::Formatter.new($stdout, banner: nil, command_output: true, log_file: nil)

%w[execute test capture debug info warn error fatal].each do |m|
  eval <<~END_OF_DOC, binding, __FILE__, __LINE__ + 1 # rubocop:disable all
    def #{m}(...)
      run_locally { #{m}(...) }
    end
  END_OF_DOC
end

# Load task libraries
Rake.add_rakelib '_includes/tasks'

desc 'Check the website (aka :c)'
task check: %w[check:codes check:assets]
task c: :check # rubocop:disable Rake/Desc

desc 'Serve the website (aka :s)'
task :serve do
  execute 'bundle exec jekyll serve --watch --livereload'
end
task s: :serve # rubocop:disable Rake/Desc

desc 'Build the website (aka :b)'
task :build do
  execute 'bundle exec jekyll build'
end
task b: :build # rubocop:disable Rake/Desc

task default: 'synchronize:incrementally'
