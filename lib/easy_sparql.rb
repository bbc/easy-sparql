require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'store.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'resource.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'mock_cache.rb')
require File.join(File.expand_path(File.dirname(__FILE__)), 'easy_sparql', 'vocab.rb')
require 'date'

module EasySparql

  def self.store=(store)
    @store = store
  end

  def self.store
    raise Exception.new("You need to specify a store using EasySparql.store = ... before trying to access it") unless @store
    @store
  end

  def self.query
    store.sparql_client
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def query
      EasySparql.query
    end

    def count_all_by_sparql(query)
      results = query.execute
      results.empty? ? 0 : query.execute.first[:count].to_i
    end

    def find_all_by_sparql(query)
      to_map = query.values.map { |symbol, var| symbol }
      results = query.execute
      objects = []
      results.each do |result|
        object = new
        to_map.each do |symbol|
          value = result[symbol]
          if value and value.literal?
            value = value.object
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

  def query
    EasySparql.query
  end

end

# Monkey-patching sparql-client to add count support
module SPARQL; class Client

  class Query < RDF::Query

    def self.count(*variables)
      options = variables.last.is_a?(Hash) ? variables.pop : {}
      unless variables.size == 1 and variables.first.is_a?(Symbol)
        raise Exception.new "Only one symbol must be provided for count"
      end
      self.new(:select, options).select(:count => variables.first)
    end

    def filter(string)
      ((options[:filters] ||= []) << string) if string and not string.empty?
      self
    end

  end

  def count(*args)
    call_query_method(:count, *args)
  end

end; end

class RDF::Query
  class Variable
    def initialize(name = nil, value = nil)
      @count = false
      if name.is_a?(Hash) and name.has_key?(:count)
        @count = true
        name = name[:count]
      end
      @name = (name || "g#{__id__.to_i.abs}").to_sym
      @value = value
    end
    def count?
      @count
    end
    def to_s
      prefix = distinguished? ? '?' : "??"
      var_s = "#{prefix}#{name}"
      var_s =  "(COUNT(DISTINCT #{var_s}) AS ?count)" if count?
      unbound? ? var_s : "#{var_s}=#{value}"
    end
  end
end
