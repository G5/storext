module Storext
  module InstanceMethods

    def destroy_key(column, attr)
      new_value = send(column)
      new_value.delete(attr.to_s)
      send("#{column}=", new_value)
    end

    def destroy_keys(column, *attrs)
      new_value = send(column)
      attrs.each { |a| new_value.delete(a.to_s) }
      send("#{column}=", new_value)
    end

    private

    def set_storext_defaults
      self.class.storext_options.each do |column, default|
        self.send("#{column}=", default) if self.send(column).nil?
      end

      storext_definitions.each do |attr, definition|
        set_storext_default_for(definition[:column], attr)
      end
    end

    def set_storext_default_for(column, attr)
      if self.send(column).nil? || !self.send(column).has_key?(attr.to_s)
        write_store_attribute(column, attr, default_store_value(attr))
      end
    end

    def default_store_value(attr)
      storext_cast_proxy(attr).send("casted_attr")
    end

    def storext_cast_proxy(attr)
      if @storext_cast_proxies && @storext_cast_proxies[attr]
        return @storext_cast_proxies[attr]
      else
        @storext_cast_proxies ||= {}

        klass = Class.new do
          include Virtus.model
        end

        klass.attribute(
          "casted_attr",
          self.class.storext_definitions[attr][:type],
          self.class.storext_definitions[attr][:opts],
        )

        @storext_cast_proxies[attr] = klass.new
      end
    end

  end
end
