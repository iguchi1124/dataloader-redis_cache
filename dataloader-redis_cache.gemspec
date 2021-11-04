require_relative 'lib/dataloader/redis_cache/version'

Gem::Specification.new do |spec|
  spec.name = "dataloader-redis_cache"
  spec.version = Dataloader::RedisCache::VERSION
  spec.authors = ["Shota Iguchi"]
  spec.email = ["shota-iguchi@cookpad.com"]
  spec.summary = "Dataloader redis cache plugin"
  spec.license = "MIT"
  spec.files = Dir["lib/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.test_files = Dir["spec/**/*"]
  spec.add_dependency "dataloader"
  spec.add_development_dependency "mock_redis"
end
