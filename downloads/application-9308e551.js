document.addEventListener("turbo:load", function() {
  if (!window.Stimulus) {
    console.error("Foton Contacts plugin: Stimulus not found on window object.");
    return;
  }

  const application = window.Stimulus.Application.start();
  const Controller = window.Stimulus.Controller;

  // Register HelloController
  application.register("hello", class extends Controller {
    connect() { console.log("Hello, Stimulus!", this.element); }
  });

  // Register NestedFormController
  application.register("nested-form", class extends Controller {
    static targets = [ "target" ];
    static values = { url: String };
    connect() { console.log("Nested-form controller connected!", this.element); }
    add(event) {
      event.preventDefault();
      fetch(this.urlValue, { headers: { "Accept": "text/vnd.turbo-stream.html" } })
        .then(r => r.text())
        .then(html => window.Turbo.renderStreamMessage(html));
    }
    remove(event) {
      event.preventDefault();
      const wrapper = event.target.closest(".contact-employment-fields");
      if (wrapper.dataset.newRecord === "true") {
        wrapper.remove();
      } else {
        wrapper.style.display = "none";
        wrapper.querySelector("input[name*='_destroy']").value = "1";
      }
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
