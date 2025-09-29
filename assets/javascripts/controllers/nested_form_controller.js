import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="nested-form"
export default class extends Controller {
  static targets = [ "template", "target", "fields" ]

  add(event) {
    event.preventDefault()

    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.targetTarget.insertAdjacentHTML("beforeend", content)
    const newFields = this.targetTarget.lastElementChild
    newFields.scrollIntoView({ behavior: "smooth", block: "center" })
    newFields.querySelector("input, select, textarea").focus()
  }

  remove(event) {
    event.preventDefault()

    const wrapper = event.target.closest("[data-nested-form-target='fields']")
    if (wrapper.dataset.newRecord === "true") {
      wrapper.remove()
    } else {
      wrapper.style.display = "none"
      wrapper.querySelector("input[name*='_destroy']").value = "1"
    }
  }
}