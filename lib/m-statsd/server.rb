require 'eventmachine'

module MStatsd
  class Server < EM::Connection
    def initialize
      @parser = MStatsd::Parser.new
    end
 
    def add_backend(backend)
      @backends ||= []
      @backends << backend
    end

    def receive_data(msg)
      @parser.parse(msg)
    end

    def flush!
      counters, timers, gauges = @parser.get_and_clear_stats!
      @backends.each { |backend| backend.store!(counters, timers, gauges, Time.now) }
    end
  end
end