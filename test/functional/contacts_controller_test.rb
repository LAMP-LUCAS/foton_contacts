require File.expand_path('../../test_helper', __FILE__)

class ContactsControllerTest < ActionController::TestCase
  include FotonContacts::TestHelper
  
  def setup
    setup_contact_test
    @request.session[:user_id] = @user.id
  end
  
  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:contacts)
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_select 'input[name=?]', 'contact[name]'
  end
  
  def test_create_person
    assert_difference 'Contact.count' do
      post :create, params: {
        contact: {
          name: 'New Person',
          contact_type: 'person',
          email: 'person@test.com',
          status: 'active'
        }
      }
    end
    
    assert_redirected_to contact_path(assigns(:contact))
    assert_equal 'person', assigns(:contact).contact_type
  end
  
  def test_create_company
    assert_difference 'Contact.count' do
      post :create, params: {
        contact: {
          name: 'New Company',
          contact_type: 'company',
          email: 'company@test.com',
          status: 'active'
        }
      }
    end
    
    assert_redirected_to contact_path(assigns(:contact))
    assert_equal 'company', assigns(:contact).contact_type
  end
  
  def test_show
    contact = create_contact
    get :show, params: { id: contact.id }
    assert_response :success
    assert_template 'show'
  end
  
  def test_edit
    contact = create_contact
    get :edit, params: { id: contact.id }
    assert_response :success
    assert_template 'edit'
  end
  
  def test_update
    contact = create_contact
    put :update, params: {
      id: contact.id,
      contact: { name: 'Updated Name' }
    }
    
    assert_redirected_to contact_path(assigns(:contact))
    assert_equal 'Updated Name', assigns(:contact).name
  end
  
  def test_destroy
    contact = create_contact
    assert_difference 'Contact.count', -1 do
      delete :destroy, params: { id: contact.id }
    end
    
    assert_redirected_to contacts_path
  end
  
  def test_unauthorized_access
    User.current = nil
    @request.session[:user_id] = nil
    
    get :index
    assert_response :redirect
    assert_redirected_to '/login'
  end
  
  def test_search
    contact1 = create_contact(name: 'John Doe')
    contact2 = create_contact(name: 'Jane Smith')
    
    get :search, params: { q: 'john' }, format: :json
    assert_response :success
    
    json = JSON.parse(@response.body)
    assert_equal 1, json.size
    assert_equal contact1.name, json.first['text']
  end
  
  def test_export
    create_contact(name: 'Export Test')
    
    get :index, format: :csv
    assert_response :success
    assert_equal 'text/csv', @response.content_type
  end
end