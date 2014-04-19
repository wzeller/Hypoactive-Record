require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    objects = []
    results.each do |params|
      objects << self.new(params)
    end 
    objects 
  end
end

class SQLObject < MassObject
  require 'active_support/inflector'

  def self.columns

    if @columns 
      return @columns
    end

    @columns = DBConnection.execute2("SELECT * FROM #{self.table_name} LIMIT 1")
      .first.map{|name| name.to_sym}

    @columns.each do |var|
      define_method(var) do
        attributes[var]
      end
      define_method("#{var}=") do |val|
        attributes[var] = val 
      end
    end 
  end

  def self.table_name=(table_name)
    @table_name = table_name 
  end

  def self.table_name
    @table_name ||= @table_name = self.to_s.underscore.pluralize
  end

  def self.all
    self.parse_all(DBConnection.execute("SELECT * FROM #{self.table_name}"))
  end

  def self.find(id)
    self.parse_all(DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = #{id}")).first
  end

  def attributes
    @attributes ||= {}
  end

  def insert
    columns = self.attributes.keys 
    values = self.attributes.values 
    stringy_columns = columns.join(", ")
    question_marks = (["?"]*(columns.length)).join(", ") 
    query = "INSERT INTO #{self.class.table_name} (#{stringy_columns}) VALUES (#{question_marks})"
    DBConnection.execute(query, values)
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    params.each do |name, value| 
      name = name.to_sym
      raise "unknown attribute #{name}" unless self.class.columns.include?(name)
      send("#{name}=", value) 
    end
  end

  def save
    self.id.nil? ? self.insert : self.update 
  end

  def update
    columns = self.attributes.keys 
    values = self.attributes.values 
    set_line = [].tap do |set_line|
      columns.length.times do |num|
        set_line << columns[num].to_s + " = ?"
      end
    end.join(", ")
    update = "UPDATE #{self.class.table_name} SET #{set_line} WHERE id = #{self.id}"
    DBConnection.execute(update, values)
  end

  def attribute_values
    attributes.values 
  end
end




