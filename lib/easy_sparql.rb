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

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def find_all_by_sparql(to_map, query)
      results = EasySparql.store.sparql_client.select(*to_map).where(*query).execute
      objects = []
      results.each do |result|
        to_map.each do |symbol|
          setter = (symbol.to_s + '=').to_sym
          object = new
          object.send(setter, result[symbol].value)
          objects << object
        end
      end
      objects
    end

  end

end
