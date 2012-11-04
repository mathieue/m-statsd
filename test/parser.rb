require 'helper'

class TestParser < Test::Unit::TestCase
	def test_store_counter
		parser = MStatsd::Parser.new
		parser.parse 'userlogouts:1|c'

		assert_equal(1, parser.counters.size)
	end

	def test_store_multiple_items
		parser = MStatsd::Parser.new
		parser.parse "userlogouts:1|c\nuserlogins:1|c"

		assert_equal(2, parser.counters.size)
	end


	def test_store_timers
		parser = MStatsd::Parser.new
		parser.parse 'glork:320|ms'

		assert_equal(1, parser.timers.size)
	end

	def test_store_gauge
		parser = MStatsd::Parser.new
		parser.parse 'meter:320|g'

		assert_equal(1, parser.gauges.size)
	end


	def test_get_and_clear_clear_stats
		parser = MStatsd::Parser.new

		parser.parse 'userlogouts:1|c'
		parser.parse 'glork:320|ms'
		parser.parse 'meter:320|g'

		counters, timers, gauges = parser.get_and_clear_stats!

		assert_equal(0, parser.counters.size)
		assert_equal(0, parser.timers.size)
		assert_equal(0, parser.gauges.size)	

		assert_equal(1, counters.size)
		assert_equal(1, timers.size)
		assert_equal(1, gauges.size)	
	end
end