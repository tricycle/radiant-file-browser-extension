class Admin::FileController < ApplicationController
  include DirectoryArray
  
  def index
    @assets = Pathname.new(FileBrowserExtension.asset_path)
    @asset_lock = AssetLock.lock_version
  end
  
  def new
    @asset_lock = AssetLock.lock_version
    @parent_id = params[:parent_id]
    if request.post?
      if params[:new_type] == 'Directory'
        @file = DirectoryAsset.new(params[:asset])
      else
        @file = FileAsset.new(params[:asset])
      end

      if @file.save
        redirect_to files_path
      else
        if @file.errors.no == 0
           flash[:error] = @file.errors.full_messages.join(", ")
           redirect_to files_path
        end 
      end
    end
  end
  
  def remove
    @asset = Asset.find(params[:id], params[:v])
    @asset_lock = AssetLock.lock_version
    unless @asset.pathname.nil?
      if request.post?      
        if @asset.destroy
          flash[:notice] = "The asset was successfully removed."   
        else
          flash[:error] = @asset.errors.full_messages.join(", ")
        end
        redirect_to files_path
      end
    else
       flash[:error] = @asset.errors.full_messages.join(", ")
       redirect_to files_path
    end
  end
  
  def edit
    @file = Asset.find(params[:id], params[:v])
    
    unless @file.pathname.nil?
      if request.post?
        if @file.update(params[:asset])
          flash[:notice] = @file.success
          redirect_to files_path
        else
          if @file.errors.no == 0
            flash[:error] = @file.errors.full_messages.join(", ")
            redirect_to files_path
          end
        end
   
      end
    else
       flash[:error] = @file.errors.full_messages.join(", ")
       redirect_to files_path
    end
  end
  
  def children
    if request.xhr?
      @asset_lock = params[:asset_lock]  
      if AssetLock.confirm_lock(@asset_lock)
         @id = params[:id]
         @assets = Pathname.new(FileBrowserExtension.asset_path) 
         @indent_level = params[:indent_level]
      else
         @error_message = "The assets have been modified since it was last loaded. Please <a href=''>reload</a> this page."
      end
      render :layout => false
    end
  end       

end
