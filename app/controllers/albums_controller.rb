class AlbumsController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:new, :edit, :destroy]
  before_filter :find_album, :only => [:edit, :update, :upload_photos, :show, :destroy]
  before_filter :manipulatable?, :only => [:edit, :destroy]
  
  def index
    @albums = current_user.albums.includes(:images)
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
  
  def edit
  end
  
  def update
    if @album.update_attributes(params[:album])
      render :json => {:success => -1, :message => "Album has been updated"}
    else
      render :json => {:success => 1, :message => "An error occured. Album was not updated"}
    end
  end
  
  def show
    @images = @album.images
  end
  
  def destroy
    @album.destroy
    flash[:notice] = "Your album has been deleted"
    redirect_to :action => :index
  end
  
  def upload_photos
    image = Image.new(coerce(params))
    
    if image.save
      @album.images << image
      
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
  
  def find_album
    @album = Album.find(params[:id])
  end
  
  def manipulatable?
    unless @album.user_id == current_user.id
      redirect_to :action => :index
    end
  end
  
end
