Gem::Specification.new do |s|
  s.name = "easy_sparql"
  s.version = "0.0.1"
  s.date = "2012-06-06"
  s.summary = "Simple wrapper to explore SPARQL endpoints"
  s.email = "yves.raimond@bbc.co.uk"
  s.description = "A (very limited) library for exploring SPARQL endpoints simply"
  s.has_rdoc = false
  s.authors = ['Yves Raimond']
  s.files = ["lib/easy_sparql.rb", "lib/easy_sparql/resource.rb"]
  s.add_dependency 'sparql-client'
  s.add_dependency 'activesupport'
end
