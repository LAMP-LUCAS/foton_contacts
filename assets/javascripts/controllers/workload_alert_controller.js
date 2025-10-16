import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="workload-alert"
export default class extends Controller {
  static values = {
    checkUrl: String
  }

  // Flag to prevent infinite loop on re-submission
  isSubmittingAfterCheck = false

  check(event) {
    // If this is the programmatic re-submission, let it go through
    if (this.isSubmittingAfterCheck) {
      return;
    }

    // Stop the original submission to perform the async check
    event.preventDefault();

    const form = this.element;
    const contactId = form.querySelector("input[name='contact_id']").value;

    const issueStartDate = document.getElementById('issue_start_date')?.value;
    const issueDueDate = document.getElementById('issue_due_date')?.value;
    const issueEstimatedHours = document.getElementById('issue_estimated_hours')?.value;

    // If dates are not present, we cannot check. Submit the form to be handled by Turbo.
    if (!issueStartDate || !issueDueDate) {
      this.submitForm(form);
      return;
    }

    const formData = new FormData();
    formData.append('contact_id', contactId);
    formData.append('start_date', issueStartDate);
    formData.append('due_date', issueDueDate);
    formData.append('estimated_hours', issueEstimatedHours || '0');

    const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

    fetch(this.checkUrlValue, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': csrfToken,
        'Accept': 'application/json'
      },
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'overload') {
        if (window.confirm(data.message)) {
          this.submitForm(form);
        }
      } else {
        this.submitForm(form);
      }
    })
    .catch(error => {
      console.error('Error checking workload:', error);
      // In case of error, submit the form to not block the user
      this.submitForm(form);
    });
  }

  submitForm(form) {
    this.isSubmittingAfterCheck = true;
    // Use requestSubmit() to re-trigger the submit event, which Turbo will intercept
    form.requestSubmit();
  }
}