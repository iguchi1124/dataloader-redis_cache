require "dataloader/redis_cache/version"

class Dataloader
  class RedisCache
    def initialize(redis, replica_redis: nil, memory_cache: {})
      @memory_cache = memory_cache
      @writer = redis
      @reader = replica_redis || redis
    end

    def compute_if_absent(key, &block)
      value = get(key)
      return value if value

      promise = block.call
      promise.then do |value|
        set(key, value) if value
        value
      end
    end

    private

    def get(key)
      value_str = @memory_cache[key] || @reader.get(key)
      Marshal.load(value_str) if value_str
    end

    def set(key, value)
      value_str = Marshal.dump(value)
      @writer.set(key, value_str)
      @memory_cache[key] = value_str
    end
  end
end
