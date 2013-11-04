require 'active_support/concern'

require 'active_record_tweaks/version'
require 'active_record_tweaks/integration'

module ActiveRecordTweaks
  extend ActiveSupport::Concern

  included do
    include Integration
  end
end
