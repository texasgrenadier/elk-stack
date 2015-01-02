require 'rubygems'
require 'redis'

redis = Redis.new(:host => "192.168.33.10", :port => 6379)
puts redis.ping

redis.set('foo','bar')
puts redis.get('foo')
