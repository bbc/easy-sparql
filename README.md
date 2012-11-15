easy-sparql
===========

A gem to explore SPARQL end-points easily. It provides two main modes:

* Exploring the graph held in a triple store
* Mapping SPARQL queries to model instances

EasySparql::Resource
--------------------

The EasySparql::Resource class provides some graph-walking facilities,
to explore the graph stored in a remote triple store. This mode is useful
for rapidly prototyping an application on top of a triple store.

    require 'easy\_sparql'
    include EasySparql
    EasySparql.store = EasySparql::Store.new 'http://dbpedia.org/sparql/'
    Resource.add\_namespace 'dbpo' => 'http://dbpedia.org/ontology/'
    resource = Resource.find\_by\_uri('http://dbpedia.org/resource/Doctor\_Who')
    resource.rdfs\_label
    resource.properties
    resource.dbpo\_genre.uri
    resource.dbpo\_country.dbpo\_largestCity.uri


EasySparql
----------

The main module can be included into a model class and provides a few
utilities to map SPARQL queries to model instances. This mode is useful
for applications needing to specify explicitly the SPARQL queries
that can be executed.


    require 'easy\_sparql'
    EasySparql.store = EasySparql::Store.new 'http://dbpedia.org/sparql/'
    class TelevisionShow
      include EasySparql
      attr_accessor :title, :uri
    end
    shows = TelevisionShow.find\_all\_by\_sparql(
      EasySparql.query.select(:uri, :title).where(
        [ :uri, RDF.type, RDF::URI.new('http://dbpedia.org/ontology/TelevisionShow') ], 
        [ :uri, RDF::RDFS.label, :title ] 
      ).filter('lang(?title) = "en"').limit(10)
    )
    puts shows.map { |s| s.title }


Running the tests
-----------------

The tests rely on the lightweight RedStore triplestore: http://www.aelius.com/njh/redstore/.

Once RedStore is installed:

    $ bundle install
    $ bundle exec rake
