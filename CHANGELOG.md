# Changelog

## 1.0.2 — security fix

- **Upload from URL (SSRF, parser differences).** Addresses with a user name, backslashes, spaces, control characters
  or an encoded host are refused, a trailing dot is ignored, and curl now receives an address rebuilt from the checked
  parts, so PHP and curl always agree on the host. After each request the connected IP must equal the checked one,
  otherwise the download is discarded.
- **Upload from URL (IPv6 forms).** Addresses are checked in binary form: IPv6 only within global unicast
  (2000::/3), excluding 6to4, Teredo and documentation ranges, which also rules out NAT64 (64:ff9b::/96),
  IPv4-compatible, unique-local and link-local addresses; IPv4-mapped addresses are checked as IPv4. IPv4 additionally
  excludes CGNAT, link-local, benchmarking, multicast and reserved ranges.

## 1.0.1 — security fixes

- **Settings are for admins only.** Full-access users with an own folder can no longer open Settings, the server
  browser, image previews or server tools. Before, they could change the root folder, other users' passwords or
  switch on server tools, and so escape their folder. An admin is a full-access user without an own folder; at
  least one must remain, and you can't give your own account a folder.
- **Upload from URL (SSRF).** Redirects are now followed by the app and every hop is checked (http/https only,
  blocked ports, all A and AAAA addresses must be public, including IPv4-mapped IPv6, CGNAT and link-local), and each
  request is pinned to the checked address, which also stops DNS rebinding. Without the curl extension the feature
  is refused instead of following unchecked redirects.
- **Hidden items.** A request could skip the hidden-items check by adding `type=settings_all` (with or without
  `ajax`); the check is now only skipped for an admin's Settings request with a valid token, which always finishes
  before any file action or page can run.

## 1.0.0 — Tiny File Manager++ (fork of Tiny File Manager 2.6)

### Added
- New interface: light and dark theme, coloured icons, compact one-screen layout, styled dialogs.
- Download of several selected files and folders as one zip, with a progress spinner; leftover temporary zips are cleaned up.
- Settings page for every option, with side tabs, defaults, reset, search, and a Users tab.
- Pickers and editors instead of typed values: server folder/image browser, IP list editor (IPv4/IPv6 checks, "add my address"), file-type editor with quick-add groups, hidden-items editor, editor-language editor, date format presets.
- First-run setup screen that creates the admin account.
- Change password page with strength meter and password generator; other sessions are signed out after a change.
- Optional server tools (off by default): Environment page, scheduled jobs (cron and systemd timers, with disable/enable/delete) and a log viewer.
- `TFMPP_SETTINGS` environment variable for the location of `settings.php`.
- Built-in default images, so the PHP file alone is a complete install.

### Changed
- Settings and users are stored in `settings.php`; the PHP file is never rewritten. A `config.php` is migrated once.
- Hidden items accept wildcards and full paths in any case, and are enforced for every action, search and direct links, including everything inside hidden folders.
- Allowed file types and editor languages match case-insensitively and accept wildcards.
- Safer defaults: no built-in password, PHP errors hidden, root folder = document root.
- Docker image based on PHP 8.3; Docker Compose keeps users and settings in a volume.
- Requires PHP 7.2 or newer.

### Fixed
- Rename / create refused upper-case extensions of allowed types (`Notes.TXT`).
- Search showed hidden files.
- The app's own `settings.php` (password hashes) could be viewed or downloaded by any signed-in user.
- The editor requested non-existent colouring modes for `.txt`, `.log` and similar files.
- Uploads from other clients than the upload page caused PHP warnings.
- With no users configured, sign-in was silently switched off.
