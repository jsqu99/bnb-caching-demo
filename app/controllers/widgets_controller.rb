require 'benchmark'

class WidgetsController < ApplicationController

  before_filter :set_cache_headers
  
  def index
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.all
        render 'widgets/index'
      end
    end
  end

  def plucked_index
    Benchmark.bm do |bm|
      bm.report do
        @names = Widget.pluck(:name)
        render 'widgets/plucked_index'
      end
    end
  end
  
  def poorly_fragment_cached_index
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.all
        render 'widgets/poorly_fragment_cached_index'
      end
    end
  end

  def smartly_fragment_cached_index
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.scoped
        render 'widgets/smartly_fragment_cached_index'
      end
    end
  end
  
  def show
    Benchmark.bm do |bm|
      bm.report do
        @widget = Widget.find(params[:id])
      end
    end
  end

  private
  def set_cache_headers
    response.cache_control[:public] = false
    response.cache_control[:no_cache] = true
    response.cache_control[:max_age] = 0
  end
end


































__END__












































def show_goofy
  @widget = Widget.find(1)

  @widget.touch if params[:touch] = 't'
  
  request.session_options[:skip] = true     # remove Set-Cookie
  response.cache_control[:no_cache] = 'no-cache' unless params[:vis] || params[:ma]
  response.cache_control[:public] = public?
  response.cache_control[:max_age] = max_age
  handle_conditional_get
end

private
def public?
  params[:vis] == 'private' ? false : true
end

def max_age
  ma = params[:ma].try(:to_i) || 0
end

def handle_conditional_get
  fresh_when(@widget) if params[:fw] == 't'
end

