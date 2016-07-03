# Storext

[![Build Status](https://travis-ci.org/G5/storext.svg?branch=master)](https://travis-ci.org/G5/storext)

`ActiveRecord::Store` allows you to put data, like a hash, in a single column. The problem is that when you retrieve these values, they are strings. Storext aims to solve that. This is a layer on top of `ActiveRecord::Store` that uses Virtus to typecast the values and add other options like:

* default values
* type (`String`, `Integer`)

Currently this gem uses [virtus](see https://github.com/solnic/virtus) so you can pass options that is accepted by [Virtus::Extensions#attribute](https://github.com/solnic/virtus#using-virtus-with-classes)

## Dependencies

  * Rails 4.x, 5.x
  * Virtus

## Installation

Just add `gem 'storext'` in your Gemfile and `bundle install`.

## Usage

First, make sure you can use `store_accessor` as described in the [ActiveRecord::Store][active_record_store] docs. This ensures that you have everything required to get this working correctly. [Here](https://mikecoutermarsh.com/using-hstore-with-rails-4/) is a good tutorial.

Define the attributes:

```ruby
class Book < ActiveRecord::Base

  include Storext.model

  # You can define attributes on the :data hstore column like this:
  store_attributes :data do
    author String
    title String, default: "Great Voyage"
    available Boolean, default: true
    copies Integer, default: 0
  end

  # Or you can define attributes like this:
  store_attribute :data, :hardcover, Boolean
  store_attribute :data, :alt_name

end
```

You can also set defaults (useful when you want to default a serialized column to be an empty hash (`{}`)):

```ruby
class Book < ActiveRecord::Base
  include Storext.model(data: {})
end
```

You can get a hash that lists the defined storext attributes by doing

```ruby
Book.storext_definitions
# => { author: { column: :data, type: 'String' }, ..., }
```

Not using `hstore`? You can still have serialized columns using `ActiveRecord::Store`.

```ruby
class User < ActiveRecord::Base
  include Storext.model
  store :settings, coder: JSON

  store_attributes :settings do
    number_of_strikes Integer, default: 0
  end
end
```

Check `spec/storext_spec.rb` for more details.

## How to run the test suite

1. Copy and edit `spec/dummy/config/database.yml.sample` to `spec/dummy/config/database.yml` to fit your own PostgreSQL databases
2. From `spec/dummy`, `rake db:migrate db:test:prepare`
2. From the root dir of the gem, `rspec spec`

## License

Copyright (c) 2015 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  [active_record_store]: http://api.rubyonrails.org/classes/ActiveRecord/Store.html
