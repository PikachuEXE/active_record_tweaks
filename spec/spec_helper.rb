if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!('rails')
end

require 'active_record'
require 'active_record_tweaks'

require 'timecop'

require 'database_cleaner'
require 'logger'

require 'rspec'
require 'rspec/its'

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
  :adapter => "sqlite3",
  :database => ":memory:"
)

# create tables
ActiveRecord::Schema.define(:version => 1) do
  create_table :stones do |t|
  end

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


RSpec.configure do |config|
end
