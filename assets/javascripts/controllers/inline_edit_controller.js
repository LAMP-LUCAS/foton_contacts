import { Controller } from '@hotwired/stimulus'

// Handles auto-submitting a form when one of its inputs loses focus (blur).
export default class extends Controller {
  
  // The submit action is triggered by the 'blur' event on the input field.
  submit() {
    // Find the form within the controller's element and submit it.
    const form = this.element.querySelector('form');
    if (form) {
      form.requestSubmit();
    }
  }
}
