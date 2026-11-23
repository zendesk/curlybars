# frozen_string_literal: true

# Presenters, global helpers and partials used by the benchmark templates in
# benchmark/templates/.
#
# The data is built once, when this file is loaded, so the allocations
# measured during rendering are Curlybars' own and not those of building
# presenters.
module CurlybarsBenchmark
  # A presenter whose values are given up front.
  class Record < Curlybars::Presenter
    # The values replace Curlybars::Presenter's context and options.
    def initialize(**values)
      values.each { |name, value| instance_variable_set(:"@#{name}", value) }
    end
  end

  class Author < Record
    allow_methods :name, :avatar_url
    attr_reader :name, :avatar_url
  end

  class Comment < Record
    allow_methods :body, :author, :created_at
    attr_reader :body, :author, :created_at
  end

  class Article < Record
    allow_methods :title, :url, :summary, :body, :author, :featured, :votes, :comments
    attr_reader :title, :url, :summary, :body, :author, :featured, :votes, :comments
  end

  class Section < Record
    allow_methods :name, :url, :archived, :articles
    attr_reader :name, :url, :archived, :articles
  end

  class Category < Record
    allow_methods :name, :sections
    attr_reader :name, :sections
  end

  class Site < Record
    allow_methods :name, :tagline, :layout
    attr_reader :name, :tagline, :layout
  end

  module Data
    module_function

    def author(index)
      Author.new(name: "Author #{index}", avatar_url: "/avatars/#{index}.png")
    end

    def article(index, comments:)
      Article.new(
        title: "Article #{index}",
        url: "/articles/#{index}",
        summary: "A summary of article #{index}, which is a bit longer than its title.",
        body: "The body of article #{index}, with questions & answers.",
        author: author(index % 7),
        featured: index.even?,
        votes: index * 3,
        comments: Array.new(comments) do |comment|
          Comment.new(body: "Comment #{comment} on article #{index}", author: author(comment), created_at: "2026-01-0#{comment + 1}")
        end
      )
    end

    SITE = Site.new(name: "Help Center", tagline: "Answers to all your questions, and then some", layout: "grid")

    # One article.
    SMALL = article(1, comments: 0)

    # 20 articles with 5 comments each.
    MEDIUM = Array.new(20) { |index| article(index, comments: 5) }.freeze

    # 4 categories with 3 sections each, with 5 articles each.
    LARGE = Array.new(4) do |category|
      Category.new(
        name: "Category #{category}",
        sections: Array.new(3) do |section|
          index = (category * 3) + section
          Section.new(
            name: "Section #{index}",
            url: "/sections/#{index}",
            archived: index == 4,
            articles: Array.new(index == 7 ? 0 : 5) { |article| article((index * 5) + article, comments: 2) }
          )
        end
      )
    end.freeze

    PROMOTED = MEDIUM.first(3).freeze
  end

  # The presenters for the templates. The view path is `templates/<name>`,
  # and the presenters namespace is `curlybars_benchmark`.
  module Templates
    class SmallPresenter < Curlybars::Presenter
      allow_methods :article

      def article = Data::SMALL
    end

    class MediumPresenter < Curlybars::Presenter
      allow_methods :site, :articles

      def site = Data::SITE
      def articles = Data::MEDIUM
    end

    class LargePresenter < Curlybars::Presenter
      allow_methods :site, :categories, :promoted

      def site = Data::SITE
      def categories = Data::LARGE
      def promoted = Data::PROMOTED
    end
  end

  class GlobalHelpers
    extend Curlybars::MethodWhitelist

    allow_methods :t, :link_to, :truncate, :concat, :eq, :emphasize, :if_any

    TRANSLATIONS = {
      "by" => "by",
      "comments" => "Comments",
      "featured" => "Featured",
      "no_articles" => "No articles yet",
      "promoted" => "Promoted",
      "votes" => "votes"
    }.freeze

    def initialize(context = nil)
      @context = context
    end

    def t(key, _options)
      TRANSLATIONS.fetch(key, key)
    end

    def link_to(text, url, options)
      %(<a href="#{ERB::Util.html_escape(url)}" class="#{ERB::Util.html_escape(options[:class])}">#{ERB::Util.html_escape(text)}</a>).html_safe
    end

    def truncate(text, length, _options)
      text.to_s.truncate(length)
    end

    def concat(left, right, _options)
      "#{left}#{right}"
    end

    def eq(left, right, _options)
      left == right
    end

    # A block helper: {{#emphasize}}...{{/emphasize}}
    def emphasize(options)
      "<em>#{options[:fn].call}</em>".html_safe
    end

    # A block helper with an else block and a variable:
    # {{#if_any collection}}{{@count}}{{else}}...{{/if_any}}
    def if_any(collection, options)
      if collection.any?
        options[:fn].call(count: collection.size)
      else
        options[:inverse].call
      end
    end
  end

  class Partials
    PARTIALS = Dir[File.join(__dir__, "partials", "*.hbs")].to_h do |path|
      [File.basename(path, ".hbs"), File.read(path)]
    end.freeze

    def initialize(context = nil)
      @context = context
    end

    def resolve_partial(name)
      PARTIALS[name]
    end
  end
end
