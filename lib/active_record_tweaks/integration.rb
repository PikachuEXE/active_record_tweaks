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

    module ClassMethods
      # Returns a cache key for the ActiveRecord class based
      # based on count and maximum value of update timestamp columns
      # (e.g. Cookie based caching with expiration)
      #
      #   Product.cache_key     # => "products/0" (empty, has updated timestamp columns or not)
      #   Product.cache_key     # => "products/1" (not empty but has no updated timestamp columns)
      #   Person.cache_key     # => "people/1-20071224150000" (not empty and has updated timestamp columns)
      #
      # @param [Array<String, Symbol>] args The column name with timestamp to check
      def cache_key(*args)
        timestamp_columns = args.empty? ? [:updated_at] : args

        if timestamp = max_updated_column_timestamp_for_cache_key(timestamp_columns)
          timestamp = timestamp.utc.to_s(cache_timestamp_format)
          "#{self.model_name.cache_key}/all/#{self.count}-#{timestamp}"
        else
          "#{self.model_name.cache_key}/all/#{self.count}"
        end
      end

      def max_updated_column_timestamp_for_cache_key(timestamp_columns)
        available_timestamp_columns = timestamp_columns.select { |c| self.column_names.include?(c.to_s) }

        if (timestamps = available_timestamp_columns.map { |column| self.maximum(column) }.compact).present?
          timestamps.map { |ts| ts.to_time }.max
        end
      end
    end
  end
end
