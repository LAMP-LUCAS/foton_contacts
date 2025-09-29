import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  static targets = [ "submit" ]

  disable() {
    this.submitTarget.disabled = true;
    this.submitTarget.innerHTML = `
      <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
      Salvando...
    `;
  }

  enable() {
    this.submitTarget.disabled = false;
    this.submitTarget.innerHTML = this.submitTarget.dataset.originalText;
  }

  connect() {
    if (this.hasSubmitTarget) {
      this.submitTarget.dataset.originalText = this.submitTarget.innerHTML;
    }
  }
}
