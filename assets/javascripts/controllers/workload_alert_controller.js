(function() {
  class WorkloadAlertController extends Stimulus.Controller {
    static values = { 
      checkUrl: String,
      startDate: String,
      dueDate: String,
      estimatedHours: String
    }

    async connect() {
      this.element.addEventListener("submit", this.check.bind(this), { capture: true })
    }

    async check(event) {
      if (this.element.dataset.workloadChecked) return

      event.preventDefault()
      event.stopImmediatePropagation()

      const contactIdField = this.element.querySelector('select[name="contact_id"], input[name="contact_id"]');
      const contactId = contactIdField ? contactIdField.value : null;

      if (!contactId) {
        console.error("WorkloadAlertController: Contact ID field not found or is empty.");
        this.submitForm();
        return;
      }

      const response = await fetch(this.checkUrlValue, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
        },
        body: JSON.stringify({
          contact_id: contactId,
          start_date: this.startDateValue,
          due_date: this.dueDateValue,
          estimated_hours: this.estimatedHoursValue
        })
      })

      const data = await response.json()

      if (data.status === 'overload') {
        if (confirm(data.message)) {
          this.submitForm()
        }
      } else {
        this.submitForm()
      }
    }

    submitForm() {
      this.element.dataset.workloadChecked = "true"
      this.element.requestSubmit()
    }
  }

  window.WorkloadAlertController = WorkloadAlertController;
})();
