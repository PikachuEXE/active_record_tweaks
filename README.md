Active Record Tweaks
===========

Active Record is great, but could be better. Here are some tweaks for it.

### Support
===========
Tested against:
- Active Record of version `3.2` and `4.0`
- Ruby `1.9.3`, `2.0.0` (except Rails 4 with `1.9.2`)

[![Build Status](https://travis-ci.org/PikachuEXE/active_record_tweaks.png?branch=master)](https://travis-ci.org/PikachuEXE/active_record_tweaks)
[![Gem Version](https://badge.fury.io/rb/active_record_tweaks.png)](http://badge.fury.io/rb/active_record_tweaks)
[![Dependency Status](https://gemnasium.com/PikachuEXE/active_record_tweaks.png)](https://gemnasium.com/PikachuEXE/active_record_tweaks)
[![Coverage Status](https://coveralls.io/repos/PikachuEXE/active_record_tweaks/badge.png)](https://coveralls.io/r/PikachuEXE/active_record_tweaks)
[![Code Climate](https://codeclimate.com/github/PikachuEXE/active_record_tweaks.png)](https://codeclimate.com/github/PikachuEXE/active_record_tweaks)

Install
=======

```ruby
gem 'active_record_tweaks'
```

Usage
=====

Either include it in specific record or just `ActiveRecord::Base`
```ruby
class SomeRecord
  include ActiveRecordTweaks
end 

# or

# In a initialzer
ActiveRecord::Base.send(:include, ActiveRecordTweaks)
```


### `#cache_key_without_timestamp`
Nothing special, just like `record.cache_key`  
But it has no timestamp so you can use it for scoped cache key  
(e.g. When caching with Cookie, which you want to control the expiry time independent of record update time)  
Usage:
```ruby
  # Just like using #cache_key
  record.cache_key_without_timestamp
```
