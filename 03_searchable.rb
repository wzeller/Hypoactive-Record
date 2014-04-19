require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
  	values = params.values
  	params.keys 
    where_line = params.keys.map{|key| "#{key} = ?"}.join(" AND ")
    query = "SELECT * FROM #{self.table_name} WHERE #{where_line}"
    self.parse_all(DBConnection.execute(query, values))
  end
end

class SQLObject
	extend Searchable
end
