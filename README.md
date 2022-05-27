# Storext

[![Build Status](https://travis-ci.org/G5/storext.svg?branch=master)](https://travis-ci.org/G5/storext)

`ActiveRecord::Store` allows you to put data, like a hash, in a single column. The problem is that when you retrieve these values, they are strings. Storext aims to solve that. This is a layer on top of `ActiveRecord::Store` that uses Virtus to typecast the values and add other options like:

* default values
* type (`String`, `Integer`)

Currently this gem uses [virtus](https://github.com/solnic/virtus) so you can pass options that are accepted by [Virtus::Extensions#attribute](https://github.com/solnic/virtus#using-virtus-with-classes)

## Dependencies

  * Rails 4.x, 5.x, 6.x, 7.x
  * Virtus

## Installation

Add `gem 'storext'` to your Gemfile and `bundle install`.

## Usage

### With jsonb (postgresql 9.4+)

Add a jsonb column. e.g.:

```ruby
add_column :books, :data, :jsonb, null: false, default: {}
add_index :books, :data, using: :gin
```

["Using PostgreSQL and JSONB with Ruby on Rails"](http://nandovieira.com/using-postgresql-and-jsonb-with-ruby-on-rails) is a good tutorial for jsonb and Rails.

### With hstore (postgresql 9.2+)

```ruby
enable_extension 'hstore'
add_column :books, :data, :hstore, null: false, default: {}
add_index :books, :data, using: :gin
```

["Using HStore with Rails 4"](https://mikecoutermarsh.com/using-hstore-with-rails-4/) is a good tutorial for hstore and Rails.


### With Rails standard methods

With Rails and the text format there is no need for postgresql or any nosql db. You can use every db.

```ruby
add_column :books, :data, :text
```

[ActiveRecord::Store](https://api.rubyonrails.org/classes/ActiveRecord/Store.html) is the Documentation for Rails Store.


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

- Copy `spec/dummy/config/database.yml.sample` to `spec/dummy/config/database.yml`
- Setup your PG database, and fill in the correct credentials in `spec/dummy/config/database.yml`. If you're familiar with Docker, you use the `docker-compose up db` to start the db. It will be accessible via your host's `5432` port.
- `bundle exec rake --rakefile spec/dummy/Rakefile db:create db:schema:load`
- `bundle install`
- `appraisal install`
- From the root dir of the gem, `appraisal rspec spec`

## License

Copyright (c) 2019 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

  [active_record_store]: https://api.rubyonrails.org/classes/ActiveRecord/Store.html
