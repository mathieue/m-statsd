module MStatsd
  class Parser
    attr_reader :timers, :counters, :gauges


    def initialize
      @timers = {}
      @counters = {}
      @gauges = {}
    end

    def get_and_clear_stats!
      counters = @counters.dup
      @counters.clear

      timers = @timers.dup
      @timers.clear

      gauges = @gauges.dup
      @gauges.clear
      
      [counters, timers, gauges]
    end

    def parse(data)
      data.split("\n").each do |update|
        parse_update(update)
      end
    end

    def parse_update(update)
      bits = update.split(":")
      key  = bits.first.gsub(/\s+/, '_').gsub(/\//, '-').gsub(/[^a-zA-Z_\-0-9\.]/, '')

      bits << '1' if bits.empty?

      bits.each do |b|
        next unless b.include? '|'

        sample_rate = 1
        fields      = b.split('|')

        if fields[1]


          case fields[1].strip
          when 'ms'
            @timers[key] ||= []
            @timers[key] << fields[0].to_f || 0
          when 'c'
            /^@([\d\.]+)/.match(fields[2]) { |m| sample_rate = m[1].to_f }
            @counters[key] ||= 0
            @counters[key] += (fields[0].to_f || 1) * (1 / sample_rate)
          when 'g'
            @gauges[key] = fields[0].to_f
          end
        end
      end
    end
  end
end