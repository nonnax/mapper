#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:24:22 +0800
require_relative 'lib/mapper'
require 'yaml'

# single path mapping
# Map.get('/'){ :index }

# or multi declarations
Map.get do
  index '/',      title: 'Tada!'
  tv    '/tv',    active: 'tv'
  movie '/movie', title: 'movie time', active: 'mov'
  movie '/mov'
  doc_md '/doc'  #x.md.erb methods are md processed erbs
end

puts Map.routes.to_yaml
