# TBA

- Fix issue where columm default was being overridden

# 0.2.0

- Ensure that behaviour remains the same as `ActiveRecord::Base` when no attributes are defined
- Allow options to be passed in with `include Storext.model`

# 0.1.4

- Fix overwriting of attributes in classes that share the same ancestor

# 0.1.3

- Fix discrepancy when setting attributes when creating and updating

# 0.1.2

- Fix: errors that show up when `include Storext` is in parent

# 0.1.1

- Fix: defaults are now set when an object is created

# 0.1.0

- Allow defining of type `Boolean` instead of `Axiom::Types::Boolean`

# 0.0.2

- Fix issue when defining `name` store attribute
- Refactor Storext module into mulitple classes:
  - Storext::AttributeProxy
  - Storext::ClassMethods

# 0.0.1

- Initial release
