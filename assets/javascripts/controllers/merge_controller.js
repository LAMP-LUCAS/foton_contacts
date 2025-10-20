window.MergeController = class extends Stimulus.Controller {
  connect() {
    this.autoSelectRecommended();
    this.updateSubmitButtonState();
  }

  autoSelectRecommended() {
    const conflictFields = this.element.querySelectorAll('.conflict-field');
    conflictFields.forEach(field => {
      const recommendedOption = field.querySelector('.source-option.recommended');
      if (recommendedOption) {
        const radio = recommendedOption.querySelector('input[type=radio]');
        if (radio && !radio.checked) {
          recommendedOption.click();
        }
      }
      const checkboxes = field.querySelectorAll('input[type=checkbox]');
      checkboxes.forEach(cb => {
        if (cb.checked) {
          cb.closest('.source-option').classList.add('selected');
        }
      });
    });
  }

  select(event) {
    const selectedOption = event.currentTarget;
    const conflictField = selectedOption.closest('.conflict-field');
    const options = conflictField.querySelectorAll('.source-option');

    options.forEach(opt => opt.classList.remove('selected'));
    selectedOption.classList.add('selected');

    selectedOption.querySelector('input[type=radio]').checked = true;
    this.updateSubmitButtonState();
  }

  toggleCheckbox(event) {
    const selectedOption = event.currentTarget;
    selectedOption.classList.toggle('selected');
    const checkbox = selectedOption.querySelector('input[type=checkbox]');
    checkbox.checked = !checkbox.checked;
    this.updateSubmitButtonState();
  }

  updateSubmitButtonState() {
    const submitButton = this.element.querySelector('input[type=submit]');
    if (submitButton) {
      submitButton.disabled = false;
    }
  }
};