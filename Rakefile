require 'dotenv/load'
require 'notion-sdk-ruby'
require 'time'
require 'yaml'

desc 'Clean the website'
task :c do
  raise NotImplementedError # TODO
end

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
    filename = "_posts/#{page.created_time[0...10]}-#{page.id}.md"
    next unless Time.parse(page.last_edited_time) > File.open(filename).mtime

    puts "Fetching latest version of page #{page.id}"
    contents = [
      {
        'layout' => 'post',
        'notion_id' => page.id,
        'title' => page.properties['Name']['title'].first['plain_text'],
        'slug' => page.properties['Origin']['url'].split('/').last.sub(/\.html$/, ''),
        'date' => Time.parse(page.created_time).getlocal.to_s,
        'modified_date' => Time.parse(page.last_edited_time).getlocal.to_s,
        'comments' => true
      }.compact.to_yaml + '---'
    ] + client.blocks.children.list_all(page.id).map(&:to_md)

    File.open(filename, 'w').puts contents.join("\n\n")
    puts "Saved to #{filename}"
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
      prefix = ''
      suffix = ''

      case type
      when 'paragraph'
        nil
      when /heading_(\d)/
        prefix = '#' * $1.to_i + ' '
        self[type]['rich_text'].map { _1['annotations']['bold'] = false } # unbold headings
      when 'callout'
        nil
      when 'quote'
        prefix = '> '
      when 'bulleted_list_item'
        prefix = '- '
      when 'numbered_list_item'
        prefix = '1. '
      when 'to_do'
        prefix = to_do['checked'] ? '- [x] ' : '- [ ] '
      when 'toggle'
        nil
      when 'code'
        prefix = "```#{code['language'].split(' ').first}\n"
        suffix = "\n```"
      when 'image'
        res = Faraday.get(image[image['type']]['url'])
        raise RuntimeError.new('Unable to fetch a image inside') unless res.success?

        loc = 'assets/' + res.headers['x-amz-version-id'] + '.' + res.headers['content-type'].sub('image/', '')
        File.open(loc, 'wb').puts res.body
        return "{% include image src='/#{loc}' cap='#{RichText.to_md(image['caption'])}' %}"
      when 'equation'
        return '$$' + equation['expression'] + '$$' # TODO: import KaTex javascripts
      else
        raise RuntimeError.new('Unable to convert the block')
      end

      # Only for types with rich_text, others should return in `case`
      prefix + RichText.to_md(self[type]['rich_text']) + suffix

    rescue RuntimeError => e
      puts "#{e.message}: #{JSON.pretty_generate(to_h)}"
      return "```json\n#{JSON.pretty_generate(to_h)}\n```"
    end
  end

  class RichText < OpenStruct
    def self.to_md(obj)
      obj.is_a?(Array) ? obj.map { |item| new(item).to_md }.join : new(obj).to_md
    end

    def to_md
      md = plain_text

      # Shortcut for equation
      return "$#{md}$" if type == 'equation' # TODO: import KaTex javascripts

      # For mutually exclusive annotations
      md = annotations['code'] ? "`#{md}`" : annotations['underline'] ? "<u>#{md}</u>" : md

      # For non-exclusive annotations
      md = "**#{md}**" if annotations['bold']
      md =  "*#{md}*"  if annotations['italic']
      md = "~~#{md}~~" if annotations['strikethrough']

      # TODO: support colors with Tailwind CSS

      # Add link
      md = "[#{md}](#{href})" + '{:target="_blank"}' if href

      md
    end
  end
end
