require 'pp'
require 'socket'
require 'strscan'
require 'time'
require 'uri'

require 'rubygems'
require 'eventmachine'

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'http/request'
require 'http/request/body'
require 'http/response'
require 'http/header_hash'
require 'http/connection'
require 'http/client'
require 'http/util'

module HTTP
  def self.connect(uri) Request.new(uri).connect end
  def self.delete(uri)  Request.new(uri).delete  end
  def self.get(uri)     Request.new(uri).get     end
  def self.head(uri)    Request.new(uri).head    end
  def self.options(uri) Request.new(uri).options end
  def self.post(uri)    Request.new(uri).post    end
  def self.put(uri)     Request.new(uri).put     end
  def self.trace(uri)   Request.new(uri).trace   end
end
