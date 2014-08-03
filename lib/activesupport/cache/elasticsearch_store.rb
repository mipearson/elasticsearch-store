# encoding: utf-8

begin
  require 'elasticsearch'
rescue LoadError => e
  $stderr.puts <<-EOF
    You don't have elasticsearch installed in your application.
    Please add it to your Gemfile and run bundle install.
  EOF
  raise e
end

require 'digest/md5'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/slice'
require 'active_support/cache'

module ActiveSupport
  module Cache
    # A cache store implementation which stores data in ElasticSearch:
    # http://www.elasticsearch.org/
    #
    # This store is experimental and was developed against a non-clustered
    # ElasticSearch environment.
    class ElasticsearchStore < Store
      # Creates a new ElasticstoreSearch object, with the given elasticsearch
      # server addresses. The addresses and the randomize_hosts,
      # retry_on_failure and reload_connections options are passed verbatim
      # to Elasticsearch::Client.new.
      #
      # Defaults to 'localhost:9200' if no addresses are specified.
      #
      # Will create an index named 'cache' unless the :index_name option is
      # specified.
      def initialize(*addresses)
        addresses = addresses.flatten
        options = addresses.extract_options!

        es_options = options.extract!(:retry_on_failure, :randomize_hosts, :reload_connections)
        @index_name = options.delete(:index_name) || 'cache'

        if options[:namespace]
          raise ArgumentError, ":namespace option not yet supported"
        end

        super(options)

        addresses = %w(localhost:9200) if addresses.length == 0
        es_options[:addresses] = addresses

        @client = Elasticsearch::Client.new(es_options)
        @index_created = false
      end

      # Clear the entire cache in our Elasticsearch index. This method should
      # be used with care when shared cache is being used.
      def clear(_options = nil)
        # TODO: Support namespaces
        @client.delete_by_query index: @index_name, type: 'entry', body: { query: { match_all: {} } }
      end

      protected

      def read_entry(key, options) # :nodoc:
        document = @client.get index: @index_name, type: 'entry', fields: %w(_ttl _source), id: key

        fields = document['fields'] || {}
        source = document['_source'] || {}
        expires_in = (fields['_ttl'].to_f / 1000.0) if fields.key? '_ttl'

        Entry.new(
          source["value"],
          options.merge(expires_in: expires_in)
        )
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
        nil
      end

      def write_entry(key, entry, _options) # :nodoc:
        request = { value: entry.value }
        if entry.expires_at
          expires_in = (entry.expires_at - Time.now.to_f) * 1000
          request[:_ttl] = [expires_in, 1].max
        end

        @client.index index: @index_name, type: 'entry', id: key, body: request
      end

      def delete_entry(key, _options) # :nodoc:
        @client.delete index: @index_name, type: 'entry', id: key
      end

      private

      def create_index
        @index_created = true

        # TODO: Check index mappings to make sure they match ours, warn if they don't.
        @client.indices.create index: @index_name, body: {
          settings: { index: {
            number_of_replicas: 0
          } },
          mappings: { entry: { properties: {
            _ttl: { enabled: true },
            value: { type: 'string', index: 'no' }
          } } }
        }
      rescue Elasticsearch::Transport::Transport::Errors::BadRequest => e
        raise unless e.message =~ /IndexAlreadyExists/
      end
    end
  end
end
