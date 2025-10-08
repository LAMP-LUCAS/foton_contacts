import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { 
    checkUrl: String,
    contactId: String,
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

    const response = await fetch(this.checkUrlValue, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({
        contact_id: this.contactIdValue,
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
