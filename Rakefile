Rake.add_rakelib '_includes'

desc 'Check the website'
task c: %w[check:codes check:assets]

desc 'Serve the website'
task :s do
  system('bundle exec jekyll serve --watch --livereload')
end

desc 'Build the website'
task :b do
  system('bundle exec jekyll build')
end

desc 'Synchronize with writings'
task default: 'synchronize:incrementally'
