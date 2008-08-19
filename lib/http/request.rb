module HTTP
  class Request
    USER_AGENT = 'sHTTP 0.1'
    VERSION = 'HTTP/1.1'
    METHODS = %w[
      CONNECT DELETE GET HEAD OPTIONS POST PUT TRACE
    ]

    attr_accessor :uri, :method, :version, :body, :user_agent
    attr_reader :headers

    def initialize(uri, headers = {})
      @headers = HeaderHash.new(headers)
      @uri = sanitize_uri(uri)

      @user_agent, @version = USER_AGENT, VERSION
      @body = nil
      @method = 'GET'
    end

    METHODS.each do |m|
      method = m.downcase

      define_method(method){ send_request(method) }
      define_method("#{method}?"){ self.method == m }
    end

    def each
      @send_body = Body.new(self, @body)
      prepare_headers

      yield request_line
      each_header{|header| yield header }
      yield("\r\n")
      each_body{|body| yield(body) }
    end

    def prepare_headers
      self['accept'] ||= '*/*'
      self['user-agent'] ||= USER_AGENT
      self['expect'] ||= '100-continue' if post? or put?
    end

    def request_line
      "#{method} #{uri.path} #{version}\r\n"
    end

    def each_header
      headers.each do |key, value|
        yield "#{key}: #{value}\r\n" if key and value
      end
    end

    def each_body
      @send_body.each{|chunk| yield chunk }
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

    # TODO: refactor, this is not working out
    def send_request(method = 'GET')
      self.method = method
      response = nil

      if @connection
        response = @connection.send_request(self)
      else
        Connection.open(uri.host, uri.port) do |conn|
          @connection = conn

          if block_given?
            response = yield(self)
          else
            response = send_request(method)
          end
        end

        @connection = nil
      end

      return response
    end

    def method=(name)
      @method = name.to_s.upcase
    end

    def [](key)
      @headers[key]
    end

    def []=(key, value)
      @headers[key] = value
    end

    def open
      send_request do |conn|
        yield(self)
      end
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
