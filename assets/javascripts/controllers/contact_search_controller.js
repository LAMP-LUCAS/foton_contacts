// assets/javascripts/controllers/contact_search_controller.js
(function() {
  const interval = setInterval(() => {
    if (window.Stimulus) {
      clearInterval(interval);

      const application = window.Stimulus.Application.getApplications()[0] || window.Stimulus.Application.start();
      const Controller = window.Stimulus.Controller;

      if (application.controllers.find(c => c.identifier === "contact-search")) {
        return;
      }

      application.register("contact-search", class extends Controller {
        initialize() {
          this.search = this.debounce(this.search.bind(this), 300);
        }

        search() {
          this.element.form.requestSubmit();
        }

        debounce(func, wait) {
          let timeout;
          return function(...args) {
            const context = this;
            clearTimeout(timeout);
            timeout = setTimeout(() => func.apply(context, args), wait);
          };
        }
      });
    }
  }, 50);
})();
