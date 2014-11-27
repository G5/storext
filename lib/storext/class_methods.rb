module Storext
  module ClassMethods

    def storext_define_writer(column, attr)
      define_method "#{attr}=" do |value|
        storext_cast_proxy.send("_casted_#{attr}=", value)
        write_store_attribute(column,
                              attr,
                              storext_cast_proxy.send("_casted_#{attr}"))
      end
    end

    def storext_define_reader(column, attr)
      define_method attr do
        if store_val = read_store_attribute(column, attr)
          storext_cast_proxy.send("_casted_#{attr}=", store_val)
        end
        storext_cast_proxy.send("_casted_#{attr}")
      end
    end

    def store_attribute(column, attr, type=nil, opts={})
      track_store_attribute(column, attr)

      storext_cast_proxy_class.attribute "_casted_#{attr}", type, opts

      storext_define_writer(column, attr)
      storext_define_reader(column, attr)

      store_accessor column, *store_attribute_defs[column]
    end

    def store_attributes(column, &block)
      AttributeProxy.new(self, column, &block).define_store_attribute
    end

    def track_store_attribute(column, attr)
      store_attribute_defs[column] ||= []
      store_attribute_defs[column] << attr
    end

    def storext_cast_proxy_class
      @storext_cast_proxy_class ||= Class.new do
        include Virtus.model
      end
    end

  end
end
