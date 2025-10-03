//= require controllers/tom_select_controller
//= require controllers/analytics_tabs_controller
//= require controllers/nested_form_controller

document.addEventListener("turbo:load", function() {
  if (!window.Stimulus) {
    console.error("Foton Contacts plugin: Stimulus not found on window object.");
    return;
  }

  const application = window.Stimulus.Application.start();
  const Controller = window.Stimulus.Controller;

  // To avoid re-registering controllers on every turbo:load, check if already registered.
  if (application.controllers.find(c => c.identifier === "form")) {
    return;
  }

  // Register HelloController
  application.register("hello", class extends Controller {
    connect() {
      // Hello world!
    }
  });

  // Register FormController
  application.register("form", class extends Controller {
    static targets = [ "submit" ];
    connect() { if (this.hasSubmitTarget) { this.submitTarget.dataset.originalText = this.submitTarget.innerHTML; } }
    disable() {
      this.submitTarget.disabled = true;
      this.submitTarget.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Salvando...`;
    }
    enable() {
      this.submitTarget.disabled = false;
      this.submitTarget.innerHTML = this.submitTarget.dataset.originalText;
    }
  });
});