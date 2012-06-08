easy-sparql
===========

A gem to explore SPARQL end-points simply.

Example use
-----------

  require 'easy\_sparql'
  include EasySparql
  Resource.sparql\_uri = 'http://wsarchive-staging.prototype0.net/sparql/'
  resource = Resource.find\_by\_uri('http://wsarchive.prototype0.net/programmes/episode-49590#programme')
  resource.dc\_title
