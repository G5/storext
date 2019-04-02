module Storext
  module ClassMethods

    def storext_define_writer(column, attr)
      define_method "#{attr}=" do |value|
        coerced_value = storext_cast_proxy.send("#{attr}=", value)

        send("#{column}=", send(column) || {})
        write_store_attribute column, attr, coerced_value
        send(column)[attr.to_s] = coerced_value
      end
    end

    def storext_define_reader(column, attr)
      define_method attr do
        if send(column) && send(column).has_key?(attr.to_s)
          store_val = read_store_attribute(column, attr)
          storext_cast_proxy.send("#{attr}=", store_val)
        end
        storext_cast_proxy.send("#{attr}")
      end
    end

    def storext_define_predicater(column, attr)
      define_method "#{attr}?" do
        return false unless send(column) && send(column).has_key?(attr.to_s)
        if read_store_attribute(column, attr).is_a? String
          !read_store_attribute(column, attr).blank?
        else
          !!read_store_attribute(column, attr)
        end
      end
    end

    def store_attribute(column, attr, type=nil, opts={})
      track_store_attribute(column, attr, type, opts)
      storext_check_attr_validity(attr, type, opts)
      storext_define_accessor(column, attr)
      store_accessor(column, attr)
    end

    def storext_define_accessor(column, attr)
      storext_define_writer(column, attr)
      storext_define_reader(column, attr)
      storext_define_predicater(column, attr)
      storext_define_proxy_attribute(attr)
    end

    def store_attributes(column, &block)
      AttributeProxy.new(self, column, &block).define_store_attribute
    end

    def storext_define_proxy_attribute(attr)
      compute_default_method_name = :"compute_default_#{attr}"
      definition = self.storext_definitions[attr]
      proxy_class = self.storext_proxy_class
      proxy_class.attribute(
        attr,
        definition[:type],
        definition[:opts].merge(default: compute_default_method_name),
      )

      proxy_class.send :define_method, compute_default_method_name do
        default_value = definition[:opts][:default]
        if default_value.is_a?(Symbol)
          source.send(default_value)
        elsif default_value.respond_to?(:call)
          attribute = self.class.attribute_set[attr]
          default_value.call(source, attribute)
        else
          default_value
        end
      end
    end

    def storext_proxy_class
      Storext.proxy_classes[self] ||= Class.new(*Storext.proxy_classes[self.superclass]) do
        include Virtus.model
        attribute :source
      end
    end

    def _load(yml)
      YAML.load(yml)
    end

    private

    def storext_attrs_for(column)
      attrs = []
      storext_definitions.each do |attr, definition|
        attrs << attr if definition[:column] == column
      end
      attrs
    end

    def track_store_attribute(column, attr, type, opts)
      self.storext_definitions = self.storext_definitions.dup

      storext_definitions[attr] = {
        column: column,
        type: type,
        opts: opts,
      }
    end

    def storext_check_attr_validity(attr, type, opts)
      storext_cast_proxy_class = Class.new { include Virtus.model }
      storext_cast_proxy_class.attribute attr, type, opts
      unless storext_cast_proxy_class.instance_methods.include? attr
        raise ArgumentError, "problem defining `#{attr}`. `#{type}` may not be a valid type."
      end
    end

  end
end
