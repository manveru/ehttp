module HTTP
  class Client < EventMachine::Connection
    attr_reader :response

    def post_init # called from within initialize
      @response = HTTP::Response.new
      self.comm_inactivity_timeout = 5
    end

    def send_request(request)
      request.each do |line|
        send_line(line)
      end

      send_line ''
      self
    end

    # TODO: figure out how to avoid EM::stop_event_loop
    #       as far as i can understand that will terminate any other
    #       connections, but there seems to be no way to get past EM::run
    #       otherwise, which we need to if the user wants to avoid wrapping the
    #       whole application in an EM::run (they do, trust me)

    def receive_data(data)
      @response.parse(data)

      if @response['Connection'] =~ /close/i
        close_connection
      end

      EM::stop_event_loop
    end

    def unbind
      @response.finalize

      unless @response.status
        @response.errors[:connection] = "Couldn't establish connection"
      end

      EM::stop_event_loop
    end

    def send_line(line)
      send_data "#{line}\r\n"
    end
  end
end
