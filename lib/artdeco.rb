require "artdeco/version"

module Artdeco

  class Decorator
    attr_reader :params, :view_context
    alias_method :h, :view_context
    
    class << self
      def decorate(model, *args)
        self.new(args).decorate(model)
      end
    end

    # Args may be either the params hash of the request
    # or an object which responds to :params and optionaly to :view_context, e.g. a controller instance
    # If a view_context is given it will be accessible in various blocks by calling :h
    def initialize(*args)
      opts = args.extract_options!
      
      @decorator_classes = ([opts.delete(:decorators)] + [opts.delete(:decorator)]).flatten.compact
      @decorator_classes = nil if @decorator_classes.empty? # required for #decorate

      case args.size
      when 0
        @view_context = opts.delete :view_context 
        @params = opts.delete(:params){opts}
      when 1
        arg = args.first
        @view_context = arg.respond_to?(:view_context) ? arg.view_context : nil

        if arg.respond_to? :params
          @params = arg.params.symbolize_keys.merge(opts)
        else
          raise ArgumentError, 'argument must respond_to :params'
        end
      else
        raise ArgumentError, 'too many arguments' if args.size > 1
      end
    end
 
    # evaluate data (string or proc)
    # if model is provided it will accessible in evaluated data
    def eval( data, model = nil )
      case data
      when Proc
        (model ? model : self).instance_exec(&data)
      else
        data
      end
    end

    def decorate( model, decorator_classes = nil)
      return nil if model.nil?
      decorator_classes ||= @decorator_classes || default_decorator_class(model)
      decorator_classes.each{|dc|model.extend dc}
      h = view_context
      model.define_singleton_method(:h){h}
      model
    end
    
    private
    def default_decorator_class(model)
      @cache ||= {} 
      [@cache.fetch(model.class){"#{model.class}Decorator".constantize rescue nil}].compact
    end
      
  end
end
