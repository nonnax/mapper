#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-01 15:27:49 +0800
# http routes mapper

require_relative 'viewmd'
require 'json'

V=View.method(:render)
D=Object.method(:define_method)

class Mapper
  def call(env)
    req=Rack::Request.new(env)
    catch(:halt) do
      Map.routes.dup[env.values_at('REQUEST_METHOD', 'REQUEST_PATH')]
      .tap{|match| throw( :halt, [302, { 'Location' => ?/ }, []] ) if match.nil? }
      .then{|match|
          match
          .tap {|route| 
              post_body=JSON.parse(req.body.read) rescue {}
              route[:data].merge!(post_body, req.params) 
            }
           .then { |route| V.(route[:erb], **route[:data]) }
           .then { |body| [200, {'Content-type'=>'text/html; charset=utf8'}, [body]] }
        }
    end
  end
end

module Map
  @routes = Hash.new { |h, k| h[k] = nil }
  class << self
    attr_accessor :routes, :method
    def method_missing(m, a, **data, &block)
      push m, a, **data, &block
      @matched=true
    end
    
    D[:push] do |m, u, **data, &block|
      # a block val supercedes arg
      m=block.call if block
      r={erb: m.to_s.tr('_', '.'), data:}
      routes[[method, u]] = r
    end

    %w[GET POST DELETE].map do |m|
      D[m.downcase]{|*path, **data, &b| 
        @method=m
        instance_eval(&b)
        path.map{ |u| push(m, u, **data, &b) } unless @matched
        @matched=false
      }
    end
  end
end
