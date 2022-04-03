#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:27:49 +0800
require 'kramdown'

class String
  def to_html() Kramdown::Document.new(self).to_html end
end

class View
  attr :data, :template, :layout

  def self.render(page, **data) new(page, **data).render end

  def initialize(page, **data)
    @data = data
    @template, @layout = [page, :layout].map do |v|
      File.expand_path("../public/views/#{v}.erb", __dir__)
      .then{ |f| IO.read(f) }
      .then{ |text| v.match?(/\.md/)? text.to_html : text  }
    end
  end

  def render(**h)
    _render(layout, **h){ _render(template, **h) } 
  rescue
    nil
  end
  def _render(text, **h) ERB.new(text).result_with_hash(**h) end
  def visit_count() data[:visit_count] end
end
