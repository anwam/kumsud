import { mount } from 'svelte'
import App from './App.svelte'
import './app.css'

const app = mount(App, {
  target: document.getElementById('app'),
})

if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .register('/sw.js')
      .then((registration) => {
        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing
          if (!newWorker) {
            return
          }

          newWorker.addEventListener('statechange', () => {
            if (
              newWorker.state === 'installed'
              && navigator.serviceWorker.controller
            ) {
              console.warn('A newer app version is available. Refresh to update.')
            }
          })
        })
      })
      .catch((error) => {
        console.error('Service Worker registration failed:', error)
      })
  })
}

export default app
