require 'spec/helper'

# Saddle the horse, we go for a ride
require 'spec/stallion'

describe HTTP::Request do
  describe 'perform HTTP methods' do
    http = HTTP::Request.new('http://localhost:8080/')

    should 'perform CONNECT' do
      got = http.connect
      got.errors.should.be.empty
      got.status.should == 200
    end

    should 'perform DELETE' do
      http.delete.status.should == 200
    end

    should 'perform GET' do
      http.get.status.should == 200
    end

    should 'perform HEAD' do
      http.head.status.should == 200
    end

    should 'perform OPTIONS' do
      http.options.status.should == 200
    end

    should 'perform POST' do
      http.post.status.should == 200
    end

    should 'perform PUT' do
      http.put.status.should == 200
    end

    should 'perform TRACE' do
      http.trace.status.should == 200
    end
  end

  describe 'HTTP method GET' do
    should 'perform simple GET' do
      got = HTTP.get('http://localhost:8080/')
      got.status.should == 200
      got.body.should == 'Hello, World!'
    end
  end
end
