require 'ramaze'

class MainController < Ramaze::Controller
  engine :None
  def index
    response['content-type'] = 'text/plain'
    pp request
    pp request.body
    pp request.body.read
    request.inspect
  end
end

Ramaze.start :adapter => :thin
