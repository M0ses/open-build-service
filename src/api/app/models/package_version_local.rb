# Model to track the local version history of a package
class PackageVersionLocal < PackageVersion
  #### Includes and extends

  #### Constants

  #### Self config

  #### Attributes

  #### Associations macros (Belongs to, Has one, Has many)

  #### Callbacks macros: before_save, after_save, etc.

  #### Scopes (first the default_scope macro if is used)

  #### Validations macros

  #### Class methods using self. (public and then private)

  #### To define class methods as private use private_class_method
  #### private

  #### Instance methods (public and then protected/private)

  #### Alias of methods
end

# == Schema Information
#
# Table name: package_versions
#
#  id         :bigint           not null, primary key
#  type       :string(255)      not null
#  version    :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  package_id :integer          not null, indexed
#
# Indexes
#
#  index_package_versions_on_package_id  (package_id)
#
# Foreign Keys
#
#  fk_rails_...  (package_id => packages.id)
#
