require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/file/rindex.html" do

    before(:each) do
        @asset_lock = AssetLock.lock_version
        @test_dir_path = File.join(FileBrowserExtension.asset_path, 'Test1')
        assigns[:asset_lock] = @asset_lock
    end

    it "should render new asset page" do
        render "/admin/file/new.rhtml"

        response.should have_tag("form[action=''][method=post]") do
        end
    end    

    it "should render add child page" do
        Dir.mkdir(@test_dir_path) 
        parent_id = path2id(@test_dir_path)
        assigns[:parent_id] = parent_id
        render "/admin/file/new.rhtml"
        Pathname.new(@test_dir_path).rmdir 
        

        response.should have_tag("form[action=''][method=post]") do
             with_tag("input[type='hidden'][name='version'][value=#{@asset_lock}]")
             with_tag("input[type='hidden'][name='asset[parent_id]'][value=#{parent_id}]")
        end  
    end    

end