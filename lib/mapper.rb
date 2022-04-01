#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-01 15:27:49 +0800

require_relative 'view'

module Map
  @routes = Hash.new { |h, k| h[k] = {} }
  class << self
    attr_accessor :routes
  end
end

class Mapper
  def call(env)
    path = env['PATH_INFO']
    method = env['REQUEST_METHOD']
    body = Map.routes[method][path] if Map.routes[method].key?(path)
    body = View.render(body) rescue nil
    return [200, {}, [body]] if body

    [302, { 'Location' => '/' }, []] # go home
  end
end

module Map
  @routes = Hash.new { |h, k| h[k] = {} }
  class << self
    attr_accessor :routes, :method

    def method_missing(m, a)
      routes[method][a] = m.to_s.tr('_','.')
    end

    def get(&block)
      @method = 'GET'
      instance_eval &block
    end

    def post(&block)
      @method = 'POST'
      instance_eval &block
    end
  end
end
