# Elasticsearch::Store

[![Gem Version](https://badge.fury.io/rb/elasticsearch-store.svg)](http://badge.fury.io/rb/elasticsearch-store) [![Build Status](https://travis-ci.org/mipearson/elasticsearch-store.svg)](https://travis-ci.org/mipearson/elasticsearch-store) [![Code Climate](https://codeclimate.com/github/mipearson/elasticsearch-store/badges/gpa.svg)](https://codeclimate.com/github/mipearson/elasticsearch-store)

ElasticSearch-backed Ruby on Rails cache.

Experimental - only tested against a single, local ES instance.

Abandoned for now: benchmarks versus redis-store are quite awful:

```
redis: 500 actions per run
       user     system      total        real
missing  0.020000   0.010000   0.030000 (  0.043769)
write 1k array  0.080000   0.010000   0.090000 (  0.091629)
write 20k array  0.710000   0.030000   0.740000 (  0.805244)
read 1k  0.080000   0.010000   0.090000 (  0.095346)
read 20k  0.850000   0.070000   0.920000 (  0.940215)

es (Ruby JSON): 500 actions per run
       user     system      total        real
missing  0.340000   0.060000   0.400000 (  0.482999)
write 1k array  0.520000   0.090000   0.610000 (  1.394557)
write 20k array  3.800000   0.170000   3.970000 ( 15.465462)
read 1k  0.580000   0.110000   0.690000 (  0.849519)
read 20k  4.430000   0.500000   4.930000 (  5.252917)

es (YAJL): 500 actions per run
       user     system      total        real
missing  0.410000   0.090000   0.500000 (  0.662786)
write 1k array  0.470000   0.110000   0.580000 (  1.418989)
write 20k array  1.200000   0.160000   1.360000 ( 14.092673)
read 1k  0.570000   0.090000   0.660000 (  0.842748)
read 20k  2.860000   0.120000   2.980000 (  3.324823)
```

Compatible with Ruby 1.9.3 & Rails 3.2 and above.

## Installation

Add this line to your application's Gemfile:

    gem 'elasticsearch-store'

And then execute:

    $ bundle

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it ( https://github.com/[my-github-username]/elasticsearch-store/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
