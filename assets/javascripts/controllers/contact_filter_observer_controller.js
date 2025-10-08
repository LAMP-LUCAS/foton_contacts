import { Controller } from '@hotwired/stimulus'

// Observes a form and updates a Turbo Frame with the form's query parameters.
export default class extends Controller {
  static targets = ["frame"]
  static values = { baseUrl: String }

  connect() {
    this.element.addEventListener("submit", this.updateFrame.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("submit", this.updateFrame.bind(this))
  }

  updateFrame(event) {
    event.preventDefault()
    const params = new URLSearchParams(new FormData(this.element))
    const frame = this.frameTarget
    frame.src = `${this.baseUrlValue}?${params.toString()}`
  }
}
