module HTTP
  class Request
    attr_accessor :uri, :method, :version
    attr_reader :headers

    def initialize(uri, headers = {})
      @headers = HeaderHash.new(headers)
      @method = 'GET'
      @version = 'HTTP/1.1'
      @uri = sanitize_uri(uri)
    end

    def each
      yield "#{method} #{uri.path} #{version}"

      headers['host'] ||= "#{uri.host}:#{uri.port}"

      headers.each do |key, value|
        yield "#{key}: #{value}"
      end
    end

    def connect; send_request :connect; end
    def delete;  send_request :delete;  end
    def get;     send_request :get;     end
    def head;    send_request :head;    end
    def options; send_request :options; end
    def post;    send_request :post;    end
    def put;     send_request :put;     end
    def trace;   send_request :trace;   end

    def send_request(method = 'GET')
      self.method = method.to_s.upcase
      response = nil

      HTTP::Connection.open(uri.host, uri.port) do |conn|
        conn.send_request(self)
        response = conn.response
      end

      return response
    end

    def [](key)
      @headers[key]
    end

    def []=(key, value)
      @headers[key] = value
    end

    private

    def sanitize_uri(obj)
      case obj
      when URI
        obj
      else
        URI(obj.to_str)
      end
    end
  end
end
