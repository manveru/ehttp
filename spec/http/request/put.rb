require 'spec/helper'
# require 'spec/stallion'

require 'ruby-prof'

http = HTTP::Request.new('localhost:7000')
http.body = File.new(__FILE__)
http.open do |req|
  got = req.post
end
