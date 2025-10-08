module FotonContactsLinkHelper
  # Overrides the default link_to helper to enforce a specific navigation behavior for the plugin.
  # By default, all standard navigation links are set to trigger a full page reload (data-turbo="false").
  # This ensures a consistent and predictable UX, avoiding Turbo Drive issues when navigating between
  # different full-page contexts within the plugin or to external Redmine pages.
  #
  # Links that are explicitly meant to use Turbo features (like opening modals with turbo_frame or
  # performing actions with turbo_method) are ignored by this helper, preserving their rich interactivity.
  def link_to(name = nil, options = nil, html_options = nil, &block)
    if block_given?
      html_options = options
      options = name
      name = block
    end
    html_options ||= {}

    # Check if the link is already configured for a specific Turbo action.
    is_turbo_managed = html_options.dig(:data)&.keys&.any? { |k| k.to_s.start_with?('turbo') }

    # If it's a standard navigation link, disable Turbo Drive by default.
    unless is_turbo_managed
      html_options.deep_merge!(data: { turbo: false })
    end

    # Call the original link_to with the modified options.
    super(name, options, html_options, &block)
  end
end
