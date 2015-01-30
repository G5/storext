class Coffee < ActiveRecord::Base

  include Storext.model

  store_attributes :data do
    name String
  end

end
