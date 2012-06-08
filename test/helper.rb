require 'test/unit'
require 'test/unit/assertions'
require 'restclient'

require File.join(File.dirname(__FILE__), '..', 'lib', 'easy_sparql')

TEST_REDSTORE_PORT = 1234

# Mock memcached

class MockCache

  def initialize
    @cache = {}
  end

  def get(key)
    @cache[key] if @cache.has_key? key
  end

  def set(key, value)
    @cache[key] = value
  end

  def reset!
    @cache = {}
  end

end


class Test::Unit::TestCase

  @has_data = false

  def setup
    EasySparql::Resource.cache = MockCache.new
  end

  def start_redstore
    @pid = Process.fork
    if @pid.nil? then
      exec "redstore -q -p #{TEST_REDSTORE_PORT}"
    else
      sleep(0.1)
    end
  end

  def load_rdf(rdf)
    start_redstore
    EasySparql::Resource.sparql_uri = 'http://localhost:1234/sparql/'
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
