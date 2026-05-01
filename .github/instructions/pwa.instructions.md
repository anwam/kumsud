---
description: "Use when implementing Progressive Web App features. Covers service worker implementation, web app manifest, installability, caching strategies, offline support, and PWA-specific performance optimization for kumsud."
applyTo: "**/manifest.json, **/service-worker.js, **/sw.js, src/main.js, index.html"
---

# PWA Implementation Guidelines

kumsud is designed as a progressive web app (PWA) that works offline and can be installed on users' home screens. These guidelines ensure consistent PWA patterns across the project.

## Asset Organization

### Icons & Branding
- **Service icons**: `public/pwa-64x64.png`, `public/pwa-192x192.png`, `public/pwa-512x512.png`
  - Used in manifest and install prompts
  - Must be PNG, fully opaque (no alpha channel)
- **Maskable icon**: `public/maskable-icon-512x512.png`
  - Safe zone: center 80% of image (mask-safe area); background pixels (outer 20%) may be clipped
  - Used by OS for adaptive icons on Android
- **Apple touch icon**: `public/apple-touch-icon-180x180.png`
  - iOS app icon (home screen, task switcher)
  - 180×180 PNG, no transparency
- **Favicon**: `public/favicon.ico` or `.svg`
  - Browser tab icon; referenced in `index.html`

### Icon Generation
If updating branding:
```bash
# All icons must be regenerated from source
# Use tools like: https://realfavicongenerator.net/ or similar
# Verify:
# 1. All sizes generated (64, 192, 512 for PWA; 180 for Apple)
# 2. Maskable icon has safe zone (center 80%)
# 3. All PNGs are RGB mode, no transparency
```

## Web App Manifest

Create `public/manifest.json`:
```json
{
  "name": "Kum Sud - คุ้มสุด",
  "short_name": "Kum Sud",
  "description": "Calculate price-per-unit across products to find the best value",
  "lang": "th",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "orientation": "portrait-primary",
  "background_color": "#ffffff",
  "theme_color": "#ffffff",
  "categories": ["shopping", "utilities"],
  "icons": [
    {
      "src": "/pwa-64x64.png",
      "sizes": "64x64",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/pwa-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/pwa-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any"
    },
    {
      "src": "/maskable-icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshot-1x.png",
      "sizes": "540x720",
      "type": "image/png",
      "form_factor": "narrow"
    },
    {
      "src": "/screenshot-2x.png",
      "sizes": "1080x1440",
      "type": "image/png",
      "form_factor": "narrow"
    }
  ],
  "shortcuts": [
    {
      "name": "Add Product",
      "description": "Quickly add a new product to compare",
      "url": "/?action=add",
      "icons": [
        {
          "src": "/pwa-192x192.png",
          "sizes": "192x192"
        }
      ]
    }
  ]
}
```

### Manifest Requirements
- **`name`**: Full app name in target language (Thai)
- **`short_name`**: ≤12 characters for OS app drawer display
- **`start_url`**: Always `"/"` for single-page app
- **`display`**: Use `"standalone"` to hide browser UI
- **`scope`**: Defines which URLs the PWA controls; `"/"` for full site
- **`orientation`**: `"portrait-primary"` for mobile-first app
- **`theme_color`**: CSS color for browser chrome (matches app UI)
- **`background_color`**: CSS color shown while app loads
- **`icons`**: Must include `purpose: "any"` (regular) and `"maskable"` (adaptive)
  - All PNGs must exist in `public/` and be valid
  - Sizes must be exact (64, 192, 512 for `purpose: any`; 512 for maskable)

### Link Manifest in `index.html`
```html
<head>
  <link rel="manifest" href="/manifest.json" />
  <meta name="theme-color" content="#ffffff" />
  <meta name="description" content="Calculate price-per-unit across products to find the best value" />
</head>
```

## Service Worker

### File Location & Registration

Place service worker at `public/sw.js` (root of site) to maximize scope.

Register in `src/main.js`:
```javascript
// src/main.js
import App from './App.svelte'

const app = mount(App, { target: document.getElementById('app') })

// Register service worker
if ('serviceWorker' in navigator) {
  navigator.serviceWorker
    .register('/sw.js')
    .then((registration) => {
      console.log('✓ Service Worker registered', registration)
    })
    .catch((error) => {
      console.error('✗ Service Worker registration failed:', error)
    })
}

export default app
```

