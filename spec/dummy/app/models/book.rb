class Book < ActiveRecord::Base

  include Storext.model
  store_attributes :data do
    author String
    title String, default: "Great Voyage"
    available Boolean, default: true
    copies Integer, default: 0
    preface String, default: :default_preface
    isbn(String, {
      default: lambda do |book, attribute|
        book.send(:"compute_#{attribute.name}")
      end
    })
  end
  store_attribute :data, :hardcover, Boolean
  store_attribute :data, :alt_name
  store_attribute :another_hstore, :diff_hstore_attr, String, default: 'some value'

  def default_preface
    "Write something"
  end

  def compute_isbn
    "Computed ISBN"
  end

end
