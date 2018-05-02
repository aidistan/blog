require 'date'
require 'yaml'
require 'highline/import'

namespace :serve do
  task :default do
    config = YAML.load(File.read('_config.yml'))

    %w(baidu).each do |s|
      config['service'].delete(s)
    end

    File.open('__config.yml', 'w') { |fout| fout.puts YAML.dump(config) }
    system('bundle exec jekyll serve --drafts --config __config.yml')
  end
end

namespace :new do
  desc 'Create a new draft'
  task :draft do
    File.open('_drafts/new-draft.md', 'w').puts File.read('_templates/draft.md')
      .gsub(/^modified:$/, "modified: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}")
  end

  desc 'Create a new page'
  task :page do
    File.open('new-page.html', 'w').puts File.read('_templates/page.html')
  end

  desc 'Create a new note'
  task :note do
    # Interact
    path = ask(
      'Please specify the relative path:',
      ->(str) { str.gsub(/\.md$/, '') }
    ) { |q| q.default = 'new-note' }
    title = ask('Please specify the title:') { |q| q.default = '' }

    # Generate
    filepath = "_notes/#{path}.md"
    raise 'Specified directory not exists.' unless Dir.exist?(File.dirname(filepath))
    File.open(filepath, 'w').puts <<-END_OF_DOC
---
layout:    note
permalink: /notes/#{path}/
title:     #{title}
date:      #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}
modified:  #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}
---
    END_OF_DOC
    say "#{filepath.inspect} created"
  end
end

namespace :publish do
  task :draft do
    drafts = Dir['_drafts/*.md']

    if drafts.empty?
      say 'No draft to publish'
    elsif drafts.size == 1
      publish_draft(drafts.first)
    else
      choose do |menu|
        menu.prompt = 'Which draft to publish?'
        drafts.each do |draft|
          menu.choice(draft) { publish_draft(draft) }
        end
      end
    end
  end

  def publish_draft(path, time = ask_date)
    File.open(path.gsub(%r{^_drafts/}, "_posts/#{time.strftime('%Y-%m-%d')}-"), 'w').puts File.read(path)
      .gsub(/^modified:[ 0-9\-:+]*$/, "modified: #{time.strftime('%Y-%m-%d %H:%M:%S %z')}")

    File.unlink(path)
  end

  def ask_date
    ask(
      'At which date?',
      ->(str) { DateTime.parse(str + ' +0800').to_time }
    ) { |q| q.default = Time.now.to_s }
  end
end

#
# Aliases
#

task default: :serve

desc 'Run the server (as: default)'
task serve: 'serve:default'

desc 'Publish a draft'
task publish: 'publish:draft'
