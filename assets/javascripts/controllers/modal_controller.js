// Connects to data-controller="modal"
(function() {
  const interval = setInterval(() => {
    if (window.Stimulus) {
      clearInterval(interval);

      const application = window.Stimulus.Application.start();
      const Controller = window.Stimulus.Controller;

      if (application.controllers.find(c => c.identifier === "modal")) {
        return;
      }

      application.register("modal", class extends Controller {
        static values = {
          historyAction: { type: String, default: "none" } // 'back', 'replace', 'none'
        }

        connect() {
          document.body.classList.add("modal-open");
          // Store the URL of the page *before* the modal was opened
          // This is the URL we want to revert to if historyAction is 'replace'
          this.originalUrl = document.referrer || window.location.href;
        }

        disconnect() {
          document.body.classList.remove("modal-open");
          
          if (this.historyActionValue === "back") {
            window.history.back();
          } else if (this.historyActionValue === "replace") {
            // Replace the current history entry with the original URL
            window.history.replaceState({}, "", this.originalUrl);
          }
          // If historyActionValue is 'none' (default), do nothing to history
        }

        closeAndGoBack() {
          // This action is triggered by the close button/cancel link
          // It will remove the turbo-frame, and then disconnect() will handle history
          this.element.remove();
        }
      });
    }
  }, 50);
})();