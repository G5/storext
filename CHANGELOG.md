# Unreleased
## Changed

- Store the coerced values in the database. This may introduce a breaking change if one by-passes the reader method provided by `ActiveRecord::Store`. https://github.com/G5/storext/pull/17

# 1.1.2

- Refactor ClassMethods#store_attribute to call store_accessor only with the key to be added, instead of including existing keys.

# 1.1.1

- Attempt to address memory leak issues by conservatively creating proxy classes and instances that convert values

# 1.1.0

- Add `#storext_has_key?` to check if a column has a key, but do so with indifferent access. When using PostgreSQL's hstore, the column's keys are strings.

# 1.0.3

- Fix how defaults are computed [#7](https://github.com/G5/storext/issues/7)

# 1.0.2

- Apply fix in `1.0.1` to `destroy_keys`

# 1.0.1

- Fix bug when deleting keys

# 1.0.0

- Expose class method `storext_definitions` to list defined Storext attributes

# 0.2.1

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
