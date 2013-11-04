if ENV["TRAVIS"]
  require 'coveralls'
  Coveralls.wear!('rails')
end

require 'active_record'
require 'active_record_tweaks'

require 'database_cleaner'
require 'logger'

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

  create_table :parents do |t|
    t.datetime :created_at
    t.datetime :updated_at
  end

  create_table :chirdren do |t|
    t.integer :parent_id

    t.datetime :created_at
    t.datetime :updated_at
  end
end

# setup models

class Stone < ActiveRecord::Base
end

class Parent < ActiveRecord::Base
  has_many :children, inverse_of: :parent
end

class Child < ActiveRecord::Base
  belongs_to :parent, inverse_of: :children, touch: true
end

RSpec.configure do |config|
end
