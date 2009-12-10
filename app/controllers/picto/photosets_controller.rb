class Picto::PhotosetsController < ApplicationController

  helper 'picto/base'
  include Picto::BaseHelper

  before_filter :extract_query_options
  
  def index
    if logged_in?
      @photosets = Picto::Photoset.all.select do |set|
        current_user.can_read?(set)
      end.paginate(pagination_options)
    else
      @photosets = Picto::Photoset.public.paginate(pagination_options)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @photosets }
    end    
  end
  
  def show
    @photoset = Picto::Photoset.find(params[:id])
    unless @photoset.can_be_read_by?(current_user)
      flash[:error] = "Unauthorized"
      redirect_to :action => 'index' and return
    end
    @photos = @photoset.photos.paginate(pagination_options)
  end

end
