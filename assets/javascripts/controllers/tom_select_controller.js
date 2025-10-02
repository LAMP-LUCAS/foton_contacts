// Connects to data-controller="tom-select"
// Assumes TomSelect is loaded globally via a <script> tag
(function() {
  // Wait for both Stimulus and TomSelect to be available
  const interval = setInterval(() => {
    if (window.Stimulus && window.TomSelect) {
      clearInterval(interval);

      const application = window.Stimulus.Application.getApplications()[0] || window.Stimulus.Application.start();
      const Controller = window.Stimulus.Controller;

      // Avoid re-registering the controller
      if (application.controllers.find(c => c.identifier === "tom-select")) {
        return;
      }

      application.register("tom-select", class extends Controller {
        static values = {
          options: { type: Object, default: {} },
          plugins: { type: Array, default: [] },
          create: { type: Boolean, default: false },
        }

        connect() {
          if (!window.TomSelect) {
            console.error("TomSelect not found on window object");
            return;
          }
          this.select = new window.TomSelect(this.element, this.config);
        }

        disconnect() {
          if (this.select) {
            this.select.destroy();
          }
        }

        get config() {
          const baseConfig = {
            plugins: this.pluginsValue,
            create: this.createValue,
          };

          return { ...baseConfig, ...this.optionsValue };
        }
      });
    }
  }, 50); // Check every 50ms
})();