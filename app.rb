#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-01 15:24:22 +0800
require_relative 'lib/mapper'
require 'pp'

# single path mapping
# get <path> <**locals> -> render <template>

# multi-path mapping
Map.get('/hq', '/home', title: 'Home' ){
  :index
}

# or multi declarations
Map.get do
  #template, url
  data '/data'

  #template, url, locals
  tv    '/tv',    active: 'tv'
  movie '/movie', title: 'movie time', active: 'mov'

  #template, url, new template
  movie('/mov'){ :tv } # change the target template

  #template.md.erb, url
  doc_md '/doc'  #x.md.erb template methods are markdown-processed erbs
end

Map.post do
  #template, url, locals
  data '/', title: 'Posting'
end

Map.post('/post', title: 'Posting again') do
  :data
end

Map.get('/', title: 'Tada!' ){
  :index
}

def GET(**match)
  pp match
  V.call(match[:erb], **match[:data])
end

pp Map.routes
