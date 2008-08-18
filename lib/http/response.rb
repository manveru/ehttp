module HTTP
  # http://www.w3.org/Protocols/rfc2616/rfc2616-sec6.html#sec6
  #
  # Response = Status-Line
  #            *( ( general-header |
  #                 response-header |
  #                 entity-header )
  #                CRLF
  #             )  ; Section 7.1
  #            CRLF
  #            [ message-body ]

  class Response
    # Status-Line
    attr_reader :version, :status, :phrase
    attr_reader :headers, :body

    def initialize
      @headers = HeaderHash.new
      @body = ''
    end

    # Easy Access to headers

    def [](key)
      @headers[key]
    end

    # Segmenting

    GENERAL_HEADERS = %w[
      Cache-Control Connection Date Pragma Trailer Transfer-Encoding Upgrade
      Via Warning
    ]

    RESPONSE_HEADERS = %w[
      Accept-Ranges Age ETag Location Proxy-Authenticate Retry-After Server
      Vary WWW-Authenticate
    ]

    ENTITY_HEADERS = %w[
      Allow Content-Encoding Content-Language Content-Length Content-Location
      Content-MD5 Content-Range Content-Type Expires Last-Modified
    ]


    #  There are a few header fields which have general applicability for both
    #  request and response messages, but which do not apply to the entity
    #  being transferred. These header fields apply only to the message being
    #  transmitted.

    def general_headers
      return headers_subset(GENERAL_HEADERS)
    end

    # The response-header fields allow the server to pass additional
    # information about the response which cannot be placed in the Status-
    # Line. These header fields give information about the server and about
    # further access to the resource identified by the Request-URI.

    def response_headers
      return headers_subset(RESPONSE_HEADERS)
    end

    # Entity-header fields define metainformation about the entity-body or, if
    # no body is present, about the resource identified by the request.

    def entity_headers
      return headers_subset(ENTITY_HEADERS)
    end


    # Free memory for next cycle of GC

    def finalize
      @scanner = nil
    end

    # Small helper to produce subsets of the header hash, use Hash#reject since
    # Enumerable#select returns an Array.

    def headers_subset(keys)
      @headers.reject do |key, value|
        not keys.include?(key)
      end
    end

    STATUS_MEANING = {
      # 1xx: Informational - Request received, continuing process
      (100..199) => :informational,

      # 2xx: Success - The action was successfully received, understood, and
      # accepted
      (200..299) => :success,

      # 3xx: Redirection - Further action must be taken in order to complete the
      # request
      (300..399) => :redirection,

      # 4xx: Client Error - The request contains bad syntax or cannot be
      # fulfilled
      (400..499) => :client_error,

      # 5xx: Server Error - The server failed to fulfill an apparently valid
      # request
      (500..599) => :server_error,

      # HTTP status codes are extensible.
      # The RFC doesn't say anything about things > 599 other than they must
      # not be cached.
      (600..999) => :extended,
    }

    def informational? ; status_meaning == :informational  end
    def success?       ; status_meaning == :success        end
    def redirection?   ; status_meaning == :redirection    end
    def client_error?  ; status_meaning == :informational  end
    def server_error?  ; status_meaning == :server_error   end
    def extended?      ; status_meaning == :extended       end

    def status_meaning
      STATUS_MEANING.each do |range, meaning|
        return meaning if range.include?(status)
      end

      return :invalid
    end
    alias status_class status_meaning

    # Parsing

    def parse(string)
      @scanner = StringScanner.new(string)

      parse_status
      parse_headers
      parse_body
    end

    private

    STATUS = /(HTTP\/\d+\.\d+)\s+(\d\d\d)\s+(.*)\r\n/

    def parse_status
      scan(STATUS)

      @version = @scanner[1]
      @status  = @scanner[2].to_i
      @phrase  = @scanner[3]
    end

    HEADER = /^(.*?):\s*(.*)\r\n/

    def parse_headers
      while scan(HEADER)
        key, value = @scanner[1], @scanner[2]

        case key
        when 'Date'
          value = Time.httpdate(value)
        when 'Content-Length'
          value = value.to_i
        end

        @headers[key] = value
      end
    end

    def parse_body
      scan(/\r\n/)
      @body << @scanner.rest
      @scanner.terminate
    end

    # Easier access to StringScanner

    def scan(regex)
      @scanner.scan(regex)
    end
  end
end