### Service Worker Template

`public/sw.js`:
```javascript
// Service Worker — offline support & caching strategy

const CACHE_NAME = 'kumsud-v1'
const ASSETS_TO_CACHE = [
  '/',
  '/index.html',
  '/manifest.json',
  '/apple-touch-icon-180x180.png',
  '/maskable-icon-512x512.png',
  '/pwa-64x64.png',
  '/pwa-192x192.png',
  '/pwa-512x512.png',
  '/favicon.ico',
  '/robots.txt'
]

// Install: Pre-cache essential assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE)
    })
  )
  self.skipWaiting() // Activate immediately
})

// Activate: Clean old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName)
          }
        })
      )
    })
  )
  self.clients.claim() // Control all pages immediately
})

// Fetch: Network-first, fall back to cache (for index.html & assets)
self.addEventListener('fetch', (event) => {
  const { request } = event
  const url = new URL(request.url)

  // Only cache GET requests
  if (request.method !== 'GET') {
    return
  }

  // Network-first for HTML (to get latest app code)
  if (request.destination === 'document' || url.pathname === '/') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          if (response.ok) {
            return caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, response.clone())
              return response
            })
          }
          return response
        })
        .catch(() => caches.match(request))
    )
    return
  }

  // Cache-first for assets (JS, CSS, images)
  event.respondWith(
    caches.match(request).then((cached) => {
      if (cached) {
        return cached
      }
      return fetch(request)
        .then((response) => {
          if (response.ok && (
            request.destination === 'style'
            || request.destination === 'script'
            || request.destination === 'image'
          )) {
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(request, response.clone())
            })
          }
          return response
        })
        .catch(() => {
          // Return offline fallback if needed
          // For now, let requests fail (browser handles gracefully)
        })
    })
  )
})

// Handle messages from clients
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting()
  }
})
```

### Caching Strategy Explanation

- **Network-first for HTML**: Fetches from network first; falls back to cache on failure. Ensures users get latest app code; works offline if previously visited.
- **Cache-first for assets**: Checks cache first; fetches from network if missing. Fast loads; new assets require cache invalidation (version bump in `CACHE_NAME`).
- **Version cache via `CACHE_NAME`**: Increment version (e.g., `kumsud-v2`, `kumsud-v3`) when deploying updates. Old cache is cleaned on next SW activation.

## Install Prompt & Installability Detection

### Check Installability in `App.svelte`

```svelte
<script>
  let deferredPrompt = $state(null)
  let canInstall = $state(false)

  $effect(() => {
    const handleBeforeInstallPrompt = (e) => {
      e.preventDefault()
      deferredPrompt = e
      canInstall = true
    }

    const handleAppInstalled = () => {
      console.log('✓ App installed to home screen')
      canInstall = false
      deferredPrompt = null
    }

    window.addEventListener('beforeinstallprompt', handleBeforeInstallPrompt)
    window.addEventListener('appinstalled', handleAppInstalled)

    return () => {
      window.removeEventListener('beforeinstallprompt', handleBeforeInstallPrompt)
      window.removeEventListener('appinstalled', handleAppInstalled)
    }
  })

  const handleInstall = async () => {
    if (!deferredPrompt) return
    deferredPrompt.prompt()
    const { outcome } = await deferredPrompt.userChoice
    console.log(`User response: ${outcome}`)
    canInstall = false
    deferredPrompt = null
  }
</script>

{#if canInstall}
  <button onclick={handleInstall}>Add to Home Screen</button>
{/if}
```

### Installability Checklist

The app is installable when:
- [ ] HTTPS (or localhost for dev)
- [ ] Valid `manifest.json` linked in `<head>`
- [ ] Service Worker registered and functional
- [ ] At least 192×192 icon in manifest with valid PNG
- [ ] `display: "standalone"` in manifest
- [ ] `start_url` defined in manifest
- [ ] No existing window controls detected (app not already installed)

Chrome DevTools: **Application > Manifest** shows warnings if any criteria fail.

## Updating & Versioning

### Bump Version When Deploying

1. Update `package.json`:
   ```json
   "version": "1.0.2"
   ```

2. Increment cache name in `public/sw.js`:
   ```javascript
   const CACHE_NAME = 'kumsud-v2' // was v1
   ```

