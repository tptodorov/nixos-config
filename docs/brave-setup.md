# Brave Browser Setup Guide

This document describes the Brave browser configuration in your NixOS system and how to complete the sync setup with your `todor@peychev.com` account.

## What Was Configured

### System Changes
- **Replaced Firefox** with Brave browser as the default browser
- **Updated environment variables**: `BROWSER` is now set to `brave`
- **Updated MIME associations**: All web content now opens with Brave
- **Updated Hyprland config**: `$browser` variable now points to `brave`

### Brave Browser Features
- **Hardware acceleration** enabled for better performance
- **Wayland support** for native Linux desktop integration
- **Privacy-focused extensions** pre-installed:
  - uBlock Origin (Ad blocker)
  - Bitwarden (Password manager)
  - Dark Reader (Dark mode for websites)
  - Privacy Badger (Tracker blocker)
  - ClearURLs (Remove tracking parameters)

### Performance Optimizations
- GPU rasterization enabled
- Zero-copy rendering for better performance
- Hardware overlays support
- Optimized memory usage (4GB max old space size)

### Security & Privacy Settings
- DNS-over-HTTPS with Cloudflare
- WebRTC leak protection
- Background networking disabled
- Client-side phishing detection disabled
- Breakpad crash reporting disabled

## Completing Sync Setup

### Method 1: Using the Setup Script
```bash
cd ~/mycfg
./scripts/setup-brave-sync.sh
```

### Method 2: Manual Setup
1. **Open Brave browser**:
   ```bash
   brave
   ```

2. **Access sync settings**:
   - Click the profile icon (top-right corner)
   - Select "Turn on sync..."
   - Or use the alias: `brave-sync`

3. **Sign in with your account**:
   - Use your email: `todor@peychev.com`
   - Enter your password
   - Complete any 2FA if enabled

4. **Choose what to sync**:
   - Bookmarks ✅
   - History ✅
   - Passwords ✅
   - Extensions ✅
   - Settings ✅
   - Open tabs ✅
   - Autofill ✅

## Useful Commands

### Browser Launching
```bash
brave                # Open Brave browser
brave-private        # Open in incognito mode
brave-sync          # Open sync settings directly
```

### Default Browser Verification
```bash
echo $BROWSER                        # Should show 'brave'
xdg-mime query default text/html     # Should show 'brave-browser.desktop'
```

## Configuration Locations

### NixOS Configuration Files
- `home/todor/modules/brave.nix` - Main Brave configuration
- `home/todor/modules/desktop-apps.nix` - MIME associations
- `home/todor/secrets/environment.nix` - Environment variables
- `home/todor/config/hypr/hyprland.conf` - Hyprland browser setting

### Brave Data Directory
```bash
~/.config/BraveSoftware/Brave-Browser/
├── Default/              # Main profile data
│   ├── Preferences      # Browser settings
│   ├── Bookmarks        # Bookmarks file
│   └── ...
└── Local State          # Profile information
```

## Brave Features Enabled

### Privacy & Security
- **Brave Shields**: Blocks ads, trackers, and fingerprinting
- **HTTPS Everywhere**: Upgrades connections to HTTPS
- **Script blocking**: Configurable JavaScript blocking
- **Cookie control**: First-party cookies allowed, third-party blocked

### Web3 & Crypto
- **Brave Wallet**: Built-in cryptocurrency wallet
- **IPFS support**: InterPlanetary File System integration
- **Web3 DApp support**: Decentralized application compatibility

### Performance
- **Brave Search**: Privacy-focused search engine as default
- **Ad blocking**: Built-in ad and tracker blocking
- **Background tab throttling**: Reduces CPU usage for inactive tabs

## Troubleshooting

### Sync Issues
1. **Check internet connection**
2. **Verify account credentials**
3. **Clear sync data**: Settings → Advanced → Reset sync
4. **Restart Brave** and try again

### Extension Problems
1. **Check extension permissions**
2. **Disable/re-enable problematic extensions**
3. **Clear browser cache**: Settings → Privacy → Clear browsing data

### Performance Issues
1. **Check hardware acceleration**: Settings → Additional settings → System
2. **Clear browsing data** regularly
3. **Disable unnecessary extensions**

## Updating Configuration

To modify Brave settings:

1. **Edit the configuration**:
   ```bash
   vim ~/mycfg/home/todor/modules/brave.nix
   ```

2. **Rebuild the system**:
   ```bash
   sudo nixos-rebuild switch --flake .#blackbox
   ```

3. **Restart Brave** to apply changes

## Migration Notes

### From Firefox
- **Bookmarks**: Import via Brave Settings → Import bookmarks and settings
- **Passwords**: Use built-in import or Bitwarden extension
- **Extensions**: Reinstall from Chrome Web Store or Brave's extension store
- **Settings**: Most preferences will need to be reconfigured manually

### Data Sync
Once sync is enabled with `todor@peychev.com`, all your Brave data will:
- Sync across all your devices
- Be encrypted end-to-end
- Include passwords (if password sync is enabled)
- Update in real-time when you make changes

## Additional Resources

- **Brave Help Center**: https://support.brave.com/
- **Privacy Settings Guide**: https://support.brave.com/hc/en-us/articles/360017989132
- **Sync Documentation**: https://support.brave.com/hc/en-us/articles/360021218111

---

*This configuration provides a privacy-focused, high-performance browser setup optimized for your NixOS system with seamless sync capabilities.*
