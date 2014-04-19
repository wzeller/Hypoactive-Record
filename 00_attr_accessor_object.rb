class AttrAccessorObject
  def self.my_attr_accessor(*var_names)
    var_names.each do |var|
    	define_method(var) do 
    		self.instance_variable_get('@'+var.to_s)
    	end
    	define_method("#{var}=") do |val|
    		self.instance_variable_set('@'+var.to_s, val)
    	end
    end
  end
end

class TestClass < AttrAccessorObject
require 'active_support/inflector'
	my_attr_accessor :name

	def attributes
    @attributes ||= @attributes = Hash.new(0)
  end

  def attributes=(var)
  	@attributes.merge!({var.to_sym => 1})
  end
	
	def initialize (names)
		@name = nil
		@attributes = nil
	end
end

test = TestClass.new("FirstName")

p test.class.superclass