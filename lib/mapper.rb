#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-01 15:27:49 +0800
# http routes mapper

require_relative 'viewmd'
require 'json'

class Mapper
  def call(env)
    req=Rack::Request.new(env)
    if match=Map.routes[env.values_at('REQUEST_METHOD', 'REQUEST_PATH')]
      match
      .tap {|route| 
          post_body=JSON.parse(req.body.read) rescue {}
          route[:data].merge!(post_body, req.params) 
        }
       .then { |route| View.render(route[:erb], **route[:data]) }
       .then { |body| return [200, {'Content-type'=>'text/html; charset=utf8'}, [body]] if body }
    end

    [302, { 'Location' => '/' }, []] # go home
  end
end

module Map
  D=Object.method(:define_method)
  @routes = Hash.new { |h, k| h[k] = nil }
  class << self
    attr_accessor :routes, :method

    def method_missing(m, a, **data, &block)
      push m, a, **data, &block
      @matched=true
    end
    
    D[:push] do |m, a, **data, &block|
      m=block.call if block
      r={erb: m.to_s.tr('_', '.'), data:}
      routes[[method, a]] = r
    end

    %w[GET POST DELETE].map do |m|
      D[m.downcase]{|*path, **data, &b| 
        @method=m
        instance_eval(&b)
        path.map{ |p| push(m, p, **data, &b) } unless @matched
        @matched=false
      }
    end
  end
end
