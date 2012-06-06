# Artdeco

[![Build History][2]][1]

[1]: http://travis-ci.org/tracksun/artdeco
[2]: https://secure.travis-ci.org/tracksun/artdeco.png?branch=master

Decorators for Rails 

* extend an object with given classes (default is \<object.class\>Decorator, if defined)
* make helpers accessible in object via :h

### Example

Decorate a model in your controller:

   def show
     article = Article.find(params[:id])
     @article = Artdeco.decorate(article, self)
   end

   def index
     articles = Article.all
     @articles = Artdeco.decorate(articles, self)
   end

Then @article will be extended by module ArticleDecorator
and has access to your helpers via :h

   module ArticleDecorator
     def image
       h.image_tag('article')
     end
   end

and your views may use the decorated model: 

   # app/views/articles/show.html.haml
   %h1 
     Article
     = @article.image


Modules for decoration may be given explicitly:

   Artdeco.decorate(user, self, decorator: Customer)

   # or

   Artdeco.decorate(user, self, decorator: [ Customer, Admin ] )


For conveniance decorated objects may decorate other objects:
   Artdeco.decorate(order, self)

   order.decorate(shopping_card)
