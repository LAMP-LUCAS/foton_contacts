// Connects to data-controller="show-tabs"
(function() {
  const interval = setInterval(() => {
    if (window.Stimulus) {
      clearInterval(interval);

      const application = window.Stimulus.Application.start(); // Corrected line
      const Controller = window.Stimulus.Controller;

      if (application.controllers.find(c => c.identifier === "show-tabs")) {
        return;
      }

      application.register("show-tabs", class extends Controller {
        static targets = ["tab", "content"];

        connect() {
          // Find the initially selected tab based on URL parameter or default to the first tab
          const urlParams = new URLSearchParams(window.location.search);
          let activeTabName = urlParams.get('tab');
          
          let activeTabLink;

          if (activeTabName) {
            activeTabLink = this.tabTargets.find(tab => tab.dataset.tabName === activeTabName);
          }

          // If no tab parameter or matching tab found, default to the first tab
          if (!activeTabLink && this.tabTargets.length > 0) {
            activeTabLink = this.tabTargets[0];
            activeTabName = activeTabLink.dataset.tabName; // Ensure activeTabName is set for the default
          }
          
          if (activeTabLink) {
            this.showTab({ target: activeTabLink });
          }
        }

        showTab(event) {
          event.preventDefault();
          const clickedTab = event.target;
          const tabName = clickedTab.dataset.tabName;

          // Update URL without full page reload
          const url = new URL(window.location.href);
          url.searchParams.set('tab', tabName);
          window.history.pushState({}, '', url);

          // Remove 'selected' class from all tab links
          this.tabTargets.forEach(tab => {
            tab.classList.remove("selected");
          });
          // Remove 'selected' class from all tab content
          this.contentTargets.forEach(content => {
            content.classList.remove("selected");
          });

          // Add 'selected' class to the clicked tab link
          clickedTab.classList.add("selected");
          // Add 'selected' class to the corresponding tab content
          this.contentTargets.find(content => content.dataset.tabName === tabName).classList.add("selected");
        }
      });
    }
  }, 50);
})();