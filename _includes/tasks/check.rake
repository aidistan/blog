namespace :check do
  desc 'Lint codes with rubocop'
  task :codes do
    execute 'bundle exec rubocop --format tap'
  end

  desc 'Check redundent assets'
  task assets: :b do
    denpedents = Dir['assets/*'].to_h { [_1, []] }
    pattern = Regexp.new(Dir['assets/*'].join('|'))

    Dir['_site/**/*.html'].each do |path|
      File.read(path).scan(pattern) { denpedents[Regexp.last_match(0)] << path }
    end

    redundents = denpedents.keys.select { denpedents[_1].empty? }
    next info 'No redundent asset found.' if redundents.empty?

    redundents.each do |path|
      info "Remove redundent asset '#{path}'"
      execute "rm #{path}"
    end
  end
end
