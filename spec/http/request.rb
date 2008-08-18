require 'lib/http'

require 'rack'
require 'pp'

require 'bacon'
Bacon.summary_on_exit
Bacon.extend(Bacon::TestUnitOutput)

def to(uri)
  HTTP::Request.new(uri)
end

describe HTTP::Request do
  describe 'perform HTTP method' do
    http = to('http://localhost:8080/')

    %w[
      CONNECT DELETE GET HEAD OPTIONS POST PUT TRACE
    ].each do |method|
      should "#{method}" do
        got = http.send(method.downcase)
        got.status.should == 200
        got.body.should == 'Hello, World'
      end
    end
  end

  describe 'HTTP method GET' do
    should 'perform simple GET' do
      got = HTTP.get('http://localhost:8080/')
      got.status.should == 200
      got.body.should == 'Hello, World'
    end
  end
end
