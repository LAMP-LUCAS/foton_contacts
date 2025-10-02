// Connects to data-controller="analytics-tabs"
(function() {
  const interval = setInterval(() => {
    if (window.Stimulus) {
      clearInterval(interval);

      const application = window.Stimulus.Application.getApplications()[0] || window.Stimulus.Application.start();
      const Controller = window.Stimulus.Controller;

      if (application.controllers.find(c => c.identifier === "analytics-tabs")) {
        return;
      }

      application.register("analytics-tabs", class extends Controller {
        static targets = ["tab", "content"];

        connect() {
          this.showTab(this.tabTargets[0]); // Show the first tab by default
        }

        showTab(event) {
          let clickedTab;
          if (event instanceof HTMLElement) { // If called directly with an element
            clickedTab = event;
          } else { // If called from a click event
            event.preventDefault();
            clickedTab = event.target;
          }

          const tabId = clickedTab.getAttribute("href").replace("#", "");

          this.tabTargets.forEach(tab => {
            tab.classList.remove("selected");
          });
          this.contentTargets.forEach(content => {
            content.style.display = "none";
          });

          clickedTab.classList.add("selected");
          this.contentTargets.find(content => content.id === tabId).style.display = "block";
        }
      });
    }
  }, 50);
})();