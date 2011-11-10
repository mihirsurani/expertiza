require File.dirname(__FILE__) + '/../test_helper'
require 'review_mapping_controller'

# Re-raise errors caught by the controller.
class ReviewMappingController; def rescue_action(e) raise e end; end

class ReviewMappingControllerTest < ActionController::TestCase
  # use dynamic fixtures to populate users table
  # for the use of testing
  fixtures :users
  fixtures :assignments
  fixtures :questionnaires
  fixtures :courses
  set_fixture_class :system_settings => 'SystemSettings'
  fixtures :system_settings
  fixtures :content_pages
  @settings = SystemSettings.find(:first)

// set up for each test
  def setup
    @controller = ReviewMappingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @request.session[:user] = User.find(users(:student1).id )
    roleid = User.find(users(:instructor3).id).role_id
    Role.rebuild_cache

    Role.find(roleid).cache[:credentials]
    @request.session[:credentials] = Role.find(roleid).cache[:credentials]
    # Work around a bug that causes session[:credentials] to become a YAML Object
    @request.session[:credentials] = nil if @request.session[:credentials].is_a? YAML::Object
    @settings = SystemSettings.find(:first)
    AuthController.set_current_role(roleid,@request.session)
    #   @request.session[:user] = User.find_by_name("suadmin")
  end

  def test_truth
    assert true
  end

// testing if reviewer can be assigned dynamically
  def test_assign_reviewer_dynamically
    assignmentid = assignments(:assignment1).id
    reviewerid = session[:user].id
    post :assign_reviewer_dynamically,{:assignment_id => assignmentid,:reviewer_id => reviewerid, :i_dont_care => true}
    assert flash[:notice], "Reviewer was successfully assigned"
  end

// testing if metareviewer can be assigned dynamically
  def test_assign_meta_reviewer_dynamically
    assignmentid = assignments(:assignment1).id
    metareviewerid = session[:user].id
    post :assign_metareviewer_dynamically,{:assignment_id => assignmentid,:metareviewer_id => metareviewerid}
    assert flash[:notice], "Metareviewer was successfully assigned"
  end

// testing if user gets added, before assigning reviewer
// then page is redirected to reviews list
  def test_add_user_to_assignment_redirected_to_review
    assignmentid = assignments(:assignment1).id
    userid = session[:user].id
    contributorid = 632487094
    post :add_user_to_assignment, { :id => assignmentid, :user_id => userid, :contributor_id => contributorid }
    assert flash[:notice],"contributor added successfully to reviewer"
  end

// testing if user gets added, before assigning metareviewer
// then page is redirected to metareviews list
  def test_add_user_to_assignment_redirected_to_meta_review
    assignmentid = 39222559
    userid = session[:user].id
    post :add_user_to_assignment, { :id => assignmentid, :user_id => userid}
    assert flash[:notice],"contributor added successfully to meta reviewer"
  end

// testing add_reviewer method
  def test_add_reviewer
    assignmentid = assignments(:assignment1).id
    userid = session[:user].id
    contributorid = 632487094
    post :add_reviewer, { :id => assignmentid, :user_id => userid, :contributor_id => contributorid }
    assert flash[:notice],"reviewer added successfully"
  end

// testing add_metareviewer method
  def test_add_metareviewer
    assignmentid = 39222559
    userid = session[:user].id
    post :add_metareviewer, { :id => assignmentid, :user_id => userid }
    assert flash[:notice],"meta reviewer added successfully"
  end

  end