3. Update assets in `ASSETS_TO_CACHE` if new files added:
   ```javascript
   const ASSETS_TO_CACHE = [
     '/',
     '/index.html',
     // Add new files here
   ]
   ```

4. Run release:
   ```bash
   pnpm release  # generates CHANGELOG, tags commit
   ```

5. Deployed users' service workers will automatically clean old cache on next activation.

### Prompt User to Update (Optional)

Detect when a new SW version is ready:
```javascript
// src/main.js
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js').then((registration) => {
    registration.addEventListener('updatefound', () => {
      const newWorker = registration.installing
      newWorker.addEventListener('statechange', () => {
        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
          // New version available; show toast/banner
          console.log('Update available. Refresh or restart to update.')
        }
      })
    })
  })
}
```

## Testing PWA Locally

### DevTools Checklist

1. **Service Worker**:
   - Open: DevTools > **Application > Service Workers**
   - Status: "activated and running"
   - Scope: matches `start_url`

2. **Manifest**:
   - DevTools > **Application > Manifest**
   - No warnings; all fields present
   - Icons load without errors

3. **Offline**:
   - DevTools > **Network** tab
   - Check "Offline" checkbox
   - Reload page; should load from cache

4. **Cache Storage**:
   - DevTools > **Application > Cache Storage**
   - Verify `kumsud-v1` (or current version) exists
   - Inspect cached resources

### Install Simulation (Chrome)
- DevTools > **Application > Manifest**
- Click **"Install"** button to simulate A2HS

### Testing on Real Device
- Deploy to HTTPS
- Visit app on phone/tablet
- Tap menu > "Install" or "Add to Home Screen"
- Launch installed app; should load offline after first visit

## Performance & Bundling

### Vite PWA Plugin (Optional)

For advanced PWA features, install `vite-plugin-pwa`:
```bash
pnpm add -D vite-plugin-pwa
```

Update `vite.config.js`:
```javascript
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import tailwindcss from '@tailwindcss/vite'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({
  plugins: [
    tailwindcss(),
    svelte(),
    VitePWA({
      registerType: 'autoUpdate',
      manifest: {
        // Generated automatically from public/manifest.json
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/your-api\.example\.com\//,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              expiration: { maxEntries: 50, maxAgeSeconds: 300 }
            }
          }
        ]
      }
    })
  ]
})
```

However, for kumsud's simplicity, manual SW management is preferred.

### Asset Optimization

- **Code splitting**: Vite auto-splits; no action needed
- **CSS**: Tailwind + Vite purge; unused styles removed
- **Icons**: All PNG icons compressed; use `imagemin` if needed:
  ```bash
  pnpm add -D imagemin imagemin-mozjpeg imagemin-pngquant
  ```
- **Bundle analysis**:
  ```bash
  pnpm build
  # Check dist/ size; target <500KB gzipped for fast load on 3G
  ```

## Troubleshooting

### App Not Installing
- **Issue**: Installability check fails
- **Solution**:
  1. Verify HTTPS or localhost
  2. Check manifest.json is valid JSON (no trailing commas)
  3. Ensure all icons exist in `public/` and are valid PNGs
  4. DevTools > Application > Manifest; read error messages
  5. Service Worker must be registered and "activated and running"

### SW Not Updating
- **Issue**: Changes to `public/sw.js` not visible
- **Solution**:
  1. Increment `CACHE_NAME` version
  2. Open DevTools > Application > Service Workers
  3. Click "Unregister" or "Update"
  4. Hard-refresh page (Cmd+Shift+R on Mac)

### Offline Mode Not Working
- **Issue**: App shows blank on offline after closing/reopening
- **Solution**:
  1. Ensure `ASSETS_TO_CACHE` includes `/index.html` and bundle files
  2. Check cache not full (browsers limit cache to ~50MB per origin)
  3. Verify network strategy in SW (should be "network-first" for HTML)

### Icons Missing on Home Screen
- **Issue**: No icon or wrong icon displayed after install
- **Solution**:
  1. Ensure `maskable-icon-512x512.png` has safe zone (center 80%)
  2. All icons must be RGB PNGs (no transparency)
  3. Rebuild manifest.json if icons added/removed
  4. Uninstall app, clear cache, reinstall

---

**Related**: [SVG Icon guidelines](./svelte.instructions.md), [Performance budgets](../AGENTS.md), [Release workflow](./../../pnpm-release)
