module ContactsHelper
  def options_for_company_contact(options = {})
    company_scope = Contact.companies.order(:name)
    options_array = company_scope.map { |c| [c.name, c.id] }
    options_for_select(options_array, options[:selected])
  end
end