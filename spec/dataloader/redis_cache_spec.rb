require 'dataloader'
require 'mock_redis'

RSpec.describe Dataloader::RedisCache do
  let(:redis) { MockRedis.new }
  let(:redis_cache) { Dataloader::RedisCache.new(redis, cache: cache, prefix: 'test') }
  let(:dataloader) do
    Dataloader.new(cache: redis_cache) do |keys|
      keys.map do |key|
        data[key]
      end
    end
  end

  let(:cache) do
    {}
  end

  let(:data) do
    {
      example_1: :value_1,
    }
  end

  it "load data from datasource" do
    expect(redis).to receive(:get).with('test:example_1').and_return(nil)
    expect(cache).not_to be_key('test:example_1')
    promise = dataloader.load(:example_1)
    expect(promise.sync).to eq(:value_1)
    expect(cache).to be_key('test:example_1')
  end

  context "when data cached in memory" do
    let(:cache) do
      { 'test:example_2' => Marshal.dump(:value_2) }
    end

    it "load data from memory" do
      expect(redis).not_to receive(:get)
      promise = dataloader.load(:example_2)
      expect(promise.sync).to eq(:value_2)
    end
  end

  context "when data cached in redis" do
    before do
      redis.set('test:example_3', Marshal.dump(:value_3))
    end

    it "load data from redis" do
      promise = dataloader.load(:example_3)
      expect(promise.sync).to eq(:value_3)
    end
  end

  it "does not create negative cache" do
    promise = dataloader.load(:example_4)
    expect(cache).not_to be_key('test:example_4')
  end

  describe "#reset" do
    it "deletes redis cache" do
      expect(redis).to receive(:del).with('test:example_4')
      redis_cache.reset(:example_4)
    end
  end
end
