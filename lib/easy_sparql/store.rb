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
