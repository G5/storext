class SmartPhone < Phone

  store_attributes :data do
    number String, default: "111"
  end

end
