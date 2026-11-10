# Changelog

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
