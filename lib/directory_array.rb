module DirectoryArray
  
     def get_directory_array(path)
      asset_array = Array.new
      asset_absolute_path = Pathname.new(FileBrowserExtension.asset_path.to_s)
      path.children.collect do |child|
         unless hidden?(child)
           if child.directory?
               asset_array << child.relative_path_from(asset_absolute_path)
               asset_array << get_directory_array(child)
           else  
               asset_array << child.relative_path_from(asset_absolute_path)
           end  
         end
     end
     return asset_array.flatten
    end   
  
    def hidden?(path)
      path.realpath.basename.to_s =~ (/^\./)
    end    
  
    def id2path(id)
      asset_absolute_path = Pathname.new(FileBrowserExtension.asset_path.to_s)      
      asset_array = get_directory_array(asset_absolute_path)
      asset_absolute_path + asset_array[id.to_i]
    end
  
end