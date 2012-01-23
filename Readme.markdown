# Artdeco

Decorators for Rails 

* extend an object with given classes (default is \<object.class\>Decorator, if defined)
* make helpers accessible in object via :h

### Example

Decorate a model in your controller:

```ruby
  def show
    article = Article.find(params[:id])
    @article = TracksGrid::Decorator.decorate(article, self)
  end
```

Then @article will be extended by module ArticleDecorator
and has access to your helpers via :h

```ruby
module ArticleDecorator
  def image
    h.image_tag('article')
  end
end
```
and your views may use the decoratored model: 

```ruby
# app/views/articles/show.html.haml
%h1 
  Article
  = @article.image
```

