# Active Record Tweaks

Active Record is great, but could be better. Here are some tweaks for it.


## Status

[![Build Status](http://img.shields.io/travis/PikachuEXE/active_record_tweaks.svg?style=flat-square)](https://travis-ci.org/PikachuEXE/active_record_tweaks)
[![Gem Version](http://img.shields.io/gem/v/active_record_tweaks.svg?style=flat-square)](http://badge.fury.io/rb/active_record_tweaks)
[![Dependency Status](http://img.shields.io/gemnasium/PikachuEXE/active_record_tweaks.svg?style=flat-square)](https://gemnasium.com/PikachuEXE/active_record_tweaks)
[![Coverage Status](http://img.shields.io/coveralls/PikachuEXE/active_record_tweaks.svg?style=flat-square)](https://coveralls.io/r/PikachuEXE/active_record_tweaks)
[![Code Climate](http://img.shields.io/codeclimate/github/PikachuEXE/active_record_tweaks.svg?style=flat-square)](https://codeclimate.com/github/PikachuEXE/active_record_tweaks)


## Installation

```ruby
gem 'active_record_tweaks'
```


## Usage

Either include it in specific record or just `ActiveRecord::Base`
```ruby
class SomeRecord
  include ActiveRecordTweaks::Integration::InstanceMethods
  # This module is also DEPRECATED
  # See below for details
  extend  ActiveRecordTweaks::Integration::ClassMethods

  # DEPRECATED
  include ActiveRecordTweaks
end 

# or

# In a initialzer
# DEPRECATED
ActiveRecord::Base.send(:include, ActiveRecordTweaks)
```


### `#cache_key_without_timestamp`
Nothing special, just like `record.cache_key`  
But it has no timestamp so you can use it for scoped cache key  
e.g. When caching with Cookie, which you want to control the expiry time independent of record update time  
Usage:
```ruby
  # Just like using #cache_key
  record.cache_key_without_timestamp
```


### `#cache_key_from_attributes`
Nothing special, just like `record.cache_key` in rails 4.1  
But it does not check against columns  
e.g. When you have some virtual timestamp attribute method (cached or not)  
Just make sure you throw some name to it or it will raise error  
Alias: `#cache_key_from_attribute`  
Usage:
```ruby
  # Just like using #cache_key
  record.cache_key_from_attributes(:happy_at, :children_max_updated_at)
```


### `.cache_key`

**DEPRECATED**  
This method does NOT consider the query like filters and and sort orders.  
Thus deprecated without replacement.  
Rails 5 already have `#cache_key` in relation class: https://github.com/rails/rails/pull/20884  
There is also a gem for older rails: https://github.com/customink/activerecord-collection_cache_key  

There is no class level cache key for ActiveRecord at the moment (4.0.1)  
Passing an array to `cache_digest` could lead to performance issue and the key can become too long when collection is big  
([rails#12726](https://github.com/rails/rails/pull/12726))  
This is used for getting a cache key for a ActiveRecord class for all record (I don't know how to write one for `Relation`, could be similar)  
You can use it for class level caching (like displaying all Categories or a random list of 5 users  
And the cache would only expire when there is any record created, updated, or deleted (since `count` and maximum of `updated_at` are used)  
```ruby
Person.count # => 1000
Person.maximum(:updated_at) # => 20131106012125528738000
Person.cache_key # => "people/all/1000-20131106012125528738000"

# When record has multiple updated columns
Person.maximum(:updated_at) # => 20131106012125528738000
Person.maximum(:updated_on) # => 20141106012125528738000
Person.cache_key(:update_at, :updated_on)     # => "people/all/1000-20141106012125528738000" (not empty but has mutiple updated timestamp columns)

# Just get cache key without timestamp
Person.maximum(:updated_on) # => some timestamp
Person.cache_key(nil)     # => "people/all/1000"

# Other examples
Product.cache_key     # => "products/all/0" (empty, has updated timestamp columns or not)
Product.cache_key     # => "products/all/1" (not empty but has no updated timestamp columns)
```
Usage:
```ruby
RecordClass.cache_key
```
You can also use it with multiple records (Rails 4 Record might have `updated_at` and `updated_on`)
```ruby
RecordClass.cache_key(:updated_at, :updated_on)
```


### `.cache_key_without_timestamp`

**DEPRECATED**  
Same as `.cache_key`  

Just like `.cache_key(nil)`  
But much clearer
```ruby
Person.count # => 1000
Person.maximum(:updated_at) # => 20131106012125528738000
Person.cache_key_without_timestamp # => "people/all/1000"

# Other examples
Product.cache_key_without_timestamp     # => "products/all/0" (empty, has updated timestamp columns or not)
Product.cache_key_without_timestamp     # => "products/all/1" (not empty but has no updated timestamp columns)
```
Usage:
```ruby
RecordClass.cache_key_without_timestamp
```
