namespace :check do
  desc 'Lint codes with rubocop'
  task :codes do
    system('bundle exec rubocop')
  end

  desc 'Check redundent assets'
  task assets: :b do
    denpedents = Dir['assets/*'].map { [_1, []] }.to_h
    pattern = Regexp.new(Dir['assets/*'].join('|'))

    Dir['_site/**/*.html'].each do |path|
      File.read(path).scan(pattern) { denpedents[Regexp.last_match(0)] << path }
    end

    redundents = denpedents.keys.select { denpedents[_1].empty? }
    if redundents.empty?
      puts 'No redundent asset found.'
    else
      puts 'Redundent assets are:'
      puts redundents
    end
  end
end
