# easy-sparql
#
# Copyright (c) 2011 British Broadcasting Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
