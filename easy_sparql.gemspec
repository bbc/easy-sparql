Gem::Specification.new do |s|
  s.name = "easy_sparql"
  s.version = "0.1.0"
  s.date = "2012-11-15"
  s.summary = "Simple wrapper to explore SPARQL endpoints"
  s.email = "yves.raimond@bbc.co.uk"
  s.description = "A (very limited) library for exploring SPARQL endpoints simply"
  s.has_rdoc = false
  s.authors = ['Yves Raimond']
  s.files = ["lib/easy_sparql.rb", "lib/easy_sparql/resource.rb", "lib/easy_sparql/mock_cache.rb", "lib/easy_sparql/store.rb", "lib/easy_sparql/vocab.rb"]
  s.add_dependency 'sparql-client'
  s.add_dependency 'activesupport'
  s.add_dependency 'rest-client'
end
