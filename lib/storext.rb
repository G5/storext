require "active_support/concern"
require "virtus"
require "storext/attribute_proxy"
require "storext/class_methods"

module Storext

  extend ActiveSupport::Concern

  included do
    class_attribute :store_attribute_defs
    self.store_attribute_defs = {}

    unless defined?(self::Boolean)
      self::Boolean = ::Axiom::Types::Boolean
    end

    after_initialize :set_storext_defaults
  end


  private

  def set_storext_defaults
    store_attribute_defs.each do |store_column, store_keys|
      store_keys.each do |store_key|
        set_storext_default_for(store_column, store_key)
      end
    end
  end

  def set_storext_default_for(column, key)
    if self.send(column).nil? || !self.send(column).has_key?(key.to_s)
      write_store_attribute(column, key, default_store_value(key))
    end
  end

  def default_store_value(key)
    storext_cast_proxy.send("_casted_#{key}")
  end

  def storext_cast_proxy
    if @storext_cast_proxy
      return @storext_cast_proxy
    end
    @storext_cast_proxy ||= self.class.storext_cast_proxy_class.new
  end

end
