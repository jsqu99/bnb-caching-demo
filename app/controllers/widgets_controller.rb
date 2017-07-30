require 'benchmark'

class WidgetsController < ApplicationController

  before_filter :set_cache_headers, :only => [:dumb, :plucked, :poorly_fragment_cached, :smartly_fragment_cached]
  before_filter :set_cache_headers2, :only => [:dumb_304, :smart_304]
  before_filter :set_cache_headers3, :only => [:smartest_304]
  
  def dumbest
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.all
        render 'widgets/index'
      end
    end
  end

  def plucked
    Benchmark.bm do |bm|
      bm.report do
        @names = Widget.pluck(:name)
        render 'widgets/plucked'
      end
    end
  end
  
  def poorly_fragment_cached
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.all
        render 'widgets/poorly_fragment_cached'
      end
    end
  end

  def smartly_fragment_cached
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.scoped
        render 'widgets/smartly_fragment_cached'
      end
    end
  end

  def dumb_304
    Benchmark.bm do |bm|
      bm.report do
        @widgets = Widget.all
        render 'widgets/index'
      end
    end
  end

  def smart_304
    Benchmark.bm do |bm|
      bm.report do
        if stale?(last_modified: Widget.order(:updated_at).last.updated_at)
          @widgets = Widget.all
          render 'widgets/index'
        end
      end
    end
  end

  def smartest_304
    smart_304
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
  def set_cache_headers2
    response.cache_control[:public] = true
    response.cache_control[:no_cache] = true
  end
  def set_cache_headers3
    response.cache_control[:public] = true
    response.cache_control[:max_age] = 30    
  end
end
