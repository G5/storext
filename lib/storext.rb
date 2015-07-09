require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"
require "virtus"
require "storext/attribute_proxy"
require "storext/class_methods"
require "storext/instance_methods"

module Storext

  mattr_accessor :proxy_classes
  self.proxy_classes ||= {}

  def self.model(options={})
    mod = Module.new do
      mattr_accessor :storext_options

      def self.included(base)
        base.class_attribute :storext_options
        base.storext_options = self.storext_options
        base.send :include, Storext
      end
    end

    mod.storext_options = options

    mod
  end

  extend ActiveSupport::Concern

  included do
    include InstanceMethods

    unless respond_to?(:storext_options)
      warn "Storext must be included via `include Storext.model` instead. Not specifying `.model` has been deprecated. (included from #{self.to_s})"
      class_attribute :storext_options
      self.storext_options = {}
    end

    class_attribute :storext_definitions
    self.storext_definitions = {}

    unless defined?(self::Boolean)
      self::Boolean = ::Axiom::Types::Boolean
    end

    after_initialize :set_storext_defaults
  end

end
