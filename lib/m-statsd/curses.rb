require 'rubygems'
require 'ncurses'
require 'eventmachine'


module MStatsd
  class Graph
    def initialize(config)
      @cassandra_client = Cassandra.new('mstatsd', config['cassandra'], :connect_timeout => 1000, :retries => 10, :timeout => 15 )
      @cassandra_client.disable_node_auto_discovery! 
    end
    def draw
      Ncurses.initscr
      Ncurses.refresh

      @cols = Ncurses.getmaxx(Ncurses.stdscr)
      @rows = Ncurses.getmaxy(Ncurses.stdscr)

      @windows = {}
      @windows[:graph] = Ncurses.newwin(@rows, @cols, 0, 0)

      while true
        @windows[:graph].clear
        display_graph
        @windows[:graph].refresh
        sleep(1)
      end
    end
    def display_graph
      data = get_data
      max = data.max 
      data.map! { |v| v.to_f * @rows / max }.map! { |v| v.ceil  }
      data.each_with_index do |point, i|
        draw_bar(i, point)
      end
      # cols = Ncurses.getmaxx(Ncurses.stdscr)
      # rows = Ncurses.getmaxy(Ncurses.stdscr)

      # @windows[:info].refresh
    end

    def draw_bar(x, value)
      value ||= 0
      value -= 1
      value.to_i.times do |v|
        y = @rows - v -1
       @windows[:graph].mvaddstr(y, x, "#")
      end
    end

    def get_data
      key = 'graylog2.esdoc.count-2012-12-12-14'
      values = @cassandra_client.get(:counters, key, {:reversed => true, :count => @cols })
      data ||= []
      values.each do |time, value|
        data << value.to_i
      end
      data
    end
  end
end






