module Storext
  module InstanceMethods

    def destroy_key(column, attr)
      new_value = send(column)
      if Rails.gem_version < Gem::Version.new("4.2.0")
        new_value = send(column).dup
      end
      new_value.delete(attr.to_s)
      send("#{column}=", new_value)
    end

    def destroy_keys(column, *attrs)
      new_value = send(column)
      if Rails.gem_version < Gem::Version.new("4.2.0")
        new_value = send(column).dup
      end
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
      storext_cast_proxy(attr).send(attr)
    end

    def storext_cast_proxy(attr)
      if @storext_cast_proxies && @storext_cast_proxies[attr]
        return @storext_cast_proxies[attr]
      else
        @storext_cast_proxies ||= {}

        definition = self.class.storext_definitions[attr]
        klass = storext_create_proxy_class(attr, definition)

        @storext_cast_proxies[attr] = klass.new(source: self)
      end
    end

    def storext_create_proxy_class(attr, definition)
      klass = Class.new do
        include Virtus.model

        attribute :source
      end

      klass.attribute(
        attr,
        definition[:type],
        definition[:opts].merge(default: :compute_default),
      )

      klass.send :define_method, :compute_default do
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

      klass
    end

  end
end
