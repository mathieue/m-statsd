require 'cassandra'
require 'cassandra/1.1'

module MStatsd
  class MCassandra
    def initialize(config)
      @cassandra = Cassandra.new('mstatsd', config, :connect_timeout => 1000, :retries => 10, :timeout => 15 )
      @cassandra.disable_node_auto_discovery! 
    end

    def store!(counters, timers, gauges, timestamp)
      counters.each { |k, v| store_counter(k, v, timestamp) }
      timers.each { |k, v| v.each { |t| store_timer(k, t, timestamp) } }
      gauges.each { |k, v| store_gauge(k, v, timestamp) }
    end

    def store_counter(k, v, timestamp)
       time_slice = get_time_slice(timestamp)
       key = "#{k}-#{time_slice}"
       @cassandra.insert('counters', key, timestamp.to_i.to_s => v.to_s)
    end

    def store_gauge(k, v, timestamp)
       time_slice = get_time_slice(timestamp)
       key = "#{k}-#{time_slice}"
       store_keys('gauges', k, key)
       @cassandra.insert('gauges', key, timestamp.to_i.to_s => v.to_s)
    end

    def store_timer(k, v, timestamp)
       time_slice = get_time_slice(timestamp)
       key = "#{k}-#{time_slice}"
       @cassandra.insert('timers', key, timestamp.to_i.to_s => v.to_s)
    end

    def get_time_slice(timestamp)
      timestamp.strftime('%Y-%m-%d-%H')
    end

    def store_keys(type, key, key_slice)
      @key_cache ||= {}
      @key_cache[key] ||= ''
      unless @key_cache[key] == key_slice
       @cassandra.insert(type, key, key_slice => '')
       @key_cache[key] = key_slice
      end
    end
  end
end