require 'helper'

class EasySparqlTest < Test::Unit::TestCase

  class Programme

    include EasySparql

    attr_accessor :title, :description

  end

  def test_find_all_by_sparql
    load_rdf '<http://ex.co/programme-1> rdf:type po:Programme .
              <http://ex.co/programme-1> dc:title "Programme" .
              <http://ex.co/programme-2> rdf:type po:Version .
              <http://ex.co/programme-2> dc:title "Version" .'
    programmes = Programme.find_all_by_sparql( [ :title ], [
      [ :uri, RDF.type, RDF::PO.Programme ],
      [ :uri, RDF::DC11.title, :title ],
    ])
    assert_equal 1, programmes.size
    assert_equal "Programme", programmes[0].title
    assert_equal Programme, programmes[0].class
  end

  def test_find_by_sparql
    load_rdf '<http://ex.co/programme-1> rdf:type po:Programme .
              <http://ex.co/programme-1> dc:title "Programme" .
              <http://ex.co/programme-1> dc:description "Description" .
              <http://ex.co/programme-2> rdf:type po:Programme .
              <http://ex.co/programme-2> dc:title "Programme 2" .'
    programme = Programme.find_by_sparql( [ :title, :description ], [
      [ RDF::URI.new('http://ex.co/programme-1'), RDF::DC11.title, :title ],
      [ RDF::URI.new('http://ex.co/programme-1'), RDF::DC11.description, :description ],
    ])
    assert_equal "Programme", programme.title
    assert_equal "Description", programme.description
    assert_equal Programme, programme.class
    programme = Programme.find_by_sparql( [ :title ], [
      [ RDF::URI.new('http://ex.co/programme-2'), RDF::DC11.title, :title ],
    ])
    assert_equal "Programme 2", programme.title
    assert_equal Programme, programme.class
  end

end
