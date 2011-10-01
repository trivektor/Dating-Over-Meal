class AlbumsController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:new]
  
  def index
    @albums = current_user.albums
  end
  
  def new
    @album = Album.new
  end
  
  def create
    @album = Album.new(params[:album])
    @album.user_id = current_user.id
    
    if @album.save
      flash[:notice] = "Your album has been created"
      redirect_to :action => :index
    else
      render :action => :new
    end
  end
  
  def upload_photos
    image = Image.new(coerce(params))
    
    if image.save
      render :json => {:succcess => 1}
    else
      render :json => {:succcess => -1}
    end
  end
  
  private
  
  def coerce(params)
    h = Hash.new
    h[:picture] = params[:Filedata]
    h[:picture].content_type = MIME::Types.type_for(h[:picture].original_filename).to_s.gsub("[", "").gsub("]", "")
    h
  end
  
end
