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

require 'sparql/client'
require 'active_support/inflector'

module EasySparql

  class Resource

    @@namespaces = {
      'ws' => 'http://wsarchive.prototype0.net/ontology/',
      'po' => 'http://purl.org/ontology/po/',
      'dc' => 'http://purl.org/dc/elements/1.1/',
      'rdf' => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
      'rdfs' => 'http://www.w3.org/2000/01/rdf-schema#',
    }
    @@property_map = {}

    attr_accessor :uri
    attr_reader :method_bindings
    attr_reader :properties
    attr_reader :namespaces

    @@cache = nil

    def self.cache=(cache)
      @@cache = cache
    end

    def self.cache
      @@cache
    end

    def self.map(mapping)
      @@property_map.merge! mapping
    end

    def self.add_namespace(mappings)
      mappings.each do |k, v|
        @@namespaces[k] = v
      end
    end

    def self.namespaces
      @@namespaces
    end

    def initialize(uri = nil, bindings = [])
      @properties = []
      @method_bindings = {}
      @uri = uri
      bindings.each do |property, value|
        value = value.object if value.respond_to? :object
        namespaces_i = @@namespaces.invert
        namespaces_i.each do |base, short|
          if property.to_s.start_with?(base)
            method_name = property.to_s.sub(base, short + '_')
            # If we already have a binding for that method, this
            # method now outputs an array and we pluralise the method name
            # The singular method name gives the first element of the array
            if @method_bindings.has_key? method_name.pluralize.to_sym
                @method_bindings[method_name.pluralize.to_sym] << value
            elsif @method_bindings.has_key? method_name.to_sym
              old_value = @method_bindings[method_name.to_sym]
              @method_bindings[method_name.pluralize.to_sym] = [ old_value, value ]
            else
              @method_bindings[method_name.to_sym] = value
            end
            @properties << method_name.to_sym
          end
        end
      end
      @properties.uniq!
    end

    def self.find_by_uri(uri)
      cached_resource = @@cache.get(uri) if @@cache
      return cached_resource if cached_resource
      resource = find_by_uri_from_sparql(uri)
      @@cache.set(uri, resource) if @@cache
      resource
    end

    def self.find_by_uri_from_sparql(uri)
      uri = RDF::URI.new(uri) if uri.class == String
      results = sparql.select.where([uri, :p, :o]).execute
      bindings = []
      results.each do |result|
        bindings << [ result.p, result.o ]
      end
      resource = new(uri, bindings)
    end

    def self.find_type(uri)
      uri = RDF::URI.new(uri) if uri.class == String
      results = sparql.select.where([uri, RDF.type, :type]).execute
      results[0][:type] unless results.empty?
    end

    def self.sparql
      EasySparql.store.sparql_client
    end

    protected

    def method_missing(name, *args, &block)
      if args.empty? && @method_bindings.has_key?(name.to_sym)
        value = @method_bindings[name.to_sym]
        if value.class == RDF::URI
          # Following our nose and caching the result in the object
          if @@property_map.has_key? name.to_sym
            @method_bindings[name.to_sym] = @@property_map[name.to_sym].find_by_uri(value)
          else
            @method_bindings[name.to_sym] = Resource.find_by_uri(value)
          end
        else
          value
        end
      else
        nil
      end
    end

  end
end
