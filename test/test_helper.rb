require File.expand_path('../../test_helper', __FILE__)

module FotonContacts
  module TestHelper
    def setup_contact_test
      @user = User.generate!(login: 'contact_user')
      @project = Project.generate!
      @role = Role.generate!(name: 'Contact Manager')
      @role.add_permission!(:manage_contacts)
      Member.create!(user: @user, project: @project, roles: [@role])
      
      User.current = @user
    end
    
    def create_contact(attributes = {})
      Contact.create!({
        name: 'Test Contact',
        contact_type: 'person',
        status: 'active',
        author: User.current
      }.merge(attributes))
    end
    
    def create_company(attributes = {})
      Contact.create!({
        name: 'Test Company',
        contact_type: 'company',
        status: 'active',
        author: User.current
      }.merge(attributes))
    end
    
    def create_contact_group(attributes = {})
      ContactGroup.create!({
        name: 'Test Group',
        author: User.current
      }.merge(attributes))
    end
  end
end