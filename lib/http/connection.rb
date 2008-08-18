module HTTP
  class Connection
    def self.open(host, port = 80)
      EventMachine.epoll # safe?

      connection = nil

      EM::run do
        connection = EventMachine::connect(host, port, HTTP::Client)
        yield connection
      end

      connection
    end
  end
end
