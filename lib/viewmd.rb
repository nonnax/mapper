#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:27:49 +0800
require 'kramdown'

module Kernel
  def _div_(**params, &block)
    opts = []
    params.to_a.inject(opts) do |acc, (k, v)|
      acc << [k, %('#{v}')].join('=')
    end
    "<div #{opts.join(' ')}>#{block.call}</div>"
  end
end

class String
  def to_html
    Kramdown::Document.new(self).to_html
  end
end

class View
  attr :data, :template, :layout

  def self.render(page, **data)
    new(page, **data).render
  end

  def initialize(page, **data)
    @data = data
    @template, @layout = [page, :layout].map do |v|
      File.expand_path("../public/views/#{v}.erb", __dir__).then do |f|
        IO.read(f)
        .then{|text| f.match?(/.md.erb/)? _div_(class: 'item'){ text.to_html } : text  }
      end
    end
  end

  def render
    _render(layout) do
      _render(template, binding)
    end
  end

  def _render(text, b = binding)
    ERB.new(text).result(b)
  end

  def visit_count
    data[:visit_count]
  end
end
