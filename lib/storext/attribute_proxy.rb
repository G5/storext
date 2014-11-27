module Storext
  class AttributeProxy

    def initialize(source_class, column, &block)
      @source_class = source_class
      @column = column
      @block = block
    end

    def define_store_attribute
      instance_eval &@block
    end

    def method_missing(method_name, *args, &block)
      @source_class.store_attribute @column, method_name, *args
    end

  end
end
