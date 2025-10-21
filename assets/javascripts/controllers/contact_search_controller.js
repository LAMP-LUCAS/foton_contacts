// assets/javascripts/controllers/contact_search_controller.js
window.ContactSearchController = class extends window.Stimulus.Controller {
  static targets = [ "resultsFrame" ];

  initialize() {
    this.search = this.debounce(this.search.bind(this), 300);
  }

  search() {
    const form = this.element.form;
    if (!form) { return; }
    const url = new URL(form.action);
    const params = new URLSearchParams(new FormData(form));
    url.search = params.toString();

    this.resultsFrameTarget.src = url;
  }

  handleKeydown(event) {
    if (event.key === "Enter") {
      event.preventDefault();
    }
  }

  debounce(func, wait) {
    let timeout;
    return function(...args) {
      const context = this;
      clearTimeout(timeout);
      timeout = setTimeout(() => func.apply(context, args), wait);
    };
  }
};