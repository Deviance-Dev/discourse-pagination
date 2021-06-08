# name: discourse-pagination
# about: Use Pagination instead of the infinite scroll
# version: 0.0.1
# authors: Maxim

register_asset "stylesheets/pagination.scss"

after_initialize do
  require_dependency 'application_controller'

  module ::InfluxPagination
    PLUGIN_NAME = "discourse-pagination".freeze

    class Engine < ::Rails::Engine
      engine_name InfluxPagination::PLUGIN_NAME
      isolate_namespace InfluxPagination
    end
  end

  class ::InfluxPagination::PaginationController < ::ApplicationController
    requires_plugin InfluxPagination::PLUGIN_NAME

    skip_before_action :check_xhr
    
    def total_topics
      # Topic.listable_topics.where(archetype: Archetype.default).count
      #@cat = Category.where(name_lower: params[:categoryName]).first || Category.first
      tc = Topic.listable_topics.where("category_id = ?", params[:categoryName]).count
      render :json => {success: true, total: tc}
    end
  end

  InfluxPagination::Engine.routes.draw do
    get "/topics/:categoryName/total" => "pagination#total_topics"
  end

  Discourse::Application.routes.prepend do
    mount ::InfluxPagination::Engine, at: "/influx_pagination"
  end

end
