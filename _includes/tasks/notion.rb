require 'notion-sdk-ruby'

module Notion
  module Api
    module Exhaustiveness
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def exhaustively(name) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          define_method("#{name}_all") do |*args, &block| # rubocop:disable Metrics/MethodLength
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
    def to_md # rubocop:disable Metrics/*
      prefix = ''
      suffix = ''

      case type
      when 'paragraph'
        # do nothing
      when /heading_(\d)/
        prefix = '#' * Regexp.last_match(1).to_i + ' ' # rubocop:disable all
        self[type]['rich_text'].map { _1['annotations']['bold'] = false } # unbold headings
      when 'callout'
        # do nothing
      when 'quote'
        prefix = '> '
      when 'bulleted_list_item'
        prefix = '- '
      when 'numbered_list_item'
        prefix = '1. '
      when 'to_do'
        prefix = to_do['checked'] ? '- [x] ' : '- [ ] '
      when 'toggle'
        # do nothing
      when 'code'
        prefix = "```#{code['language'].split.first}\n"
        suffix = "\n```"
      when 'image'
        url = image[image['type']]['url']
        res = Faraday.get(url)
        raise 'Unable to fetch a image inside' unless res.success?

        loc = "assets/#{url.split('/')[-2]}.#{res.headers['content-type'].sub('image/', '')}"
        File.open(loc, 'wb').puts res.body
        return "{% include figure src='/#{loc}' cap='#{RichText.to_md(image['caption'])}' %}"
      when 'bookmark', 'link_preview'
        return ''
      when 'equation'
        return "$$#{equation['expression']}$$"
      when 'divider'
        return '---'
      else
        raise 'Unable to convert the block'
      end

      # Only for types with rich_text, others should return in `case`
      prefix + RichText.to_md(self[type]['rich_text']) + suffix
    rescue RuntimeError => e
      puts "#{e.message}: #{JSON.pretty_generate(to_h)}"
      "```json\n#{JSON.pretty_generate(to_h)}\n```"
    end
  end

  # Not use OpenStruct for better performance
  class RichText
    ATTRIBUTES = %w[
      plain_text href annotations type text mention equation
    ].each { attr_reader _1 }

    def self.to_md(obj)
      obj.is_a?(Array) ? obj.map { |item| new(item).to_md }.join : new(obj).to_md
    end

    def initialize(data)
      ATTRIBUTES.each { instance_variable_set("@#{_1}", data[_1]) }
    end

    def to_md # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      md = plain_text

      # Shortcut for equation
      return "$#{md}$" if type == 'equation'

      # rubocop:disable Layout/*
      md = "<u>#{md}</u>" if annotations['underline']
      md =   "`#{md}`"    if annotations['code']
      md =  "**#{md}**"   if annotations['bold']
      md =   "*#{md}*"    if annotations['italic']
      md =  "~~#{md}~~"   if annotations['strikethrough']
      md =   "[#{md}](#{href}){:target=\"_blank\"}" if href
      # rubocop:enable Layout/*

      md # TODO: support colors with Tailwind CSS
    end
  end
end
