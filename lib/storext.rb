require "active_support/concern"
require "virtus"
require "storext/attribute_proxy"
require "storext/class_methods"

module Storext

  extend ActiveSupport::Concern

  included do
    class_attribute :store_attribute_defs
    self.store_attribute_defs = {}
  end

  private

  def storext_cast_proxy
    return @storext_cast_proxy if @storext_cast_proxy
    @storext_cast_proxy ||= self.class.storext_cast_proxy_class.new
  end

end
