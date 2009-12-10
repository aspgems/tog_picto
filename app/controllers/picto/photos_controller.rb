class Picto::PhotosController < ApplicationController

  helper 'picto/base'
  include Picto::BaseHelper

  def index
    if logged_in?
      @latest_photos = Picto::Photo.latest.select do |photo|
        current_user.can_read?(photo)
      end
    else
      @latest_photos = Picto::Photo.public.all({ :limit => "20", :order => "created_at desc" })
    end
  end

  def show
    @photo = Picto::Photo.find(params[:id])
    @size = (params[:size] || :big).to_sym     
    unless @photo.can_be_read_by?(current_user)
      flash[:error] = "Unauthorized"
      redirect_to :action => 'index' and return
    end
  end

  def tags
    @tag = params[:tag]
    extract_query_options
    if logged_in?
      @photos = Picto::Photo.find_tagged_with(@tag).select do |photo|
        current_user.can_read?(photo)
      end.paginate(pagination_options)
    else
      @photos = Picto::Photo.public.find_tagged_with(@tag).paginate(pagination_options)
    end
  end
  
end
