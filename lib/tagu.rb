#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-02 00:30:16 +0800
# tagu : non-magical html markup builder
#
class String
  def and(body = nil, &block)
    self << "\n" << (body || block.call).to_s
  end
end

class Tagu
  
  OPENTAGS=%i[html head title style body div p span h1 h2 h3 h4 h5 b i strong em]
  CLOSEDTAGS=%i[link meta br hr]
  
  def self.do(&block)
    new.instance_eval(&block)
  end

  def tag(tag_name, text = nil, **params, &block)
    opts = params.to_a.inject([]) { |acc, (k, v)| acc << [k, %('#{v}')].join('=') }

    if [text, block].any?
      content = text || block.call
      "<#{tag_name} #{opts.join(' ')}>\n#{content}\n</#{tag_name}>".gsub(/\s*>/, '>')
    else
      "<#{tag_name} #{opts.join(' ')}/>"
    end
  end

  OPENTAGS.each do |m|
    define_method(m) { |text = nil, **params, &block| tag(m, text, **params, &block) }
  end
  # no-body methods
  CLOSEDTAGS.each do |m|
    define_method(m) { |text = nil, **params| tag(m, text, **params) }
  end
end
