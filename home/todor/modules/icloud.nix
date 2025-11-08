{ pkgs, lib, vm ? false, ... }:
{
  # iCloud integration for NixOS
  # Provides access to iCloud Mail, Calendar, Contacts, and limited file/photo access

  home.packages = with pkgs; lib.optionals (!vm) [
    # Mail, Calendar, and Contacts
    evolution
    evolution-ews  # Exchange Web Services (for better compatibility)

    # GNOME Online Accounts - provides iCloud integration
    gnome-online-accounts

    # Cloud storage tools
    rclone  # Multi-cloud sync tool (can access some iCloud services via WebDAV)

    # Photo management (for downloading/organizing iCloud Photos)
    digikam  # Advanced photo management

    # Alternative sync tools
    vdirsyncer  # CalDAV/CardDAV sync alternative

    # File manager with cloud support
    nautilus  # Already in your config, but good for WebDAV mounting

    # Network file system support
    davfs2  # Mount WebDAV shares as filesystems
  ];

  # Note: GNOME Online Accounts is enabled at system level in hosts/blackbox/modules/desktop.nix
  # No additional home-manager configuration needed - it works automatically

  # XDG portal for better GNOME integration
  xdg.portal = lib.mkIf (!vm) {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Create config directory for rclone
  home.file.".config/rclone/README.md".text = ''
    # iCloud Access via rclone

    ## iCloud Mail (IMAP)
    Use Evolution or GNOME Online Accounts - much easier than rclone.

    ## iCloud CalDAV/CardDAV
    Configuration is done through GNOME Online Accounts:
    1. Open Settings → Online Accounts
    2. Add iCloud account
    3. Enable Calendar and Contacts

    ## iCloud Drive (Limited Support)
    Unfortunately, Apple doesn't provide direct iCloud Drive access on Linux.

    Workarounds:
    1. **Web Interface**: https://icloud.com (access via Brave browser)
    2. **Selective Sync**: Download specific files/folders via web interface
    3. **Third-party tools**: Use pyicloud-based tools (not maintained)

    ## Alternative: WebDAV for Specific Apps
    Some iCloud services support WebDAV:
    - Calendar: https://caldav.icloud.com
    - Contacts: https://contacts.icloud.com
    - (Files/Drive: NOT supported via WebDAV)
  '';

  # Create Evolution config directory with iCloud setup instructions
  home.file.".local/share/evolution/README-ICLOUD.md".text = ''
    # Setting up iCloud in Evolution

    ## Option 1: GNOME Online Accounts (Recommended)
    1. Open Settings → Online Accounts
    2. Click "+" to add account
    3. Select "iCloud"
    4. Enter your Apple ID and password
    5. If you have 2FA enabled, you'll need an app-specific password:
       - Go to appleid.apple.com
       - Sign in
       - Go to Security → App-Specific Passwords
       - Generate a new password for "Linux Evolution"
       - Use this password instead of your regular password
    6. Enable: Mail, Calendar, Contacts
    7. Evolution will automatically detect and use these accounts

    ## Option 2: Manual Configuration in Evolution

    ### iCloud Mail (IMAP)
    - **Incoming (IMAP)**:
      - Server: imap.mail.me.com
      - Port: 993
      - Security: SSL/TLS
      - Username: your-apple-id@icloud.com
      - Password: app-specific password (see above)

    - **Outgoing (SMTP)**:
      - Server: smtp.mail.me.com
      - Port: 587
      - Security: STARTTLS
      - Username: your-apple-id@icloud.com
      - Password: app-specific password

    ### iCloud Calendar (CalDAV)
    1. In Evolution, go to File → New → Calendar
    2. Type: CalDAV
    3. URL: https://caldav.icloud.com/
    4. Username: your-apple-id@icloud.com
    5. Password: app-specific password

    ### iCloud Contacts (CardDAV)
    1. In Evolution, go to File → New → Address Book
    2. Type: CardDAV
    3. URL: https://contacts.icloud.com/
    4. Username: your-apple-id@icloud.com
    5. Password: app-specific password

    ## iCloud Photos
    Unfortunately, there's no direct iCloud Photos integration on Linux.

    Options:
    1. **Web Interface**: https://icloud.com/photos (via Brave)
    2. **Bulk Download**: Select photos on iCloud web, download to ~/Pictures
    3. **DigiKam**: Import downloaded photos for organization
    4. **Shared Albums**: Create shared albums, access via web

    ## Troubleshooting
    - **2FA Issues**: Always use app-specific passwords, never your main password
    - **Sync Problems**: Check network, verify credentials
    - **Missing Calendars**: They may appear as sub-calendars, check Evolution's calendar list
  '';

  # Add vdirsyncer config template for advanced users
  home.file.".config/vdirsyncer/config.sample".text = ''
    # vdirsyncer - Alternative CalDAV/CardDAV sync
    # Rename to 'config' and fill in your details to use

    [general]
    status_path = "~/.local/share/vdirsyncer/status/"

    # iCloud Calendar sync
    [pair icloud_calendar]
    a = "icloud_calendar_local"
    b = "icloud_calendar_remote"
    collections = ["from a", "from b"]

    [storage icloud_calendar_local]
    type = "filesystem"
    path = "~/.local/share/calendars/icloud"
    fileext = ".ics"

    [storage icloud_calendar_remote]
    type = "caldav"
    url = "https://caldav.icloud.com/"
    username = "YOUR-APPLE-ID@icloud.com"
    password.fetch = ["command", "pass", "show", "icloud/app-specific-password"]
    # Or use: password = "your-app-specific-password"

    # iCloud Contacts sync
    [pair icloud_contacts]
    a = "icloud_contacts_local"
    b = "icloud_contacts_remote"
    collections = ["from a", "from b"]

    [storage icloud_contacts_local]
    type = "filesystem"
    path = "~/.local/share/contacts/icloud"
    fileext = ".vcf"

    [storage icloud_contacts_remote]
    type = "carddav"
    url = "https://contacts.icloud.com/"
    username = "YOUR-APPLE-ID@icloud.com"
    password.fetch = ["command", "pass", "show", "icloud/app-specific-password"]
    # Or use: password = "your-app-specific-password"
  '';
}
