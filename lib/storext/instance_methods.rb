module Storext
  module InstanceMethods

    def destroy_key(column, attr)
      new_value = send(column)
      if Rails.gem_version < Gem::Version.new("4.2.0")
        new_value = send(column).dup
      end
      new_value.delete(attr.to_s)
      storext_cast_proxy.reset_attribute(attr)

      send("#{column}=", new_value)
    end

    def destroy_keys(column, *attrs)
      new_value = send(column)
      if Rails.gem_version < Gem::Version.new("4.2.0")
        new_value = send(column).dup
      end

      attrs.each do |a|
        new_value.delete(a.to_s)
        storext_cast_proxy.reset_attribute(a)
      end

      send("#{column}=", new_value)
    end

    def storext_has_key?(column, key)
      send(column).with_indifferent_access.has_key?(key)
    end

    def _dump(level)
      self.to_yaml
    end

    private

    def set_storext_defaults
      self.class.storext_options.each do |column, default|
        next unless self.respond_to?(column)
        self.send("#{column}=", default) if self.send(column).nil?
      end

      storext_definitions.each do |attr, definition|
        set_storext_default_for(definition[:column], attr)
      end
    end

    def set_storext_default_for(column, attr)
      return unless self.respond_to?(column)
      if self.send(column).nil? || !self.send(column).has_key?(attr.to_s)
        write_store_attribute(column, attr, default_store_value(attr))
      end
    end

    def default_store_value(attr)
      storext_cast_proxy.send(attr)
    end

    def storext_cast_proxy
      @storext_cast_proxy ||= self.class.storext_proxy_class.new(source: self)
    end

  end
end
