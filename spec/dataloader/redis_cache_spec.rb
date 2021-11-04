require 'dataloader'
require 'mock_redis'

RSpec.describe Dataloader::RedisCache do
  let(:redis) { MockRedis.new }
  let(:dataloader) do
    Dataloader.new(cache: Dataloader::RedisCache.new(redis, memory_cache: memory_cache)) do |keys|
      keys.map do |key|
        data[key]
      end
    end
  end

  let(:memory_cache) do
    {}
  end

  let(:data) do
    {
      example_1: :value_1,
    }
  end

  it "load data from datasource" do
    expect(redis).to receive(:get).with(:example_1).and_return(nil)
    expect(memory_cache).not_to be_key(:example_1)
    promise = dataloader.load(:example_1)
    expect(promise.sync).to eq(:value_1)
    expect(memory_cache).to be_key(:example_1)
  end

  context "when data cached in memory" do
    let(:memory_cache) do
      { example_2: Marshal.dump(:value_2) }
    end

    it "load data from memory cache" do
      expect(redis).not_to receive(:get)
      promise = dataloader.load(:example_2)
      expect(promise.sync).to eq(:value_2)
    end
  end

  context "when data cached in redis" do
    before do
      redis.set(:example_3, Marshal.dump(:value_3))
    end

    it "load data from memory cache" do
      promise = dataloader.load(:example_3)
      expect(promise.sync).to eq(:value_3)
    end
  end

  it "does not create negative cache" do
    promise = dataloader.load(:example_4)
    expect(memory_cache).not_to be_key(:example_4)
  end
end