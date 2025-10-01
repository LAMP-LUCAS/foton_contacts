import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="nested-form"
export default class extends Controller {
  static targets = [ "target" ]
  static values = { url: String }

  add(event) {
    event.preventDefault()

    get(this.urlValue, {
      responseKind: "turbo-stream"
    })
  }

  remove(event) {
    event.preventDefault()

    const wrapper = event.target.closest(".contact-employment-fields")
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = "none"
      wrapper.querySelector("input[name*='_destroy']").value = "1"
    }
  }
}