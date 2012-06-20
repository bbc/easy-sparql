require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'store.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'resource.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'mock_cache.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'vocab.rb')

module EasySparql

  def self.store=(store)
    @store = store
  end

  def self.store
    raise Exception("You need to specify a store using EasySparql.store = ... before trying to access it") unless @store
    @store
  end

  def self.query
    store.sparql_client
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def find_all_by_sparql(query)
      to_map = query.values.map { |symbol, var| symbol }
      results = query.execute
      objects = []
      results.each do |result|
        object = new
        to_map.each do |symbol|
          value = result[symbol]
          if value.literal? and value.plain?
            value = value.to_s
          end
          setter = (symbol.to_s + '=').to_sym
          object.send(setter, value)
        end
        objects << object
      end
      objects
    end

    def find_by_sparql(query)
      find_all_by_sparql(query)[0]
    end

  end

end
