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
