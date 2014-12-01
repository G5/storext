class PocketBook < Book

  store_attributes :data do
    soft Boolean, default: true
    title Integer, default: 1
  end

end
