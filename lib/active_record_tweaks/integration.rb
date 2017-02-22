module ActiveRecordTweaks
  module Integration
    def self.included(base)
      base.class_eval do
        # rubocop:disable all
        warn "[DEPRECATION] including `ActiveRecordTweaks::Integration` is deprecated. Please see README for recommanded usage."
        # rubocop:enable all

        extend ClassMethods
        include InstanceMethods
      end
    end

    module InstanceMethods
      # Returns a cache key that can be used to identify this record.
      # Timestamp is not used to allow custom caching expiration
      # (e.g. Cookie based caching with expiration )
      #
      #   Product.new.cache_key_without_timestamp     # => "products/new"
      #   Product.find(5).cache_key_without_timestamp # => "products/5" (updated_at not available)
      #   Person.find(5).cache_key_without_timestamp  # => "people/5" (updated_at available)
      def cache_key_without_timestamp
        if new_record?
          "#{self.class.model_name.cache_key}/new"
        else
          "#{self.class.model_name.cache_key}/#{id}"
        end
      end

      # Works like #cache_key in rails 4.1, but does not check column
      # Useful when you have some virtual timestamp attribute method (cached or not)
      #
      # @param attribute_names [Array<Symbol,String>]
      #   Names of attributes method(s)
      #   It does not have to be column(s)
      #
      # @raise [ArgumentError] when attribute_names is empty
      def cache_key_from_attributes(*attribute_names)
        attribute_names.any? || fail(ArgumentError)

        timestamp = max_updated_attribute_timestamp_for_cache_key(attribute_names)
        if timestamp
          timestamp = timestamp.utc.to_s(cache_timestamp_format)
          "#{self.class.model_name.cache_key}/#{id}-#{timestamp}"
        else
          "#{self.class.model_name.cache_key}/#{id}"
        end
      end
      alias cache_key_from_attribute cache_key_from_attributes

      private

      def max_updated_attribute_timestamp_for_cache_key(timestamp_attribute_names)
        timestamps = timestamp_attribute_names.map do |attribute_name|
          send(attribute_name)
        end.compact

        return nil unless timestamps.present?
        timestamps.map(&:to_time).max
      end
    end

    module ClassMethods
      def self.extended(_base)
        # rubocop:disable all
        warn ([
          "[DEPRECATION]",
          "`ActiveRecordTweaks::Integration::ClassMethods` is deprecated without replacement.",
          "Please read README in project for details."
        ].join(" "))
        # rubocop:enable all
      end

      # Returns a cache key for the ActiveRecord class based
      # based on count and maximum value of update timestamp columns
      # (e.g. Cookie based caching with expiration)
      #
      # @example when record class is empty and has updated timestamp columns or not
      #   Product.cache_key # => "products/all/0"
      # @example when record class is not empty but has no updated timestamp columns
      #   Product.cache_key # => "products/all/1"
      # @example when record class is not empty and has updated timestamp columns
      #   Person.cache_key # => "people/all/1-20071224150000"
      #
      # @param [Array<String, Symbol>] args The column name with timestamp to check
      def cache_key(*args)
        timestamp_columns = args.empty? ? [:updated_at] : args

        if (timestamp = max_updated_column_timestamp_for_cache_key(timestamp_columns))
          timestamp = timestamp.utc.to_s(cache_timestamp_format)
          "#{model_name.cache_key}/all/#{count}-#{timestamp}"
        else
          cache_key_without_timestamp
        end
      end

      # Returns a cache key for the ActiveRecord class based
      # based on count only
      #
      #   Product.cache_key # => "products/all/0" (empty, has updated timestamp columns or not)
      #   Product.cache_key # => "products/all/1" (not empty but has no updated timestamp columns)
      #   Person.cache_key  # => "people/all/1" (not empty and has updated timestamp columns)
      #
      # @param [Array<String, Symbol>] args The column name with timestamp to check
      def cache_key_without_timestamp
        "#{model_name.cache_key}/all/#{count}"
      end

      private

      def max_updated_column_timestamp_for_cache_key(timestamp_columns)
        available_timestamp_columns = timestamp_columns.select { |c| column_names.include?(c.to_s) }
        timestamps = available_timestamp_columns.map { |column| maximum(column) }.compact

        return nil unless timestamps.present?
        timestamps.map(&:to_time).max
      end
    end
  end
end
