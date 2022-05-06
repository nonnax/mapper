#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:27:49 +0800
require 'kramdown'

K=Kramdown::Document.method(:new)

class View  
  attr :data, :template, :layout

  def self.render(page, **data) new(page, **data).render end

  def initialize(page, **data)
    @data = data
    @template, @layout = [page, :layout].map do |v|
      File.expand_path("public/views/#{v}.erb", Dir.pwd)
      .then{ |f| IO.read(f)}
      .then{ |t| v.match?(/\.md/)? K[t].to_html : t }
    end
  end

  def render
    _render(layout){ _render(template, binding) } 
  rescue
    nil
  end
  def _render(text, b=binding) ERB.new(text).result(b) end
  def visit_count() data[:visit_count] end
end
