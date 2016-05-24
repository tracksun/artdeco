# encoding: UTF-8
$:.unshift File.expand_path( '../lib/', File.dirname( __FILE__))

require 'minitest/autorun'
require 'artdeco'

class ArtdecoTest < MiniTest::Unit::TestCase

  class Foo
     def foo
     end
  end

  class SubFoo < Foo
  end

  class FooHelper
    def hi
    end
  end

  module FooDecorator
    def ho
    end
  end

  module BlaDecorator
    def bla
    end
  end

  class X
    def x
    end

    def self.cx
    end
  end

  module XDecorator
    def y
    end

    module ClassMethods
      def cy
      end
    end
  end

  class FakeController
    def view_context
      @view_context ||= FooHelper.new
    end

    def params
      {}
    end

    def method_missing *args
      view_content.send *args
    end
  end

  def test_decorate_model
    model = Foo.new
    controller = FakeController.new
    Artdeco.decorate model, controller

    assert_respond_to model, :h
    assert_respond_to model, :ho
    assert_respond_to model, :decorate

    h = model.h
    assert_equal FooHelper, h.class
    assert_respond_to h, :hi
  end

  def test_decorate_model_with_given_decorator
    model = Foo.new
    controller = FakeController.new
    Artdeco.decorate model, controller, decorators: BlaDecorator

    assert_respond_to model, :h
    assert_respond_to model, :bla
    assert_respond_to model, :decorate

    h = model.h
    assert_equal FooHelper, h.class
    assert_respond_to h, :hi
  end

  def test_decorate_model_with_given_decorators
    model = Foo.new
    controller = FakeController.new
    Artdeco.decorate model, controller, decorators: [BlaDecorator, FooDecorator]

    assert_respond_to model, :h
    assert_respond_to model, :ho
    assert_respond_to model, :bla
    assert_respond_to model, :decorate

    h = model.h
    assert_equal FooHelper, h.class
    assert_respond_to h, :hi
  end

  def test_decorated_model_can_decorate
    model = Foo.new
    controller = FakeController.new
    model = Artdeco.decorate model, controller

    other = Foo.new
    model.decorate other

    assert_respond_to other, :h
    assert_respond_to other, :ho
    assert_respond_to other, :decorate

    h = other.h
    assert_equal FooHelper, h.class

    another = Foo.new
    model.decorate another, BlaDecorator

    assert_respond_to another, :h
    assert_respond_to another, :bla
    assert !another.respond_to?(:ho)
    assert_respond_to another, :decorate

    h = another.h
    assert_equal FooHelper, h.class
  end

  def decorator_with_hash_argument
    model = Foo.new
    Artdeco.decorate model, view_context: FooHelper.new, params: {}

    assert_respond_to model, :h
    assert_respond_to model, :ho
    assert_respond_to model, :decorate

    h = model.h
    assert_equal FooHelper, h.class
    assert_respond_to h, :hi
  end

  def test_decorate_enums
    models = [Foo.new, Foo.new]
    Artdeco.decorate models, view_context: FooHelper.new, params: {}

    models.each do |model|
      assert_respond_to model, :h
      assert_respond_to model, :ho
      assert_respond_to model, :decorate
    end
  end

  def test_decorate_inherited
    model = SubFoo.new

    controller = FakeController.new
    Artdeco.decorate model, controller

    assert_respond_to model, :h
    assert_respond_to model, :ho
    assert_respond_to model, :decorate

    h = model.h
    assert_equal FooHelper, h.class
  end


  def test_decorate_class_methods
    model = X.new
    assert_respond_to model, :x
    assert_respond_to model.class, :cx

    dmodel = Artdeco.decorate model
    assert_respond_to dmodel, :y
    assert_respond_to dmodel.class, :cy
  end

end
