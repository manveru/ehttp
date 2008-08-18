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

    # Returns resulting proxy URI if parameters are valid or false if proxy has
    # been disabled
    #
    # Set proxy by passing a string or URI, it will be sanitized and coerced
    # into http unless you specify https by prefixing with https://
    #
    #     http.use_proxy('https://proxy:8000')
    #     http.use_proxy('user@proxy:8000')
    #     http.use_proxy('http://user:password@proxy:8000')
    #
    #
    # Set proxy by passing explicit arguments, this doesn't allow for https (yet)
    #
    #     http.use_proxy('localhost', 8000)
    #     http.use_proxy('localhost', 8000, 'user')
    #     http.use_proxy('localhost', 8000, 'user', 'password')
    #
    #
    # Passing false|nil or no arguments at all will disable usage of proxy
    # explicitly
    #
    # --
    # Internally the @proxy is stored as URI or false

    def use_proxy(uri_or_host = nil, port = nil, user = nil, password = nil)
      if uri_or_host
        if port
          @proxy = URI("http://#{uri_or_host}")
          @proxy.port = port.to_i
          @proxy.user = user.to_s
          @proxy.password = password.to_s
        else
          @proxy = sanitize_uri(uri)
        end
      else
        @proxy = false
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

      Connection.open(uri.host, uri.port) do |conn|
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

    # Returns URI
    # Prepends http:// if scheme is missing
    # Sets '/' as path if no path is found

    def sanitize_uri(obj)
      case obj
      when URI
        obj
      else
        string = obj.to_str.sub(%r'^(?!https?://)', 'http://')
        uri = URI(string)
        uri = URI("#{string}/") if uri.path.strip.empty?
        uri
      end
    end
  end
end
