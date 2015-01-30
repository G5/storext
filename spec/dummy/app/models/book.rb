class Book < ActiveRecord::Base

  include Storext.model
  store_attributes :data do
    author String
    title String, default: "Great Voyage"
    available Boolean, default: true
    copies Integer, default: 0
  end
  store_attribute :data, :hardcover, Boolean
  store_attribute :data, :alt_name
  store_attribute :another_hstore, :diff_hstore_attr, String, default: 'some value'

end
