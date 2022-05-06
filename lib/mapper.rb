#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-01 15:27:49 +0800
# http routes mapper

require_relative 'viewmd'
require 'json'

V = View.method(:render)
D = Object.method(:define_method)

module Map
  @routes = Hash.new { |h, k| h[k] = nil }
  class << self
    attr_accessor :routes, :method

    def method_missing(m, a, **data, &block)
      push m, a, **data, &block
      @matched = true
    end

    D[:push] do |m, u, **data, &block|
      # a block val supercedes m arg
      m = block.call if block
      r = { erb: m.to_s.tr('_', '.'), data: }
      routes[[method, u]] = r
    end

    %w[GET POST DELETE].map do |m|
      D[m.downcase] do |*path, **data, &b|
        @method = m
        instance_eval(&b)
        path.map { |u| push(m, u, **data, &b) } unless @matched
        @matched = false
      end
    end

    def fetch(req)
      match=@routes.dup[[req.request_method, req.path_info]]
      [req.request_method.to_sym, match]
    end

  end
end


class Mapper
  attr :req

  def dispatch
    method, match=Map.fetch(req)
    return nil unless match
    send(method, **match)
  end

  def call(env)
    @req = Rack::Request.new(env)
    status = 200
    body=dispatch
    status = 404 unless body
    [status, { 'Content-type' => 'text/html; charset=utf8' }, [body]]
  end
end
