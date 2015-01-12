class Phone < ActiveRecord::Base

  include Storext
  store_attributes :data do
    number String, default: "222"
  end

end
