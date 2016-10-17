require "active_record_tweaks/version"
require "active_record_tweaks/integration"

module ActiveRecordTweaks
  def self.included(base)
    # rubocop:disable all
    warn "[DEPRECATION] including `ActiveRecordTweaks` is deprecated. Please see README for recommanded usage."
    # rubocop:enable all

    base.class_eval do
      include Integration
    end
  end
end
