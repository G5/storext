require "active_support/concern"
require "virtus"
require "storext/attribute_proxy"
require "storext/class_methods"
require "storext/instance_methods"

module Storext

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
