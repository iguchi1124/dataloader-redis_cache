require "concurrent"
require "dataloader/redis_cache/version"

class Dataloader
  class RedisCache
    def initialize(redis, replica_redis: nil, prefix: nil, cache: Concurrent::Map.new)
      @cache = cache
      @writer = redis
      @reader = replica_redis || redis
      @prefix = prefix
    end

    def compute_if_absent(key)
      value = get(key)
      return value if value

      promise = yield
      promise.then do |value|
        set(key, value) if value
        value
      end
    end

    def reset(key)
      del(key)
    end

    private

    def gen_key(key)
      [@prefix, key.to_s].compact.join(':')
    end

    def get(key)
      key_str = gen_key(key)
      value_str = @cache[key_str] || @reader.get(key_str)
      Marshal.load(value_str) if value_str
    end

    def set(key, value)
      key_str = gen_key(key)
      value_str = Marshal.dump(value)
      @writer.set(key_str, value_str)
      @cache[key_str] = value_str
    end

    def del(key)
      key_str = gen_key(key)
      @writer.del(key_str)
      @cache.delete(key_str)
    end
  end
end
