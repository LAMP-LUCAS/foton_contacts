//= require chartkick

//= require controllers/contact_search_controller
//= require controllers/tom_select_controller
//= require controllers/analytics_tabs_controller
//= require controllers/nested_form_controller
//= require controllers/modal_controller
//= require controllers/show_tabs_controller
//= require controllers/inline_edit_controller

document.addEventListener("turbo:load", function() {
  if (!window.Stimulus) {
    console.error("Foton Contacts plugin: Stimulus not found on window object.");
    return;
  }

  // Start the Stimulus application if it hasn't been started yet.
  const application = window.Stimulus.Application.start();

  // Register controllers from the window object
  // This pattern is used for compatibility with how Redmine loads plugin assets.
  if (window.ContactSearchController && !application.router.modulesByIdentifier.has("contact-search")) {
    application.register("contact-search", window.ContactSearchController);
  }
  if (window.TomSelectController && !application.router.modulesByIdentifier.has("tom-select")) {
    application.register("tom-select", window.TomSelectController);
  }
  if (window.AnalyticsTabsController && !application.router.modulesByIdentifier.has("analytics-tabs")) {
    application.register("analytics-tabs", window.AnalyticsTabsController);
  }
  if (window.NestedFormController && !application.router.modulesByIdentifier.has("nested-form")) {
    application.register("nested-form", window.NestedFormController);
  }
  if (window.ModalController && !application.router.modulesByIdentifier.has("modal")) {
    application.register("modal", window.ModalController);
  }
  if (window.ShowTabsController && !application.router.modulesByIdentifier.has("show-tabs")) {
    application.register("show-tabs", window.ShowTabsController);
  }
  if (window.WorkloadAlertController && !application.router.modulesByIdentifier.has("workload-alert")) {
    application.register("workload-alert", window.WorkloadAlertController);
  }
});
