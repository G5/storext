require "active_support/concern"
require "virtus"

module Storext

  extend ActiveSupport::Concern

  included do
    class_attribute :store_attribute_defs
    self.store_attribute_defs = {}
  end

  private

  def storext_proxy
    return @storext_proxy if @storext_proxy
    @storext_proxy ||= self.class.storext_proxy_class.new
  end

  module ClassMethods
    def store_attribute(column, attr, type=nil, opts={})
      store_attribute_defs[column] ||= []
      store_attribute_defs[column] << attr

      storext_proxy_class.attribute "_casted_#{attr}", type, opts

      define_method "#{attr}=" do |value|
        storext_proxy.send("_casted_#{attr}=", value)
        write_store_attribute column, attr, storext_proxy.send("_casted_#{attr}")
      end

      define_method attr do
        if store_val = read_store_attribute(column, attr)
          storext_proxy.send("_casted_#{attr}=", store_val)
        end
        storext_proxy.send("_casted_#{attr}")
      end

      store_accessor column, *store_attribute_defs[column]
    end

    def store_attributes(column, &block)
      storext_proxy_class.define_store_attributes self, column, &block
    end

    def storext_proxy_class
      @storext_proxy_class ||= Class.new do
        include Virtus.model

        def self.define_store_attributes(source_class, column, &block)
          @source_class = source_class
          @column = column
          instance_eval &block
        end

        def self.method_missing(method_name, *args, &block)
          @source_class.store_attribute @column, method_name, *args
        end
      end
    end

  end

end
