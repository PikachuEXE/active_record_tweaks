require "active_record_tweaks/version"
require "active_record_tweaks/integration"

module ActiveRecordTweaks
  def self.included(base)
    base.class_eval do
      include Integration
    end
  end
end
