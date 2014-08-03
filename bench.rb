require 'benchmark'
require_relative 'lib/activesupport/cache/elasticsearch_store'

REPEATS = 500

def assert a, b
  if a != b
    $stderr.puts "a: #{a.inspect} b: #{b.inspect}"
    raise "a != b"
  end
end

def bench name, count, store
  puts "#{name}: #{count} actions per run"

  array_1k = ["a"] * 1024
  array_20k = ["a"] * 1024 * 20

  Benchmark.bm do |x|
    x.report("missing") do
      REPEATS.times do |i|
        store.read("key#{i}")
      end
    end
    x.report("write 1k array") do
      REPEATS.times do |i|
        store.write("key_1k_#{i}", array_1k)
      end
    end
    x.report("write 20k array") do
      REPEATS.times do |i|
        store.write("key_20k_#{i}",array_20k)
      end
    end
    x.report("read 1k") do
      REPEATS.times do |i|

        assert(store.read("key_1k_#{i}"), array_1k)
      end
    end
    x.report("read 20k") do
      REPEATS.times do |i|
        assert(store.read("key_20k_#{i}"), array_20k)
      end
    end
  end
  puts
end

require 'redis-activesupport'

index_name = "cache_benchmark_#{Process.pid}"
store = ActiveSupport::Cache::ElasticsearchStore.new(index_name: index_name)

redis = ActiveSupport::Cache::RedisStore.new

bench "redis", 500, redis

MultiJson.use(:json_gem)
bench "es (Ruby JSON)", 500, store

MultiJson.use(:yajl)
bench "es (YAJL)", 500, store
