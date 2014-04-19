require_relative '04_associatable'

# It works below, but is not consistent with instructions
# module Associatable
#   # Remember to go back to 04_associatable to write ::assoc_options
#   def has_one_through(name, through_name, source_name)
#  		define_method(name) do
# 			 through_object = self.send(through_name)
# 			 target_object = through_object.send(source_name)
#  		end
#  	end
# end

module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options
  def has_one_through(name, through_name, source_name)
 		define_method(name) do
 			#query for house given cat's owner's id
 			through_options = self.class.assoc_options[through_name]
			source_options = through_options.model_class
			query = "SELECT 
								#{source_name.to_s.pluralize}.* 
								FROM 
								#{source_options.table_name} 
								JOIN 
								#{source_name.to_s.pluralize}
								ON 
								#{source_options.table_name}.#{source_name}_id = #{source_name.to_s.pluralize}.id
								WHERE 
								#{source_options.table_name}.id = ?"
			#get owner_id for cat to match on in query above
			foreign_key = through_options.foreign_key
			owner_id = self.send(foreign_key)
			p results = DBConnection.execute(query, owner_id)
			source_name.to_s.camelize.constantize.parse_all(results).first
 		end
 	end
end