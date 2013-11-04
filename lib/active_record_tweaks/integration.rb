require 'active_support/concern'

module ActiveRecordTweaks
  module Integration
    extend ActiveSupport::Concern

    # Returns a cache key that can be used to identify this record.
    # Timestamp is not used to allow custom caching expiration
    # (e.g. Cookie based caching with expiration )
    #
    #   Product.new.cache_key     # => "products/new"
    #   Product.find(5).cache_key # => "products/5" (updated_at not available)
    #   Person.find(5).cache_key  # => "people/5" (updated_at available)
    def cache_key_without_timestamp
      case
      when new_record?
        "#{self.class.model_name.cache_key}/new"
      else
        "#{self.class.model_name.cache_key}/#{id}"
      end
    end
  end
end
