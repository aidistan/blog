require 'dotenv/load'
require 'time'
require 'yaml'

require_relative './notion'

namespace :synchronize do
  desc 'Synchronize all pages'
  task :fully do
    synchronize(:fully)
  end

  desc 'Synchronize updated pages'
  task :incrementally do
    synchronize(:incrementally)
  end
end

def synchronize(type) # rubocop:disable Metrics/*
  client = Notion::Client.new(token: ENV.fetch('NOTION_API_SECRET'))
  client.databases.query_all('bbe660e545314937aa887569764b5458', {
    filter: { property: 'Column', select: { equals: 'Tech Blog' } }
  }) do |page|
    filename = "_posts/#{page.created_time[0...10]}-#{page.id}.md"

    File.read(filename).match(/^modified_date: '([^']+)'/)
    modified_date = Regexp.last_match[1]

    next if type == :incrementally && File.exist?(filename) &&
      Time.parse(modified_date) == Time.parse(page.last_edited_time)

    info "Fetching latest version of page #{page.id}"
    contents = [
      { # rubocop:disable Style/StringConcatenation
        'layout' => 'post',
        'notion_id' => page.id,
        'title' => page.properties['Name']['title'].first['plain_text'],
        'slug' => page.properties['Origin']['url'].split('/').last.sub(/\.html$/, ''),
        'date' => Time.parse(page.created_time).getlocal.to_s,
        'modified_date' => Time.parse(page.last_edited_time).getlocal.to_s,
        'comments' => true
      }.compact.to_yaml + '---'
    ] + client.blocks.children.list_all(page.id).map(&:to_md).reject(&:empty?)

    File.open(filename, 'w').puts contents.join("\n\n")
    info "Saved to #{filename}"
  end
end
