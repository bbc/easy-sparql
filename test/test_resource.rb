require 'helper'

class ResourceTest < Test::Unit::TestCase 

  include EasySparql

  def test_add_namespace
    Resource.add_namespace 'foo' => 'bar', 'foo2' => 'bar2'
    assert_equal 'bar', Resource.namespaces['foo']
    assert_equal 'bar2', Resource.namespaces['foo2']
  end

  def test_initialize
    r = Resource.new
    assert_equal(nil, r.uri)

    r = Resource.new(RDF::URI.new('http://ex.co/programme-1'))
    assert_equal('http://ex.co/programme-1', r.uri.to_s)
    assert_equal({}, r.method_bindings)

    r = Resource.new(RDF::URI.new('http://ex.co/programme-1'), [
      [ RDF::URI.new('http://purl.org/dc/elements/1.1/title'), RDF::Literal.new('Title') ],
      [ RDF::URI.new('http://purl.org/dc/elements/1.1/title'), RDF::Literal.new('Alternate') ],
      [ RDF::URI.new('http://purl.org/dc/elements/1.1/title'), RDF::Literal.new('Alternate 2') ],
      [ RDF::URI.new('http://purl.org/ontology/po/synopsis'), RDF::Literal.new('Synopsis') ],
      [ RDF::URI.new('http://ex.co/property_foo'), RDF::Literal.new('Bar') ],
    ])
    assert_equal('http://ex.co/programme-1', r.uri.to_s)
    # Unknown namespaces are left out of method bindings
    assert_equal({ 
      :dc_title => 'Title',
      :dc_titles => [ 'Title', 'Alternate', 'Alternate 2' ], 
      :po_synopsis => 'Synopsis' 
    }, r.method_bindings)
    assert_equal([ :dc_title, :po_synopsis ], r.properties)
    assert_equal('Title', r.dc_title)
    assert_equal([ 'Title', 'Alternate', 'Alternate 2' ], r.dc_titles)
    assert_equal('Synopsis', r.po_synopsis.to_s)
  end

  def test_find_by_uri
    load_rdf '<http://ex.co/programme-1> <http://purl.org/dc/elements/1.1/title> "Test".'
    r = Resource.find_by_uri('http://ex.co/programme-1')
    assert_equal('http://ex.co/programme-1', r.uri.to_s)
    assert_equal('Test', r.dc_title.to_s)
  end

  def test_find_by_uri_is_cached
    load_rdf '<http://ex.co/programme-1> <http://purl.org/dc/elements/1.1/title> "Test".'
    r1 = Resource.find_by_uri('http://ex.co/programme-1')
    r2 = Resource.find_by_uri('http://ex.co/programme-1')
    assert_equal(r1, r2)
  end

  def test_find_type
    load_rdf '<http://ex.co/programme-1> a <http://ex.co/class-1> .'
    t = Resource.find_type('http://ex.co/programme-1')
    assert_equal('http://ex.co/class-1', t.to_s)
    t = Resource.find_type('http://ex.co/programme-2')
    assert_equal(nil, t)
  end

  class Brand < Resource

  end

  def test_follow_your_nose
    load_rdf '<http://ex.co/programme-1> <http://purl.org/ontology/po/brand> <http://ex.co/brand-1>.
              <http://ex.co/programme-1> <http://purl.org/ontology/po/franchise> <http://ex.co/brand-2>.
              <http://ex.co/brand-1> <http://purl.org/dc/elements/1.1/title> "Programme".
              <http://ex.co/brand-2> <http://purl.org/dc/elements/1.1/title> "Franchise".'
    r = Resource.find_by_uri('http://ex.co/programme-1')
    assert_equal(Resource, r.po_franchise.class) # Default mapping
    Resource.map :po_brand => Brand # Object of po_brand will be mapped to the brand class
    assert_equal(Brand, r.po_brand.class)
    assert_equal('Programme', r.po_brand.dc_title)
    assert_equal(r.po_brand, r.po_brand) # Checking that we cached the result the first time we followed our nose
  end

end
