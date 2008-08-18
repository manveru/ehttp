require 'strscan'

module HTTP
  class URI
    attr_accessor :original, :schema, :host, :port, :query, :path

    def initialize(string)
      @original = string

      @schema = @host = @port = @query = nil

      @parsed = false
      @parser = Parser.new(string)
    end

    def parse
      return @parsed if @parsed

      @parsed = @parser.parse
    end

    def schema; @schema ||= parse.schema end
    def host;   @host   ||= parse.host   end
    def port;   @port   ||= parse.port   end
    def query;  @query  ||= parse.query  end
    def path;   @path   ||= parse.path   end

    def to_s
      @host
    end

    class Parser
      attr_reader :schema, :host, :port, :query, :path

      def initialize(string)
        @scanner = StringScanner.new(string)
      end

      def parse
        @schema = @host = @port = @path = nil
        @query = {}
        @scanner.pos = 0

        while_scanning{ step }
        self
      end

      def step
        if scan(/(https?|s?ftp):\/\//)
          @schema = @scanner[1]
        elsif scan(/\w+/)
          @host ||= matched
        elsif scan(/:(\d+)/)
          @port = @scanner[1].to_i
        elsif scan(/\/[^?]+/)
          @path = matched
        elsif scan(/\?/)
          while_scanning{ step_query }
        end
      end

      def step_query
        if scan(/([^;&=]+)=([^;&=]+)[&;]?/)
          @query[@scanner[1]] = @scanner[2]
        end
      end

      def while_scanning
        until @scanner.eos?
          pos = @scanner.pos

          yield

          if pos == @scanner.pos
            raise("Scanner didn't move: %p" % @scanner)
          end
        end
      end

      def scan(regex)
        @scanner.scan(regex)
      end

      def matched
        @scanner.matched
      end
    end
  end
end

require 'bacon'
require 'pp'
Bacon.summary_on_exit
Bacon.extend(Bacon::TestUnitOutput)

describe HTTP::URI do
  def uri(string)
    HTTP::URI.new(string)
  end

  should 'parse http' do
    u = uri('http://localhost:7000/foo?bar=duh&a=b;c=d')
    u.schema.should == 'http'
    u.host.should == 'localhost'
    u.port.should == 7000
    u.path.should == '/foo'
    u.query.should == {'bar' => 'duh', 'a' => 'b', 'c' => 'd'}
  end

  should 'parse https' do
    u = uri('https://localhost:7000/foo?bar=duh&a=b;c=d')
    u.schema.should == 'https'
    u.host.should == 'localhost'
    u.port.should == 7000
    u.path.should == '/foo'
    u.query.should == {'bar' => 'duh', 'a' => 'b', 'c' => 'd'}
  end

  should 'parse ftp' do
    u = uri('ftp://localhost:7000/foo?bar=duh&a=b;c=d')
    u.schema.should == 'ftp'
    u.host.should == 'localhost'
    u.port.should == 7000
    u.path.should == '/foo'
    u.query.should == {'bar' => 'duh', 'a' => 'b', 'c' => 'd'}
  end

  should 'parse sftp' do
    u = uri('sftp://localhost:7000/foo?bar=duh&a=b;c=d')
    u.schema.should == 'sftp'
    u.host.should == 'localhost'
    u.port.should == 7000
    u.path.should == '/foo'
    u.query.should == {'bar' => 'duh', 'a' => 'b', 'c' => 'd'}
  end
end
