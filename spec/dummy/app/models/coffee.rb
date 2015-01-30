class Coffee < ActiveRecord::Base

  include Storext.model(data: {})

  store_attributes :data do
    name String
  end

end
