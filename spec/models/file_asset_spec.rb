require File.dirname(__FILE__) + '/../spec_helper'

def current_version
  AssetLock.lock_version
end

def error_message(err_type)
  [:modified, :unknown, :blankid].include?(err_type) ? Asset::Errors::CLIENT_ERRORS[err_type] : "Asset name " + Asset::Errors::CLIENT_ERRORS[err_type]
end

describe FileAsset do
  before do
    @test_upload_file = 'test_image.jpg'
    @renamed_test_upload_file = 'test_image_new.jpg'
    @second_test_upload_file = 'test_image2.jpg'
    FileUtils.mkdir_p(FileBrowserExtension.asset_path)
    @file = FileAsset.new('uploaded_data' => fixture_file_upload(@test_upload_file, "image/jpg"), 'parent_id' => nil, 'version' => current_version, 'new_type' => 'File')
  end
  after do
    FileUtils.rm_r(FileBrowserExtension.asset_path)
  end
    
  it "should be not be valid if there are errors"
  it "should not save the asset to the filesystem if it is invalid"

  describe 'filesystem Create' do
    it "should create a file" do
      file_asset = FileAsset.new('uploaded_data' => fixture_file_upload(@test_upload_file, "image/jpg"), 'parent_id' => nil, 'version' => current_version, 
'new_type' => 'File')
      file_asset.save.should_not == nil
      Pathname.new(absolute_path(@test_upload_file)).file?.should be_true
    end

  end

  it 'should report the extension of the filename' do    
    @file.save
    @file.extension.should == 'jpg'
  end

  describe 'file type' do

    fixture = [
      #extension                
      ['jpg' ],
      ['jpeg' ],  
      ['gif' ],
      ['bmp' ],
      ['png' ],
    ]

    fixture.each do |ext|
      it 'should identify as image if extension is "#{ext}"' do
        @file.stub!(:extension).and_return("#{ext}")
        @file.image?.should be_true
      end
    end
      
    it 'should identify as image ignoring extension case' do
      @file.stub!(:extension).and_return('PnG')
      @file.image?.should be_true
    end
    
    it 'should identify as non-image if has no extension' do
      @file.save
      @file.stub!(:extension).and_return('')
      
      @file.image?.should be_false
    end
    it 'should identify as non-image if extension is not recognised image type'
  end
  
  describe 'embed tag' do
    it 'should give img src if is an image' do
      @file.stub!(:image?).and_return(true)
      
      @file.embed_tag.should =~ /<img src=/
    end
    
    it 'should give a if not an image' do
      @file.stub!(:image?).and_return(false)
      
      @file.embed_tag.should =~ /<a href=/
    end
    
    it 'should point to file location in uri' do
      @file.stub!(:image?).and_return(true)
      FileAsset.stub!(:public_asset_path).and_return('assets')
      
      @file.embed_tag.should == "<img src='assets/#{@file.asset_name}' />"
    end
  end

  describe "file name" do
    it "should have an error if contains backslash characters"
    it "should have an error if contains forwardslash characters"
    it "should have an error if contains fullstop characters"
    
    it "should have an error if already in use" do
      file_asset1 = FileAsset.new('uploaded_data' => fixture_file_upload(@test_upload_file, "image/jpg"), 'parent_id' => nil, 'version' => current_version, 'new_type' => 'File')
      file_asset1.save
      file_asset2 = FileAsset.new('uploaded_data' => fixture_file_upload(@test_upload_file, "image/jpg"), 'parent_id' => nil, 'version' => current_version, 'new_type' => 'File')
      file_asset2.save.should == nil
      file_asset2.errors.full_messages.should == [error_message(:exists)]
    end
  end

  describe 'on version mismatch' do

    it 'should not upload' do
      file_asset = FileAsset.new('uploaded_data' => fixture_file_upload(@test_upload_file, "image/jpg"), 'parent_id' => nil, 'version' => (current_version + 1), 'new_type' => 'File')
      file_asset.save.should == nil
      file_asset.errors.full_messages.should == [error_message(:modified)] 
      Pathname.new(absolute_path(@test_upload_file)).file?.should == false
    end
    
  end

end
