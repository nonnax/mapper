# Id$ nonnax 2022-02-26 17:19:12 +0800
# frozen_string_literal: true
require_relative 'app'

use Rack::Static,
    urls: %w[/images /js /css],
    root: 'public'

run Mapper.new
