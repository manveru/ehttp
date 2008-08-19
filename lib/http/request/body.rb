module HTTP
  class Request
    class Body
      def initialize(request, object)
        @request = request
        @body = prepare(object)
      end

      def prepare(object)
        case object
        when self.class
          object.body
        when File
          @request['content-length'] ||= object.stat.size
          object
        when String, StringIO
          @request['content-length'] ||= object.size
          object
        else
          # raise("Unknown body: %p" % object)
        end
      end

      def each
        case @body
        when IO
          @body.rewind
          yield(@body.read(1024)) until @body.eof?
          @body.rewind
        else
          yield(@body.to_str) if @body
        end
      end
    end
  end
end
