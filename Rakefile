# frozen_string_literal: true

require 'date'
require 'yaml'
require 'highline/import'

namespace :serve do
  task :default do
    config = YAML.load(File.read('_config.yml')) # rubocop:disable Security/YAMLLoad

    %w[baidu].each do |s|
      config['service'].delete(s)
    end

    File.open('__config.yml', 'w') { |fout| fout.puts YAML.dump(config) }
    system('bundle exec jekyll serve --watch --livereload --drafts --config __config.yml')
  end
end

namespace :new do
  desc 'Create a new draft'
  task :draft do
    content = <<~END_OF_DOC
      ---
      layout: post
      title:
      description:
      modified:
      tags: []
      link:
      ---
    END_OF_DOC

    File.open('_drafts/new-draft.md', 'w').puts content.gsub(
      /^modified:$/, "modified: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %z')}"
    )
  end

  desc 'Create a new page'
  task :page do
    content = <<~END_OF_DOC
      ---
      layout: page
      permalink:
      title:
      description:
      ---
    END_OF_DOC

    File.open('new-page.html', 'w').puts content
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

  def publish_draft(draft_path, time = ask_date)
    content = File.read(draft_path)
      .gsub(/^modified:[ 0-9\-:+]*$/, "modified: #{time.strftime('%Y-%m-%d %H:%M:%S %z')}")
    path = draft_path.gsub(%r{^_drafts/}, "_posts/#{time.strftime('%Y-%m-%d')}-")

    File.open(path, 'w').puts content
    File.unlink(draft_path)
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
