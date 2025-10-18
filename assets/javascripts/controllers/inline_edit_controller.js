window.InlineEditController = class extends window.Stimulus.Controller {
  submit() {
    const form = this.element.querySelector('form');
    if (form) {
      form.requestSubmit();
    }
  }
}