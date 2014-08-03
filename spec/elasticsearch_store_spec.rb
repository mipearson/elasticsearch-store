require 'rspec'
require_relative '../lib/activesupport/cache/elasticsearch_store'

index_name = "cache_test_#{Process.pid}"

describe ActiveSupport::Cache::ElasticsearchStore do

  describe ".new" do
    before do
      allow_any_instance_of(Elasticsearch::Client).to receive(:create_index)
    end

    it "should pass the addresses and some options straight through to ES::Client" do
      es_opts = { retry_on_failure: true, randomize_hosts: true, reload_connections: true }
      expect(Elasticsearch::Client).to receive(:new).with(es_opts.merge(addresses: %w(a b)))

      ActiveSupport::Cache::ElasticsearchStore.new('a', 'b', es_opts)
    end

    it "should default to localhost:9200" do
      expect(Elasticsearch::Client).to receive(:new).with(addresses: %w(localhost:9200))

      ActiveSupport::Cache::ElasticsearchStore.new
    end

    it "should error if we try to pass in a namespace" do
      expect { ActiveSupport::Cache::ElasticsearchStore.new(namespace: 'derp') }.to raise_error ArgumentError
    end
  end

  context "with an active store" do
    let(:store) { ActiveSupport::Cache::ElasticsearchStore.new(index_name: index_name) }
    after do
      # rubocop:disable Style/RescueModifier
      Elasticsearch::Client.new.indices.delete index: index_name
    end

    it "should store and retrive a cache entry" do
      expect(store.read("hello")).to be_nil
      store.write("hello", "sup")
      expect(store.read("hello")).to eq("sup")
    end

    it "should expire cache entries" do
      store.write("hi", "there", expires_in: 0.5)
      expect(store.read("hi")).to eq("there")
      sleep 1
      expect(store.read("hi")).to be_nil
    end

    it "should allow clearing the entire cache" do
      store.write("hello", "there")
      store.write("good", "bye")
      store.clear
      expect(store.read('hello')).to be_nil
      expect(store.read('good')).to be_nil
    end

  end
end
