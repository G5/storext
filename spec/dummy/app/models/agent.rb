class Agent < ActiveRecord::Base

  include Storext.model

  # You can define attributes on the :data hstore column like this:
  store_attributes :data do
    first_name String
    last_name String
  end

end
