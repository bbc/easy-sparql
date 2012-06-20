easy-sparql
===========

A gem to explore SPARQL end-points easily.


EasySparql
----------

The main module can be included into a model class and provides a few
utilities to map SPARQL queries to model instances.


  require 'easy\_sparql'
  EasySparql.store = EasySparql::Store.new 'http://wsarchive-staging.prototype0.net/sparql/'
  class Episode
    include EasySparql
    attr_accessor :title
  end
  episodes = Episode.find\_all\_by\_sparql(EasySparql.query.select(:title).where([ :uri, RDF.type, RDF::PO.Episode ], [ :uri, RDF::DC11.title, :title ] ).limit(10))
  episodes[0].title


EasySparql::Resource
--------------------

The EasySparql::Resource class provides some graph-walking facilities,
to explore the graph stored in a remote triple store.

  require 'easy\_sparql'
  include EasySparql
  EasySparql.store = EasySparql::Store.new 'http://wsarchive-staging.prototype0.net/sparql/'
  resource = Resource.find\_by\_uri('http://wsarchive.prototype0.net/programmes/episode-49590#programme')
  resource.dc\_title


