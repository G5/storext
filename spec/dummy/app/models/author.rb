class Author < ActiveRecord::Base

  include Storext
  store_attributes :data do
    name String
    title String, default: "Dr."
  end

end
