#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:24:22 +0800
require_relative 'lib/mapper'
# require 'yaml'

Map.get do
  index '/'
  tv '/tv'
  tv '/teevs'
  movie '/movie'
  movie '/mov'
  doc_md '/doc'  #x.md.erb methods are md processed erbs
end

# puts Map.routes.to_yaml
