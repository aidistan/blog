Rake.add_rakelib '_includes/tasks'

desc 'Check the website'
task check: %w[check:codes check:assets]
desc 'Shorthand to task check'
task c: :check

desc 'Serve the website'
task :serve do
  system('bundle exec jekyll serve --watch --livereload')
end
desc 'Shorthand to task serve'
task s: :serve

desc 'Build the website'
task :build do
  system('bundle exec jekyll build')
end
desc 'Shorthand to task build'
task b: :build

desc 'Shorthand to task synchronize:incrementally'
task default: 'synchronize:incrementally'
