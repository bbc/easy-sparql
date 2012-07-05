require 'helper'

class EasySparqlTest < Test::Unit::TestCase

  class Programme

    include EasySparql

    attr_accessor :title, :description, :date

  end

  def test_count_all_by_sparql_empty
    load_rdf '<http://ex.co/version-1> rdf:type po:Version .'
    assert_equal 0, Programme.count_all_by_sparql(EasySparql.query.count(:uri).where(
      [ :uri, RDF.type, RDF::PO.Programme ],
    ))
  end

  def test_count_all_by_sparql
    load_rdf '<http://ex.co/programme-1> rdf:type po:Programme .
              <http://ex.co/version-1> rdf:type po:Version .
              <http://ex.co/programme-2> rdf:type po:Programme .
              <http://ex.co/version-2> rdf:type po:Version .
              <http://ex.co/programme-3> rdf:type po:Programme .'
    assert_equal 3, Programme.count_all_by_sparql(EasySparql.query.count(:uri).where(
      [ :uri, RDF.type, RDF::PO.Programme ],
    ))
    assert_equal 2, Programme.count_all_by_sparql(EasySparql.query.count(:uri).where(
      [ :uri, RDF.type, RDF::PO.Version ],
    ))
  end

  def test_find_all_by_sparql
    load_rdf '<http://ex.co/programme-1> rdf:type po:Programme .
              <http://ex.co/programme-1> dc:title "Programme" .
              <http://ex.co/programme-2> rdf:type po:Version .
              <http://ex.co/programme-2> dc:title "Version" .'
    programmes = Programme.find_all_by_sparql(EasySparql.query.select(:title).where(
      [ :uri, RDF.type, RDF::PO.Programme ],
      [ :uri, RDF::DC11.title, :title ]
    ))
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
    programme = Programme.find_by_sparql(EasySparql.query.select(:title, :description).where(
      [ RDF::URI.new('http://ex.co/programme-1'), RDF::DC11.title, :title ],
      [ RDF::URI.new('http://ex.co/programme-1'), RDF::DC11.description, :description ]
    ))
    assert_equal "Programme", programme.title
    assert_equal "Description", programme.description
    assert_equal Programme, programme.class
    programme = Programme.find_by_sparql(EasySparql.query.select(:title).where(
      [ RDF::URI.new('http://ex.co/programme-2'), RDF::DC11.title, :title ]
    ))
    assert_equal "Programme 2", programme.title
    assert_equal Programme, programme.class
  end

  def test_find_by_sparql_casts_dates
    load_rdf '<http://ex.co/programme-1> dc:date "2010-08-07T12:00:00+00:00"^^xsd:dateTime .'
    programme = Programme.find_by_sparql(EasySparql.query.select(:date).where(
      [ RDF::URI.new('http://ex.co/programme-1'), RDF::DC11.date, :date ]
    ))
    assert_equal DateTime, programme.date.class
    assert_equal 2010, programme.date.year
    assert_equal 8, programme.date.month
    assert_equal 7, programme.date.day
    assert_equal 12, programme.date.hour
  end

  def test_find_by_sparql_and_optional
    load_rdf '<http://ex.co/programme-1> a <http://purl.org/ontology/po/Brand> .'
    programme = Programme.find_by_sparql(EasySparql.query.select(:title).where(
      [ RDF::URI.new('http://ex.co/programme-1'), RDF.type, RDF::PO.Brand ]
    ).optional(
      [ RDF::URI.new('http://ex.co/programme-1'), RDF::DC11.title, :title ]
    ))
    assert_equal Programme, programme.class
  end

  def test_query_object_accesible_at_class_and_instance_level
    assert Programme.query
    assert Programme.new.query
  end

end
