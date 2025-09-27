require File.expand_path('../../test_helper', __FILE__)

class ContactsTest < ActionDispatch::IntegrationTest
  include FotonContacts::TestHelper
  
  def setup
    setup_contact_test
  end
  
  def test_full_contact_workflow
    log_user('contact_user', 'contact_user')
    
    # Acessar a listagem de contatos
    get '/contacts'
    assert_response :success
    assert_select 'h2', text: 'Contatos'

    # Criar uma nova pessoa
    get '/contacts/new'
    assert_response :success
    
    post '/contacts', params: {
      contact: {
        name: 'Integration Test Person',
        contact_type: 'person',
        email: 'test@integration.com',
        status: 'active'
      }
    }
    follow_redirect!
    assert_response :success
    
    person = Contact.last
    assert_equal 'Integration Test Person', person.name

    # Verificar se o link para o perfil existe na listagem
    get '/contacts'
    assert_response :success
    assert_select "a[href=?]", "/contacts/#{person.id}", text: 'Integration Test Person'
    
    # Acessar a página de perfil da pessoa
    get "/contacts/#{person.id}"
    assert_response :success
    assert_select 'h2', text: 'Integration Test Person'

    # Criar uma nova empresa
    post '/contacts', params: {
      contact: {
        name: 'Integration Test Company',
        contact_type: 'company',
        status: 'active'
      }
    }
    follow_redirect!
    assert_response :success
    
    company = Contact.last
    assert_equal 'Integration Test Company', company.name
    
    # Vincular pessoa à empresa
    put "/contacts/#{person.id}", params: {
      contact: {
        employments_as_person_attributes: {
          '0' => {
            company_id: company.id,
            position: 'Integration Tester'
          }
        }
      }
    }
    follow_redirect!
    assert_response :success
    
    # Verificar vínculo
    person.reload
    assert_equal 1, person.employments_as_person.count
    assert_equal 'Integration Tester', person.employments_as_person.first.position
    assert_select 'td', text: 'Integration Test Company'
    assert_select 'td', text: 'Integration Tester'
    
    # Criar um grupo
    post '/contact_groups', params: {
      contact_group: {
        name: 'Integration Test Group',
        description: 'Group for integration testing'
      }
    }
    follow_redirect!
    assert_response :success
    
    group = ContactGroup.last
    assert_equal 'Integration Test Group', group.name
    
    # Adicionar pessoa ao grupo
    post "/contact_groups/#{group.id}/add_member", params: {
      membership: {
        contact_id: person.id,
        role: 'Tester'
      }
    }
    assert_response :redirect
    
    # Verificar membro do grupo
    get "/contact_groups/#{group.id}"
    assert_response :success
    assert_select 'ul.contacts li', text: /Integration Test Person/
    
    # Criar uma tarefa e vincular o contato
    issue = Issue.generate!(project: @project)
    
    post '/contact_issue_links', params: {
      contact_issue_link: {
        contact_id: person.id,
        issue_id: issue.id,
        role: 'Responsible'
      }
    }
    assert_response :redirect
    
    # Verificar tarefa vinculada
    get "/contacts/#{person.id}"
    assert_response :success
    assert_select 'div#tab-issues td.subject', text: /#{issue.subject}/
    
    # Atualizar contato
    put "/contacts/#{person.id}", params: {
      contact: {
        name: 'Updated Integration Test Person'
      }
    }
    follow_redirect!
    assert_response :success
    
    # Verificar atualização
    person.reload
    assert_equal 'Updated Integration Test Person', person.name
    
    # Excluir contato
    delete "/contacts/#{person.id}"
    follow_redirect!
    assert_response :success
    
    assert_raises(ActiveRecord::RecordNotFound) do
      Contact.find(person.id)
    end
  end
end