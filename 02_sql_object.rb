require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject

  #make new objects from an array of key/val pairs (attributes) 
  def self.parse_all(results)
    results.map {|result| self.new(result)}
  end

class SQLObject < MassObject
  require 'active_support/inflector'


  def self.columns
    #get existing columns or generate list of columns/generate new methods
    @columns ||= begin  
      columns = DBConnection.execute2("SELECT * FROM #{self.table_name} LIMIT 1")
        .first.map{|name| name.to_sym}

      #make getter and setter methods for each attr/column
      columns.each do |var|
        define_method(var) do
          attributes[var]
        end
        define_method("#{var}=") do |val|
          attributes[var] = val 
        end
      end 
      #return array of 
      columns.map(&:to_sym)
    end
  end

  #set table name
  def self.table_name=(table_name)
    @table_name = table_name 
  end
  
  #get table table or, if it doesn't exist, set it
  def self.table_name
    @table_name ||= @table_name = self.to_s.underscore.pluralize
  end

  #get everything from database using table_name
  def self.all
    self.parse_all(DBConnection.execute("SELECT * FROM #{self.table_name}"))
  end
  
  #find an instance by id using table_name and id
  def self.find(id)
    self.parse_all(DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = #{id}")).first
  end

  #returns all attributes or an empty hash
  def attributes
    @attributes ||= {}
  end
  
  #add element to database
  def insert
    stringy_columns = self.class.columns.map(&:to_s).join(", ")
    question_marks = (["?"]*(self.class.columns.length)).join(", ") 
    query = "INSERT INTO #{self.class.table_name} (#{stringy_columns}) VALUES (#{question_marks})"
    DBConnection.execute(query, *attribute_values)
    self.id = DBConnection.last_insert_row_id
  end

  #set a bunch of attributes based on params
  def initialize(params = {})
    params.each do |name, value| 
      name = name.to_sym
      raise "unknown attribute #{name}" unless self.class.columns.include?(name)
      #set each attribute
      send("#{name}=", value) 
    end
  end

  #if id is nil, insert self; otherwise, update
  def save
    self.id.nil? ? self.insert : self.update 
  end

  def update
    #go through every column name/attr and generate set line to set each attr
    set_line = self.class.columns.map(|attr| "#{attr} = ?").join(" ,")
    update = "UPDATE #{self.class.table_name} SET #{set_line} WHERE id = #{self.id}"
    DBConnection.execute(update, *attribute_values)
  end

  #use getter method to extract values for each column name
  def attribute_values
    self.class.columns.map {|attr| self.send(attr)}
  end
end




