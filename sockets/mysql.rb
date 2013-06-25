class QueryBuilder
	def select; end
	def insert; end
	def update; end
end

class MysqlBuilder < QueryBuilder
	def initialize
	end

	class << self
		def select(values={})
			cols = values[:cols]
			table = values[:table]
			where = values[:where]

			query = String.new
			query = "SELECT"

			# Columns (with alias)
			if cols	
				cols.each do |key,value|
					query << " #{value} AS #{key}"
				end
			else
				query << " *"
			end
			
			# From (with possible alias)
			if table
				query << " FROM #{table}"
				# query << " AS #{table_alias}" if table_alias
			else
				raise "No table at select query."
			end
			
			# @leftjoin = {:tablealias => {:name => "tablename", :on => "oncondition"}...}
			if @leftjoin && @leftjoin.length > 0
				@leftjoin.each do |key, value|
					query << " LEFT JOIN #{value[:name]} AS #{key} ON #{value[:on]}"
				end
			end
			# @where = Array
			if where && where.length > 0
				query << " WHERE"
				where.each do |dec|
					query << " #{dec}"
				end
			end

			return query
		end

		def insert(values={})
			# INSERT INTO table (column1, column2) VALUES (v1c1, v1c2), (v2c1, v2c2)

			query = String.new
			query = 'INSERT INTO'

			if @from
				query << " #{@from}"
			else
				raise "No table at insert query."
			end

			puts @cols.inspect
			if @cols && @cols.count > 0
				query << ' ('
				@cols.each do |key,col|
					query << "#{col},"
				end

				query.chop! << ')'
			end

			query << ' VALUES'

			if @values
				@values.each do |row|
					query << ' ('
					row.each do |val|
						query << "'#{val}'" << ','
					end
					query.chop!
					query << '),'
				end
				query.chop!
			else
				raise 'No values to insert.'
			end

			return query
		end

		def update(values={})
			# UPDATE example SET age='22' WHERE age='21'

			table = values[:table]
			set = values[:values]
			where = values[:where]

			query = String.new()

			if table
				query << "UPDATE #{table} "
			else
				raise "No table at update query."
			end

			query << 'SET'

			if set && set.count > 0
				set.each do |key, value|
					query << " #{key} = '#{value}',"
				end
				query.chop!
			else
				raise 'Nothing to be set.'
			end

			query << ' WHERE'

			if where && where.count > 0
				where.each do |con|
					query << ' ' << con << ','
				end
				query.chop!
			else
				raise 'No WHERE condition in update.'
			end

			return query
		end
	end
end