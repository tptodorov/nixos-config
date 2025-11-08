# iCloud Integration Guide for NixOS

This guide explains how to integrate Apple iCloud services with your NixOS system.

## Overview

Your NixOS configuration now includes support for:
- ✅ **iCloud Mail** (full support via IMAP/SMTP)
- ✅ **iCloud Calendar** (full support via CalDAV)
- ✅ **iCloud Contacts** (full support via CardDAV)
- ⚠️ **iCloud Drive** (limited - web access only)
- ⚠️ **iCloud Photos** (limited - web access or manual download)

## Prerequisites

### 1. Generate App-Specific Password

Since you likely have 2-Factor Authentication enabled on your Apple ID, you **must** use an app-specific password:

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Navigate to **Security** → **App-Specific Passwords**
4. Click **Generate Password**
5. Name it something like "NixOS Evolution" or "Linux Desktop"
6. **Save this password** - you'll need it for setup

⚠️ **Important**: Use this app-specific password, NOT your regular Apple ID password.

## Installation

The iCloud integration module is already configured in your system. To activate:

```bash
# Add new module to git (required for Nix flakes)
git add home/todor/modules/icloud.nix

# Rebuild system with Home Manager
sudo nixos-rebuild switch --flake .#blackbox
```

This will install:
- Evolution (email, calendar, contacts client)
- GNOME Online Accounts (iCloud integration)
- rclone (cloud storage tool)
- vdirsyncer (alternative sync tool)
- DigiKam (photo management)
- davfs2 (WebDAV filesystem support)

## Setup Methods

### Method 1: GNOME Online Accounts (Recommended)

This is the easiest way to set up iCloud on Linux.

1. **Open GNOME Settings**:
   ```bash
   gnome-control-center online-accounts
   ```
   Or: Settings → Online Accounts

2. **Add iCloud Account**:
   - Click the "+" button
   - Select "iCloud"
   - Enter your Apple ID email
   - Enter your **app-specific password** (not your regular password!)

3. **Enable Services**:
   - Toggle on: **Mail**, **Calendar**, **Contacts**
   - Leave other services off (Files not supported on Linux)

4. **Open Evolution**:
   ```bash
   evolution
   ```
   Your iCloud mail, calendar, and contacts will automatically appear!

### Method 2: Manual Evolution Configuration

If GNOME Online Accounts doesn't work, configure Evolution manually:

#### Email (IMAP/SMTP)

1. Open Evolution → File → New → Mail Account
2. **Identity**:
   - Full Name: Your Name
   - Email: your-apple-id@icloud.com

3. **Receiving Email (IMAP)**:
   - Server Type: IMAP
   - Server: `imap.mail.me.com`
   - Port: `993`
   - Username: `your-apple-id@icloud.com`
   - Encryption: SSL/TLS
   - Authentication: Password

4. **Sending Email (SMTP)**:
   - Server: `smtp.mail.me.com`
   - Port: `587`
   - Encryption: STARTTLS
   - Authentication: Password (same as IMAP)
   - Username: `your-apple-id@icloud.com`

5. Enter your **app-specific password** when prompted

#### Calendar (CalDAV)

1. Evolution → File → New → Calendar
2. Type: CalDAV
3. **Settings**:
   - URL: `https://caldav.icloud.com/`
   - Username: `your-apple-id@icloud.com`
   - Password: app-specific password
4. Evolution will discover your calendars automatically

#### Contacts (CardDAV)

1. Evolution → File → New → Address Book
2. Type: CardDAV (WebDAV)
3. **Settings**:
   - URL: `https://contacts.icloud.com/`
   - Username: `your-apple-id@icloud.com`
   - Password: app-specific password

### Method 3: vdirsyncer (Advanced)

For users who prefer command-line sync or want local calendar/contact files:

1. **Configure vdirsyncer**:
   ```bash
   # Copy template
   cp ~/.config/vdirsyncer/config.sample ~/.config/vdirsyncer/config

   # Edit and add your credentials
   nano ~/.config/vdirsyncer/config
   ```

2. **Replace placeholders**:
   - Change `YOUR-APPLE-ID@icloud.com` to your Apple ID
   - Add your app-specific password

