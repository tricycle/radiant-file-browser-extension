require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/file/index.rhtml" do

    before(:each) do
       @assets = Pathname.new(FileBrowserExtension.asset_path)
    end

    it "should render list of assets" do
       render "/admin/file/index.rhtml"
    end

end