require 'dotenv/load'
require 'notion-sdk-ruby'
require 'yaml'

desc 'Serve the website'
task :s do
  system('bundle exec jekyll serve --watch --livereload')
end

desc 'Build the website'
task :b do
  system('bundle exec jekyll build')
end

desc 'Synchronize with writings'
task :default do
  client = Notion::Client.new(token: ENV['NOTION_API_SECRET'])
  client.databases.query_all('bbe660e545314937aa887569764b5458', {
    filter: { property: 'Column', select: { equals: 'Tech Blog' } }
  }) do |page|
    puts "Start to process page #{page.id}..."

    contents = [
      {
        'layout' => 'post',
        'notion_id' => page.id,
        'title' => page.properties['Name']['title'].first['plain_text'],
        'slug' => page.properties['Origin']['url'].split('/').last.sub(/\.html$/, ''),
        'date' => Date.iso8601(page.created_time).to_time.getlocal.to_s,
        'modified_date' => Date.iso8601(page.last_edited_time).to_time.getlocal.to_s,
        'comments' => true
      }.compact.to_yaml + '---'
    ] + client.blocks.children.list_all(page.id).map(&:to_md)

    filename = "_posts/#{page.created_time[0...10]}-#{page.id}.md"
    File.open(filename, 'w').puts contents.join("\n\n")
    puts "Saved to #{filename}."
  end
end

module Notion
  module Api
    module Exhaustiveness
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def exhaustively(name)
          define_method("#{name}_all") do |*args, &block|
            items = []
            cursor = nil

            loop do
              if args.last.is_a?(Hash)
                args.last.merge(start_cursor: cursor).compact
              else
                args << { start_cursor: cursor }.compact
              end
              list = method(name).call(*args)

              items += list.data.tap { |d| d.each { block.call(_1) } if block }
              cursor = list.next_cursor

              break unless list.has_more
            end

            items
          end
        end
      end
    end

    class BlocksChildrenMethods
      include Exhaustiveness
      exhaustively :list
    end

    class DatabasesMethods
      include Exhaustiveness
      exhaustively :query
    end

    module SearchMethods
      include Exhaustiveness
      exhaustively :search
    end
  end

  # https://developers.notion.com/reference/block
  class Block
    def to_md
      unless self[type]['rich_text']
        puts "Cannot convert into GitHub flavored markdown: #{JSON.pretty_generate(to_h)}"
        return "```json\n#{JSON.pretty_generate(to_h)}\n```"
      end

      prefix = ''
      suffix = ''
      anofix = {} # fix for annotations, e.g. unbold all headings

      case type
      # when 'paragraph'
      when /heading_(\d)/
        prefix = '#' * $1.to_i + ' '
        anofix['bold'] = false
      # when 'callout'
      when 'quote'
        prefix = '> '
      when 'bulleted_list_item'
        prefix = '- '
      when 'numbered_list_item'
        prefix = '1. '
      when 'to_do'
        prefix = self[type]['checked'] ? '- [x] ' : '- [ ] '
      # when 'toggle'
      when 'code'
        prefix = "```#{self[type]['language'].split(' ').first}\n"
        suffix = "\n```"
      end

      prefix + self[type]['rich_text'].map do |o|
        r = o['plain_text']
        a = o['annotations'].merge(anofix)

        # For mutually exclusive annotations
        r = a['code'] ? "`#{r}`" : a['underline'] ? "<u>#{r}</u>" : r

        # For non-exclusive annotations
        r = "**#{r}**" if a['bold']
        r =  "*#{r}*"  if a['italic']
        r = "~~#{r}~~" if a['strikethrough']

        # TODO: colors are not supported yet

        # Add link
        r = "[#{r}](#{o['href']})" + '{:target="_blank"}' if o['href']

        # Capture cases
        case o['type']
        # when 'text'
        when 'mention'
          puts "Cannot convert into GitHub flavored markdown: #{JSON.pretty_generate(obj)}"
        when 'equation'
          puts "Cannot convert into GitHub flavored markdown: #{JSON.pretty_generate(obj)}"
        end

        r
      end.join + suffix
    end
  end
end
