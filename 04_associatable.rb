require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name 
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {foreign_key: (name.to_s.underscore + "_id").to_sym,
       primary_key: :id,
       class_name: name.to_s.camelize}
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key] 
    @primary_key = options[:primary_key]
    @class_name = options[:class_name] 
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {foreign_key: (self_class_name.to_s.underscore + "_id").to_sym,
        primary_key:  :id,
        class_name:  name.to_s.singularize.camelize}
    options = defaults.merge(options)
    @foreign_key = options[:foreign_key] 
    @primary_key = options[:primary_key]
    @class_name = options[:class_name] 
  end
end

module Associatable

  # Phase IVb
  def belongs_to(name, options = {})
    #makes object with all information to recreate object to which self
    #belongs 
    options = BelongsToOptions.new(name, options)
    self.assoc_options[name] = options 
    define_method(name) do 
      foreign_key = self.send(options.foreign_key)
      primary_key = options.primary_key
      target_class = options.model_class 
      options = target_class.where(primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    # makes object with all information to recreate objects self has 
    options = HasManyOptions.new(name, self.to_s, options)
    
    define_method(name) do 
      target_class = options.model_class
      foreign_key = options.foreign_key
      primary_key = self.send(options.primary_key)
      target_class.where(foreign_key => primary_key)
    end
  end

  def assoc_options
  # Wait to implement this in Phase V. Modify `belongs_to`, too.
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  extend Associatable
end
