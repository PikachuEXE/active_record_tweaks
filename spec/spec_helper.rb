# frozen_string_literal: true

if ENV["COVERALLS"]
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = "coverage/lcov.info"
  end

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]
  )

  SimpleCov.start do
    add_filter "spec/"
  end
end

require "active_record"
require "active_record_tweaks"

require "timecop"

require "database_cleaner"
require "logger"

require "rspec"
require "rspec/its"

# ActiveRecord::Base.logger = Logger.new(STDOUT) # for easier debugging

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end
end

ActiveRecord::Base.send(:include, ActiveRecordTweaks)

# connect
ActiveRecord::Base.establish_connection(
  adapter:  "sqlite3",
  database: ":memory:",
)

# create tables
ActiveRecord::Schema.define(version: 1) do
  create_table :stones

  create_table :animals do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :parents do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :children do |t|
    t.integer :parent_id

    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :people do |t|
    t.datetime :created_at
    t.datetime :updated_at
    t.datetime :created_on
    t.datetime :updated_on
  end
end

# Setup models

# Default cache timestamp format are different for Rails 3 and 4 are different,
# So set it explictly here
class Stone < ActiveRecord::Base
end

class Animal < ActiveRecord::Base
  self.cache_timestamp_format = :number
end

class Parent < ActiveRecord::Base
  self.cache_timestamp_format = :nsec

  has_many :children, inverse_of: :parent
end

class Child < ActiveRecord::Base
  self.cache_timestamp_format = :nsec

  belongs_to :parent, inverse_of: :children, touch: true
end

class Person < ActiveRecord::Base
  self.cache_timestamp_format = :nsec
end
