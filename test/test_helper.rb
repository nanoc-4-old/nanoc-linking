# encoding: utf-8

require 'helper'

require 'yard'

class Nanoc::Linking::HelperTest < Minitest::Test

  include Nanoc::Linking::Helper

  def new_item_rep_with_path(path)
    item = Nanoc::Item.new('content', {}, '/')
    snapshot_store = Nanoc::SnapshotStore::InMemory.new
    rep = Nanoc::ItemRep.new(item, :default, :snapshot_store => snapshot_store)
    rep.paths = { :last => path }
    rep
  end

  def teardown
    super
    @item     = nil
    @item_rep = nil
  end

  def test_link_to_with_path
    assert_equal(
      '<a href="/foo/">Foo</a>',
      link_to('Foo', '/foo/')
    )
  end

  def test_link_to_with_rep
    rep = new_item_rep_with_path('/bar/')
    assert_equal(
      '<a href="/bar/">Bar</a>',
      link_to('Bar', rep)
    )
  end

  def test_link_to_with_item
    rep = new_item_rep_with_path('/bar/')
    item_rep_store = Nanoc::ItemRepStore.new([ rep ])
    item = Nanoc::ItemProxy.new(rep.item, item_rep_store)
    assert_equal(
      '<a href="/bar/">Bar</a>',
      link_to('Bar', item)
    )
  end

  def test_link_to_with_attributes
    assert_equal(
      '<a title="Dis mai foo!" href="/foo/">Foo</a>',
      link_to('Foo', '/foo/', :title => 'Dis mai foo!')
    )
  end

  def test_link_to_escape
    assert_equal(
      '<a title="Foo &amp; Bar" href="/foo&amp;bar/">Foo &amp; Bar</a>',
      link_to('Foo &amp; Bar', '/foo&bar/', :title => 'Foo & Bar')
    )
  end

  def test_link_to_to_nil_item_or_item_rep
    obj = Object.new
    def obj.path ; nil ; end

    assert_raises RuntimeError do
      link_to("Some Text", obj)
    end
  end

  def test_link_to_unless_current_current
    @item_rep = new_item_rep_with_path('/foo/')

    assert_equal(
      '<span class="active" title="You\'re here.">Bar</span>',
      link_to_unless_current('Bar', @item_rep)
    )
  end

  def test_link_to_unless_current_not_current
    @item_rep = new_item_rep_with_path('/foo/')

    assert_equal(
      '<a href="/abc/xyz/">Bar</a>',
      link_to_unless_current('Bar', '/abc/xyz/')
    )
  end

  def test_relative_path_to_with_self
    @item_rep = new_item_rep_with_path('/foo/bar/baz/')

    assert_equal(
      './',
      relative_path_to('/foo/bar/baz/')
    )
  end

  def test_relative_path_to_with_root
    @item_rep = new_item_rep_with_path('/foo/bar/baz/')

    assert_equal(
      '../../../',
      relative_path_to('/')
    )
  end

  def test_relative_path_to_file
    @item_rep = new_item_rep_with_path('/foo/bar/baz/')

    assert_equal(
      '../../quux',
      relative_path_to('/foo/quux')
    )
  end

  def test_relative_path_to_dir
    @item_rep = new_item_rep_with_path('/foo/bar/baz/')

    assert_equal(
      '../../quux/',
      relative_path_to('/foo/quux/')
    )
  end

  def test_relative_path_to_rep
    @item_rep = new_item_rep_with_path('/foo/bar/baz/')
    other_item_rep = new_item_rep_with_path('/foo/quux/')

    assert_equal(
      '../../quux/',
      relative_path_to(other_item_rep)
    )
  end


  def test_relative_path_to_item
    @item_rep = new_item_rep_with_path('/foo/bar/baz/')
    other_item_rep = new_item_rep_with_path('/foo/quux/')

    assert_equal(
      '../../quux/',
      relative_path_to(other_item_rep)
    )
  end

  def test_relative_path_to_to_nil
    @item_rep = new_item_rep_with_path(nil)
    other_item_rep = new_item_rep_with_path('/foo/quux/')

    assert_raises RuntimeError do
      relative_path_to(other_item_rep)
    end
  end

  def test_relative_path_to_from_nil
    @item_rep = new_item_rep_with_path('/foo/quux/')
    other_item_rep = new_item_rep_with_path(nil)

    assert_raises RuntimeError do
      relative_path_to(other_item_rep)
    end
  end

  def test_relative_path_to_to_windows_path
    @item_rep = new_item_rep_with_path('/foo/quux/')

    assert_equal '//mydomain/tahontaenrat', relative_path_to('//mydomain/tahontaenrat')
  end

  def test_examples_link_to
    # Parse
    YARD.parse(File.dirname(__FILE__) + '/../../lib/nanoc/helpers/link_to.rb')

    # Mock
    @items = [
      OpenStruct.new(
        :identifier => '/about/',
        :path => '/about.html'),
      OpenStruct.new(
        :identifier => '/software/',
        :path => '/software.html'),
      OpenStruct.new(
        :identifier => '/software/nanoc/',
        :path => '/software/nanoc.html')
    ]
    i = @items[0]
    def i.rep(x)
      OpenStruct.new(:path => '/about.vcf')
    end

    # Run
    assert_examples_correct 'Nanoc::Linking::Helper#link_to'
  end

  def test_examples_link_to_unless_current
    # Parse
    YARD.parse(File.dirname(__FILE__) + '/../lib/nanoc/linking/helper.rb')

    # Mock
    @item_rep = OpenStruct.new(:path => '/about/')
    @item = OpenStruct.new(:path => '/about/')

    # Run
    assert_examples_correct 'Nanoc::Linking::Helper#link_to_unless_current'
  end

  def test_examples_relative_path_to
    # Parse
    YARD.parse(File.dirname(__FILE__) + '/../lib/nanoc/linking/helper.rb')

    # Mock
    @item_rep = self.new_item_rep_with_path('/foo/bar/')

    # Run
    assert_examples_correct 'Nanoc::Linking::Helper#relative_path_to'
  end

end
