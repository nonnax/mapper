#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-04-01 15:27:49 +0800
# http routes mapper

require_relative 'viewmd'

class Mapper
  def call(env)
    path, method = env.values_at('PATH_INFO', 'REQUEST_METHOD')
    if Map.routes[method].key?(path)
      Map.routes[method][path]
         .then do |erb|
        View.render(erb)
      rescue StandardError
        nil
      end
         .then { |body| return [200, {}, [body]] if body }
    end

    [404, { 'Location' => '/' }, []] # go home
  end
end

module Map
  @routes = Hash.new { |h, k| h[k] = {} }
  class << self
    attr_accessor :routes, :method

    def method_missing(m, a)
      routes[method][a] = m.to_s.tr('_', '.')
    end

    def get(&block)
      @method = 'GET'
      instance_eval(&block)
    end

    def post(&block)
      @method = 'POST'
      instance_eval(&block)
    end
  end
end
