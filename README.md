m-statsd
========

Tiny statsd implementation



create keyspace mstatsd;                        
use mstatsd;

create column family counters
  with column_type = 'Standard'
  and comparator = 'UTF8Type'
  and default_validation_class = 'UTF8Type'
  and key_validation_class = 'UTF8Type';

create column family gauges
  with column_type = 'Standard'
  and comparator = 'UTF8Type'
  and default_validation_class = 'UTF8Type'
  and key_validation_class = 'UTF8Type';

create column family timers
  with column_type = 'Standard'
  and comparator = 'UTF8Type'
  and default_validation_class = 'UTF8Type'
  and key_validation_class = 'UTF8Type';