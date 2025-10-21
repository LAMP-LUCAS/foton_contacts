import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['tab', 'content']

  connect() {
    this.showTab(0)
  }

  switch(event) {
    event.preventDefault()
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.showTab(index)
  }

  showTab(index) {
    this.tabTargets.forEach((tab, i) => {
      tab.classList.toggle('selected', i === index)
    })
    this.contentTargets.forEach((content, i) => {
      content.style.display = i === index ? 'block' : 'none'
    })
  }
}
