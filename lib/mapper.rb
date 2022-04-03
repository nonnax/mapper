#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-01 15:27:49 +0800
# http routes mapper

require_relative 'viewmd'
require 'json'

class Mapper
  def call(env)
    req=Rack::Request.new(env)
    path, method = env.values_at('PATH_INFO', 'REQUEST_METHOD')
    if Map.routes[method].key?(path)
      Map.routes[method][path]
         .tap {|route| route[:data].merge!(JSON.parse(req.body.read)) }
         .then { |route| View.render(route[:erb], **route[:data]) }
         .then { |body| return [200, {}, [body]] if body }
    end

    [302, { 'Location' => '/' }, []] # go home
  end
end

module Map
  @routes = Hash.new { |h, k| h[k] = {} }
  class << self
    attr_accessor :routes, :method

    def method_missing(m, a, **data)
      r={erb: m.to_s.tr('_', '.'), data: data}
      routes[method][a] = r
    end

    %w[GET POST DELETE].map do |m|
      define_method(m.downcase){|*path, &b| 
        @method=m
        instance_eval(&b)
      }
    end
  end
end
