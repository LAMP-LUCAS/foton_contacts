import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="workload-alert"
export default class extends Controller {
  static values = {
    checkUrl: String,
    confirmMessage: String
  }

  check(event) {
    event.preventDefault();
    const form = this.element;
    const contactId = form.querySelector("input[name='contact_id']").value;

    // Get issue attributes from the main form
    const issueStartDate = document.getElementById('issue_start_date')?.value;
    const issueDueDate = document.getElementById('issue_due_date')?.value;
    const issueEstimatedHours = document.getElementById('issue_estimated_hours')?.value;

    // If dates are not present, we cannot check. Submit the form directly.
    if (!issueStartDate || !issueDueDate) {
      form.submit();
      return;
    }

    const formData = new FormData();
    formData.append('contact_id', contactId);
    formData.append('start_date', issueStartDate);
    formData.append('due_date', issueDueDate);
    formData.append('estimated_hours', issueEstimatedHours || '0');

    // Get CSRF token
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
          form.submit();
        }
      } else {
        form.submit();
      }
    })
    .catch(error => {
      console.error('Error checking workload:', error);
      // In case of error, submit the form to not block the user
      form.submit();
    });
  }
}