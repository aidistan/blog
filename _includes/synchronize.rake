require 'dotenv/load'
require 'time'
require 'yaml'

require_relative './notion'

namespace :synchronize do
  task :fully do
    synchronize(:fully)
  end

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
    next unless type == :fully || Time.parse(page.last_edited_time) > File.open(filename).mtime

    puts "Fetching latest version of page #{page.id}"
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
    puts "Saved to #{filename}"
  end
end
