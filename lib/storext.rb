require "active_support/concern"
require "virtus"
require "storext/attribute_proxy"
require "storext/class_methods"
require "storext/instance_methods"

module Storext

  def self.model(*options)
    mod = Module.new do
      def self.included(base)
        base.send :include, Storext
      end
    end
  end

  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    class_attribute :store_attribute_defs
    self.store_attribute_defs = {}

    unless defined?(self::Boolean)
      self::Boolean = ::Axiom::Types::Boolean
    end

    after_initialize :set_storext_defaults
  end

end
