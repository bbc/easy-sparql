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

require 'test/unit'
require 'test/unit/assertions'
require 'restclient'

require File.join(File.dirname(__FILE__), '..', 'lib', 'easy_sparql')

TEST_REDSTORE_PORT = 1234

class Test::Unit::TestCase

  @has_data = false

  def setup
    EasySparql::Resource.cache = EasySparql::MockCache.new
  end

  def start_redstore
    @pid = Process.fork
    if @pid.nil? then
      exec "redstore -q -p #{TEST_REDSTORE_PORT} -s sqlite test/test.db -n"
    else
      sleep(0.2)
    end
  end

  def load_rdf(rdf)
    prefixes = '@prefix po: <http://purl.org/ontology/po/> .
              @prefix ws: <http://wsarchive.prototype0.net/ontology/> .
              @prefix dc: <http://purl.org/dc/elements/1.1/> .
              @prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
              @prefix xsd: <http://www.w3.org/2001/XMLSchema#> .
             '
    rdf = prefixes + rdf
    start_redstore
    EasySparql.store = EasySparql::Store.new 'http://localhost:1234/sparql/'
    unless @pid.nil?
      RestClient.post("http://localhost:#{TEST_REDSTORE_PORT}/data/test.rdf", rdf, :content_type => 'application/x-turtle')
      @has_data = true
    end
  end

  def teardown
    if @has_data
      RestClient.delete "http://localhost:#{TEST_REDSTORE_PORT}/data/test.rdf"
      @has_data = false
    end
    Process.kill('KILL', @pid) unless @pid.nil?
    EasySparql::Resource.cache.reset!
  end

end
