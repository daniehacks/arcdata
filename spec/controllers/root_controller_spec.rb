require 'spec_helper'

describe RootController do
  include LoggedIn

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end

  describe "GET 'health'" do
    it "returns http success" do
      get 'health'
      response.should be_success
    end

    it "returns 500 when there's an error" do
      ActiveRecord::Base.connection.should_receive(:select_value) { raise "Database Problem!" }
      Raven.should_receive(:capture)
      get 'health'
      response.status.should == 500
    end
  end

  describe "GET 'inactive'" do
    it "returns http forbidden and renders" do
      get 'inactive', format: :html
      response.should be_forbidden
      response.should render_template("inactive")
    end

    it "returns http forbidden and renders" do
      get 'inactive', format: :json
      response.should be_forbidden
    end
  end

  describe "#homepage_links" do

    let!(:link) {FactoryGirl.create(:homepage_link)}

    it "should return a link for no chapter" do
      controller.homepage_links.values.flatten.should =~ [link]
    end

    it "should return a hash" do
      controller.homepage_links.should be_a(Hash)
    end

    it "should return a link for the current chapter" do
      link.update_attributes chapter: @person.chapter
      controller.homepage_links.values.flatten.should =~ [link]
    end

    it "should not return a link for another chapter" do
      other_chapter = FactoryGirl.create :chapter
      link.update_attributes chapter: other_chapter
      controller.homepage_links.values.flatten.should =~ []
    end

    it "should return a link where the current user has the correct role" do
      role = FactoryGirl.create :role, chapter: @person.chapter
      pos = FactoryGirl.create :position, roles: [role], chapter: @person.chapter
      @person.positions << pos
      @person.save

      link.update_attributes roles: [role]
      controller.homepage_links.values.flatten.should =~ [link]
    end

    it "should not return a link where the current user does not have the right role" do
      role = FactoryGirl.create :role, chapter: @person.chapter
      link.update_attributes roles: [role]
      controller.homepage_links.values.flatten.should =~ []
    end

  end

end
