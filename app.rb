#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:24:22 +0800
require_relative 'lib/mapper'
require 'yaml'

# single path mapping
# get <path> <**locals> -> render <template>
Map.get('/', title: 'Tada!' ){ :index }

# multi-path mapping
Map.get('/hq', '/home', title: 'Home' ){ :index }

# or multi declarations
Map.get do
  tv    '/tv',    active: 'tv'
  movie '/movie', title: 'movie time', active: 'mov'
  movie( '/mov'){ :tv }
  doc_md '/doc'  #x.md.erb template methods are markdown-processed erbs
end

Map.post do
  data '/', title: 'Posting'
end

Map.post('/post', title: 'Posting again') do
  :data
end

puts Map.routes.to_yaml
