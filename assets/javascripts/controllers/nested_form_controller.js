(function() {
  const interval = setInterval(() => {
    if (window.Stimulus) {
      clearInterval(interval);

      const application = window.Stimulus.Application.getApplications()[0] || window.Stimulus.Application.start();
      const Controller = window.Stimulus.Controller;

      // Avoid re-registering the controller
      if (application.controllers.find(c => c.identifier === "nested-form")) {
        return;
      }

      application.register("nested-form", class extends Controller {
        remove(event) {
          event.preventDefault();

          let wrapper = event.target.closest(".contact-employment-fields");

          // If the record is persisted, mark it for destruction
          if (wrapper.dataset.newRecord === 'false') {
            wrapper.style.display = 'none';
            let destroyInput = wrapper.querySelector("input[name*='_destroy']");
            if (destroyInput) {
              destroyInput.value = '1';
            }
          } else {
            // If the record is new, just remove it from the DOM
            wrapper.remove();
          }
        }
      });
    }
  }, 50);
})();