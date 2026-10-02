import { Controller } from "@hotwired/stimulus"

const DEBOUNCE_MS = 300

// Submits the form owning the event target.
// - `submit`           → immediate (good for selects on `change`)
// - `submitDebounced`  → debounced (good for text inputs on `input`)
// - `clearThen`        → clears sibling inputs listed in `data-clear="id1,id2"` on the target, then submits
// Works whether the target is nested inside a <form> or linked via HTML5 form="…".
export default class extends Controller {
  initialize() {
    this.submitDebounced = this.#debounce(this.submit.bind(this), DEBOUNCE_MS)
  }

  submit(event) {
    const target = event?.target || this.element
    const form = target.form || target.closest?.("form") || this.element.closest("form")
    if (form) form.requestSubmit()
  }

  clearThen(event) {
    const ids = (event.target.dataset.clear || "")
      .split(",")
      .map(s => s.trim())
      .filter(Boolean)

    ids.forEach(id => {
      const el = document.getElementById(id)
      if (el) el.value = ""
    })

    this.submit(event)
  }

  #debounce(fn, wait) {
    let timer
    return (...args) => {
      clearTimeout(timer)
      timer = setTimeout(() => fn(...args), wait)
    }
  }
}
