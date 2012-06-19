require 'sparql/client'

module EasySparql

  class Store

    def initialize(sparql_uri = nil, update_uri = nil)
      @sparql_uri = sparql_uri
      @update_uri = update_uri
    end

    def sparql_uri=(uri)
      @sparql_uri = uri
    end

    def sparql_uri
      raise Exception.new "You need to set a valid SPARQL URI using Resource.sparql_uri = <uri>" unless @sparql_uri
      @sparql_uri
    end

    def update_uri=(uri)
      @update_uri = uri
    end

    def update_uri
      raise Exception.new "You need to set a valid SPARQL Update URI using Resource.update_uri = <uri>" unless @update_uri
      @update_uri
    end

    def sparql_client
      SPARQL::Client.new @sparql_uri
    end

  end

end
