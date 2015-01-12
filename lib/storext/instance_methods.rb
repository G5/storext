module Storext
  module InstanceMethods

    private

    def set_storext_defaults
      store_attribute_defs.each do |attr, definition|
        set_storext_default_for(definition[:column], attr)
      end
    end

    def set_storext_default_for(column, attr)
      if self.send(column).nil? || !self.send(column).has_key?(attr.to_s)
        write_store_attribute(column, attr, default_store_value(attr))
      end
    end

    def default_store_value(attr)
      storext_cast_proxy(attr).send("_casted_#{attr}")
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
          "_casted_#{attr}",
          self.class.store_attribute_defs[attr][:type],
          self.class.store_attribute_defs[attr][:opts],
        )

        @storext_cast_proxies[attr] = klass.new
      end
    end

  end
end
