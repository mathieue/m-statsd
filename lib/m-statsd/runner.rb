module MStatsd
  class Runner
    def self.run!(config)
      EM::run do
        server = EM::open_datagram_socket('192.168.2.2', 8125, Server)
        cassandra = MStatsd::MCassandra.new(config['cassandra'])

        server.add_backend(cassandra)
        EM::add_periodic_timer(1) do
          server.flush!
        end
      end
    end
  end
end