3. **Discover collections**:
   ```bash
   vdirsyncer discover icloud_calendar
   vdirsyncer discover icloud_contacts
   ```

4. **Sync**:
   ```bash
   vdirsyncer sync
   ```

5. **Automatic sync** (optional):
   Add to crontab or create a systemd timer.

## iCloud Drive & Photos

Unfortunately, Apple doesn't provide official Linux support for iCloud Drive or Photos. Here are your options:

### iCloud Drive

**Option 1: Web Interface (Recommended)**
- Visit [icloud.com](https://icloud.com) in Brave browser
- Access files directly in your browser
- Download/upload files as needed

**Option 2: Third-Party Tools (Experimental)**
- Some community tools exist (pyicloud, icloud-docker) but are not well-maintained
- Not included in this configuration due to reliability concerns

**Option 3: Alternative Cloud Sync**
- Consider using a cross-platform service (Dropbox, Google Drive, OneDrive)
- Use rclone to sync with multiple cloud providers:
  ```bash
  rclone config  # Configure other cloud storage
  rclone sync /local/path remote:path
  ```

### iCloud Photos

**Option 1: Web Interface**
- Visit [icloud.com/photos](https://icloud.com/photos)
- Select photos and download
- Save to `~/Pictures`

**Option 2: Manual Download + DigiKam**
1. Download photos from iCloud web interface
2. Import into DigiKam for organization:
   ```bash
   digikam
   ```
3. DigiKam provides tagging, albums, and editing tools

**Option 3: Shared Albums**
- Create shared albums in iCloud Photos
- Access via web interface
- Download albums as needed

## Troubleshooting

### Authentication Fails

**Problem**: "Invalid credentials" or "Authentication failed"

**Solution**:
1. Verify you're using an **app-specific password**, not your main password
2. Check that the app-specific password was copied correctly (no extra spaces)
3. Try generating a new app-specific password
4. Ensure your Apple ID email is correct (usually ends in @icloud.com, @me.com, or @mac.com)

### 2FA Issues

**Problem**: Evolution/GNOME Online Accounts asks for verification code

**Solution**:
- Don't enter your 2FA code
- You **must** use an app-specific password instead
- App-specific passwords bypass 2FA for third-party apps

### Calendars Not Appearing

**Problem**: Calendar is connected but no calendars show

**Solutions**:
1. In Evolution, click Calendar view → View → Calendar List
2. Check that iCloud calendars are enabled (checkboxes)
3. Wait a few minutes for initial sync
4. Right-click calendar → Refresh

### Contacts Not Syncing

**Problem**: Address book is empty

**Solutions**:
1. Verify CardDAV URL is correct: `https://contacts.icloud.com/`
2. Check username format (should be full Apple ID email)
3. Try removing and re-adding the account
4. Check Evolution → View → Address Books to ensure it's enabled

### GNOME Keyring Password Prompts

**Problem**: Constantly asked to unlock keyring

**Solution**:
1. The keyring should unlock automatically at login
2. If prompted, enter your user password
3. Check "Unlock automatically when I log in"
4. Ensure GNOME Keyring service is running:
   ```bash
   systemctl --user status gnome-keyring-daemon
   ```

### Mail Not Downloading

**Problem**: Folders are empty or not syncing

**Solutions**:
1. Check internet connection
2. Verify IMAP settings (server: `imap.mail.me.com`, port: 993, SSL/TLS)
3. In Evolution, right-click folder → Refresh
4. Check Send/Receive → Send/Receive All
5. Look for error messages in Evolution

### Can't Send Email

**Problem**: Receiving works but sending fails

**Solutions**:
1. Verify SMTP settings:
   - Server: `smtp.mail.me.com`
   - Port: `587`
   - Encryption: STARTTLS (not SSL/TLS)
2. Ensure SMTP authentication is enabled
3. Use the same app-specific password as IMAP
4. Check Edit → Preferences → Mail Accounts → Edit → Sending Email

## Using Evolution

### Basic Operations

**Reading Email**:
- Evolution starts in Mail view
- Click folders to browse
- Click messages to read
- Use search bar for finding emails

**Composing Email**:
- Click "New" button or `Ctrl+N`
- Fill in To, Subject, and body
- Click "Send"

**Calendar**:
- Click "Calendar" button in toolbar
- View Day/Week/Month/List
- Double-click to create events
- Drag to resize events

**Contacts**:
- Click "Contacts" button
- Double-click to edit contact
- Click "New" to add contact
- Use search to find contacts

### Keyboard Shortcuts

- `Ctrl+N` - New (email/event/contact depending on view)
- `Ctrl+R` - Reply
- `Ctrl+Shift+R` - Reply All
- `Ctrl+F` - Forward
- `Ctrl+S` - Save
- `Ctrl+Q` - Quit
- `F9` - Send/Receive All

## Alternative: Terminal-Based Access

For users who prefer command-line tools:

### Email
```bash
# Use neomutt (not installed by default)
nix-shell -p neomutt
neomutt -f imaps://your-apple-id@icloud.com@imap.mail.me.com
```

### Calendar
```bash
# Use calcurse with vdirsyncer
nix-shell -p calcurse
calcurse -D ~/.local/share/calendars/icloud/
```

### Contacts
```bash
# View VCF files directly
cat ~/.local/share/contacts/icloud/*.vcf
```

## Security Best Practices

1. **Never share your app-specific password** - treat it like your main password
2. **Store passwords in GNOME Keyring** - let Evolution handle password management
3. **Revoke unused app passwords** - regularly audit at appleid.apple.com
4. **Don't commit passwords to git** - they're stored in GNOME Keyring, not config files
5. **Use unique app passwords** - generate different ones for different services

## Limitations

What **works** on Linux:
- ✅ Email (IMAP/SMTP) - perfect compatibility
- ✅ Calendar (CalDAV) - full sync, all features
- ✅ Contacts (CardDAV) - full sync, all features
- ✅ Notes via IMAP (stored in mail folders)

What **doesn't work**:
- ❌ iCloud Drive native sync - no Linux client from Apple
- ❌ iCloud Photos native sync - no Linux client
- ❌ Find My - web only
- ❌ iCloud Keychain - Apple-exclusive
- ❌ Messages/FaceTime - Apple-exclusive

## Getting Help

If you encounter issues:

1. **Check logs**:
   ```bash
   journalctl --user -u evolution-addressbook-factory
   journalctl --user -u evolution-calendar-factory
   ```

2. **Test connectivity**:
   ```bash
   # Test IMAP
   telnet imap.mail.me.com 993

   # Test SMTP
   telnet smtp.mail.me.com 587
   ```

3. **Verify credentials**:
   ```bash
   # Test CalDAV with curl
   curl -u "your-apple-id@icloud.com:app-password" https://caldav.icloud.com/
   ```

4. **Evolution debug mode**:
   ```bash
   CAMEL_DEBUG=all evolution 2>&1 | tee evolution-debug.log
   ```

## Additional Resources

- [Apple Support: App-specific passwords](https://support.apple.com/en-us/HT204397)
- [iCloud Server Information](https://support.apple.com/en-us/HT202304)
- [Evolution Documentation](https://help.gnome.org/users/evolution/stable/)
- [vdirsyncer Documentation](https://vdirsyncer.pimutils.org/)

## Quick Reference

### iCloud Server Settings

| Service  | Server                    | Port | Encryption |
|----------|---------------------------|------|------------|
| IMAP     | imap.mail.me.com          | 993  | SSL/TLS    |
| SMTP     | smtp.mail.me.com          | 587  | STARTTLS   |
| CalDAV   | caldav.icloud.com         | 443  | HTTPS      |
| CardDAV  | contacts.icloud.com       | 443  | HTTPS      |

### Common Commands

```bash
# Open Evolution
evolution

# Open GNOME Settings (Online Accounts)
gnome-control-center online-accounts

# Sync calendars/contacts with vdirsyncer
vdirsyncer sync

# Configure rclone (for other cloud services)
rclone config

# Manage photos with DigiKam
digikam

# Validate iCloud connection
curl -u "email:password" https://caldav.icloud.com/
```
