class Coffee < ActiveRecord::Base

  include Storext.model(data: {})

end
