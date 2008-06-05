class DirectoryAsset < Asset
   attr_reader :filename

   def initialize(name, parent_id, version)
      @filename = Asset.confirm_asset_validity_and_sanitize(name)
      @parent_id = parent_id
      @version = version

      @errors = []
      @success = false
   end

   def save
      if Asset.confirm_lock(@version)
	   upload_location = Asset.get_upload_location(@parent_id)
	   new_dir = Pathname.new(File.join(upload_location, @filename))
	   unless new_dir.directory?
	       Dir.mkdir(new_dir)       
	       AssetLock.new_lock_version
               @success = true
           else
               @errors << "Directory already exists."
           end
      else
           @errors << "The assets have been modified since it was last loaded hence could not be created."
      end
   end

   def self.create(name, parent_id, version)
      object = new(name, parent_id, version)
      if object.filename
          object.save
      else
          object.errors << "Filename cannot have characters like \\ / or a leading period."  
      end
      return object
   end

   def self.update(id, name, version)
      object = new(name, nil, version)
      if object.filename
          if self.confirm_lock(version) 
               path = id2path(id)
               new_dir = Pathname.new(File.join(self.get_absolute_path, name))
               unless new_dir.directory?
                   path.rename(new_dir)
                   object.success = "Directory has been sucessfully edited."
                   AssetLock.new_lock_version
              else
                  object.errors << "Directory already exists."
              end
         else
              object.errors << "The assets have been modified since it was last loaded hence could not be updated." 
         end
      else
          object.errors << "Directory cannot have characters like \\ / or a leading period." 
      end
      return object
   end

   def self.destroy(id, version)
      ret_val = false
      if self.confirm_lock(version)
           path = id2path(id)
	   FileUtils.rm_r path, :force => true
           ret_val = true
           AssetLock.new_lock_version         
      end
      return ret_val
   end

end
