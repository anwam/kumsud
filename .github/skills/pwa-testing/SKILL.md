---
name: pwa-testing
description: "Validate and test PWA readiness before deployment. Use when checking installability, manifest validity, service worker functionality, offline mode, caching, and icon rendering. Includes automated scripts and step-by-step verification."
argument-hint: "Run PWA validation before release"
---

# PWA Testing Skill

Comprehensive validation and testing for Progressive Web App features in kumsud. Ensures app is installable, works offline, and provides excellent user experience on home screen.

## When to Use

- **Pre-deployment**: Validate all PWA criteria before `pnpm release`
- **After icon updates**: Verify icons render correctly on all devices
- **After manifest changes**: Check manifest syntax and field correctness
- **After service worker updates**: Test caching, offline mode, and updates
- **Real device testing**: Validate on actual phone/tablet before release
- **Troubleshooting**: Debug installability, offline, or cache issues

## Quick Validation

Run the automated PWA validator script:

```bash
bash .github/skills/pwa-testing/scripts/validate-pwa.sh
```

The script checks:
- ✓ Manifest exists and is valid JSON
- ✓ All required manifest fields present
- ✓ All icon files exist in `public/`
- ✓ Icon dimensions match manifest declarations
- ✓ Service Worker file exists
- ✓ Service Worker includes cache name and assets
- ✓ `index.html` links manifest and registers SW
- ✓ Icons are PNG format (or SVG for favicon)
- ✓ Manifest icons have correct purpose fields

**Output**: Pass/fail summary with specific error locations

## Detailed Checklist

Reference the [PWA Verification Checklist](./references/pwa-checklist.md) for comprehensive manual verification across:
- Manifest completeness and metadata
- Icon assets and rendering
- Service Worker implementation
- Offline functionality
- Installation flow
- Update detection
- Performance budgets
- Browser DevTools validation

## Testing Procedure

### 1. Automated Validation

```bash
bash .github/skills/pwa-testing/scripts/validate-pwa.sh
```

Fix any reported errors before proceeding.

### 2. Local Development Testing

```bash
pnpm build
pnpm preview
```

Then use DevTools (see step 3) to verify the production build works offline.

### 3. DevTools Validation

Open **Chrome DevTools** (`F12` or `Cmd+Option+I`):

#### Service Worker Status
- Tab: **Application > Service Workers**
- Expected: Status shows "activated and running"
- Scope: Should match start_url (likely `/`)
- Click: **Update on reload** for rapid testing

#### Manifest Inspection
- Tab: **Application > Manifest**
- Expected: No errors or warnings
- Verify: All icons load (green checkmarks)
- Check: `display`, `start_url`, `orientation` fields are correct

#### Cache Storage
- Tab: **Application > Cache Storage**
- Expected: `kumsud-vX` cache exists (where X is version)
- Inspect: Cache contains all URLs in `ASSETS_TO_CACHE`
- Verify: Includes `/index.html`, manifest, icons

#### Offline Testing
- Tab: **Network**
- Toggle: Check the **Offline** checkbox
- Reload: Page with Ctrl+R
- Expected: Page loads from cache (no network requests)
- Verify: All assets display (icons, CSS, layout intact)
- Re-enable: Uncheck **Offline** when done

#### Storage Quota
- Tab: **Application > Storage**
- Check: Cache usage is <10MB (plenty of headroom)
- Monitor: If cache grows over 50MB, could fail on some devices

### 4. Install Prompt Testing (Chrome)

- DevTools > **Application > Manifest**
- Button: Click **"Install"** (blue button on the manifest pane)
- Expected: App installs to Chrome app drawer
- Verify: Clicking installed app launches full-screen standalone mode

### 5. Real Device Testing (iOS & Android)

#### Android (Chrome)
1. Navigate to app in Chrome
2. Tap menu (⋮) > **"Install app"** or **"Add to Home Screen"**
3. Confirm installation
4. Launch app from home screen → should open full-screen
5. Close app, turn off WiFi, reopen → should load offline

#### iOS (Safari)
1. Navigate to app in Safari
2. Tap Share button > **"Add to Home Screen"**
3. Confirm; give it a name
4. Home screen icon appears; tap to launch
5. Expected: Standalone full-screen mode (no Safari UI)
6. Test offline: Airplane mode > reload; should display cached version

### 6. Manifest Screenshot Testing (Android)

If using `screenshots` in `manifest.json`:
- Android devices show app screenshots in Play Store-like install prompt
- Screenshots appear only if app meets all PWA criteria
- Test on Android device: Manifest should trigger "Install app" prompt with screenshots visible

### 7. Performance Validation

Check production bundle size:

```bash
pnpm build
ls -lh dist/
```

**Targets**:
- `dist/index.html`: <50KB
- `dist/index.*.js` (main bundle): <200KB gzipped
- All assets combined: <500KB gzipped

If over budget:
- Analyze with `pnpm build --analyze` (if webpack plugin available)
- Consider lazy-loading routes (not applicable for kumsud SPA)
- Compress images further if applicable

### 8. Update Flow Testing

Test service worker updates:

1. Update `CACHE_NAME` in `public/sw.js`:
   ```javascript
   const CACHE_NAME = 'kumsud-v2' // was v1
   ```

2. Run `pnpm preview` and load app
3. DevTools > **Service Workers** > Unregister old SW
4. Hard-refresh (Cmd+Shift+R)
5. Expected: New SW activates, old cache cleaned
6. DevTools > **Cache Storage**: Old `kumsud-v1` cache deleted

## Troubleshooting Guide

See [PWA Checklist > Troubleshooting](./references/pwa-checklist.md#troubleshooting) for solutions to:
- App won't install
- Service Worker not updating
- Offline mode not working
- Icons missing on home screen
- Update notifications not showing

## Before Deployment Checklist

Use this before running `pnpm release`:

- [ ] `bash .github/skills/pwa-testing/scripts/validate-pwa.sh` passes all checks
- [ ] DevTools shows no manifest errors
- [ ] Service Worker: "activated and running"
- [ ] Offline mode works (DevTools > Network > Offline)
- [ ] Cache size <50MB (DevTools > Storage)
- [ ] Production build <500KB gzipped
- [ ] Tested install on real Android device (Chrome)
- [ ] Tested install on real iOS device (Safari)
- [ ] All icons render correctly on home screen
- [ ] Version bumped in `package.json`
- [ ] `CACHE_NAME` version bumped in `public/sw.js`
- [ ] CHANGELOG generated via `pnpm release`

## Scripts

- [validate-pwa.sh](./scripts/validate-pwa.sh) — Automated manifest, icon, and SW validation

## References

- [PWA Verification Checklist](./references/pwa-checklist.md) — Detailed manual checklist
- [PWA Instructions](../../instructions/pwa.instructions.md) — Full PWA implementation guide
- [Chrome DevTools PWA Guide](https://developer.chrome.com/docs/devtools/progressive-web-apps/) — Official DevTools documentation
