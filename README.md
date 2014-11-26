= Storex

ActiveRecord::Base.store_accessor gives you accessors specific to
PostgreSQL's `hstore` for storing hashes into a single column
(See [ActiveRecord::Store](http://api.rubyonrails.org/classes/ActiveRecord/Store.html)).

Storex builds on top of that so that you can define more options such as:
* default values
* type (`String`, `Integer`)

Currently this gem uses [virtus](see https://github.com/solnic/virtus)
so you can pass options that is accepted by [Virtus::Extensions#attribute](https://github.com/solnic/virtus#using-virtus-with-classes)

## Dependencies
  * PostgreSQL
  * ruby 2.1 (but may work on earlier versions)
  * rails 4.0

## Installation

Just add `gem 'storex'` in your Gemfile and `bundle install`.

## Usage

```ruby
# create a migration that enables hstore e.g.
# db/migrate/timestamp_install_hstore.rb
class InstallHstore < ActiveRecord::Migration
  def change
    enable_extension :hstore
  end
end

# then create another migration that adds an hstore column e.g.
# db/migrate/timestamp_create_books.rb
class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.hstore :data
    end
  end
end

# run `rake db:migrate` and then in your model e.g.
# app/models/book.rb
class Book < ActiveRecord::Base

  include Storext
  store_attributes :data do
    author String
    title String, default: "Great Voyage"
    available Axiom::Types::Boolean, default: true
    copies Integer, default: 0
  end
  store_attribute :data, :hardcover, Axiom::Types::Boolean
  store_attribute :data, :alt_name

end
```
## How to run the test suite

```
rspec spec
```

## License

Copyright (c) 2014 G5

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
