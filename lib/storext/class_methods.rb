module Storext
  module ClassMethods

    def storext_define_writer(column, attr)
      define_method "#{attr}=" do |value|
        storext_cast_proxy(attr).send("_casted_#{attr}=", value)
        send("#{column}=", send(column) || {})

        attr_value = storext_cast_proxy(attr).send("_casted_#{attr}")
        write_store_attribute column, attr, value
        send(column)[attr.to_s] = value
      end
    end

    def storext_define_reader(column, attr)
      define_method attr do
        if send(column) && send(column).has_key?(attr.to_s)
          store_val = read_store_attribute(column, attr)
          storext_cast_proxy(attr).send("_casted_#{attr}=", store_val)
        end
        storext_cast_proxy(attr).send("_casted_#{attr}")
      end
    end

    def store_attribute(column, attr, type=nil, opts={})
      track_store_attribute(column, attr, type, opts)

      storext_check_attr_validity(attr, type, opts)

      storext_define_accessor(column, attr)

      store_accessor column, *storext_attrs_for(column)
    end

    def storext_define_accessor(column, attr)
      storext_define_writer(column, attr)
      storext_define_reader(column, attr)
    end

    def store_attributes(column, &block)
      AttributeProxy.new(self, column, &block).define_store_attribute
    end

    private

    def storext_attrs_for(column)
      attrs = []
      store_attribute_defs.each do |key, definition|
        attrs << key if definition[:column] == column
      end
      attrs
    end

    def track_store_attribute(column, attr, type, opts)
      self.store_attribute_defs = self.store_attribute_defs.dup

      store_attribute_defs[attr] = {
        column: column,
        type: type,
        opts: opts,
      }
    end

    def storext_check_attr_validity(attr, type, opts)
      storext_cast_proxy_class = Class.new { include Virtus.model }
      storext_cast_proxy_class.attribute "_casted_#{attr}", type, opts
      unless storext_cast_proxy_class.instance_methods.include? :"_casted_#{attr}"
        raise ArgumentError, "problem defining `#{attr}`. `#{type}` may not be a valid type."
      end
    end

  end
end
