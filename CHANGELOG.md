# Changelog

## 1.0.9 — update dialog confirms the result

- When the answer to **Update now** or **Roll back** can't be read (for example a notice printed by the version
  that ran the update, as 1.0.7 did on PHP 8.5, or a timeout), the dialog asks the server which version is now
  running. If it is the new one it says "Updated to version …" and reloads; otherwise it shows what the server
  answered, instead of "The server did not answer (200)".

## 1.0.8 — PHP 8.5, private-file check

- **PHP 8.5:** `curl_close()` (a no-op since PHP 8.0, deprecated in 8.5) is no longer called. With PHP errors shown,
  its notice was printed into the update check's answer and broke it ("The check did not finish").
- **Notices can't break the app any more:** deprecation notices are written to the Error log and never printed, and
  ajax/JSON answers never contain printed warnings. If an answer still can't be read, the update dialog shows what
  the server sent.
- **Setup check › Private files:** requests settings.php and the error log through the web server as a visitor would.
  If either comes back as source (a web server that hands out .php files as text), the row turns red with the fix
  for this server (nginx lines with its PHP-FPM socket, or Apache), and suggests keeping settings.php outside the
  web folder (TFMPP_SETTINGS).
- **Setup check › PHP errors in pages:** a note when PHP prints its errors into pages.
- Tested on PHP 8.5.12.

## 1.0.7 — Setup check tests the connection to GitHub

- **Setup check › Internet › Connection to GitHub.** Tests what updates need, step by step: name lookup, a
  connection to port 443, then the HTTPS answer over the updater's own route (curl, PHP sockets or the https
  wrapper). The first step that fails is named with its likely cause and commands for this server: e.g. PHP can't
  reach systemd-resolved because its PHP-FPM service is sandboxed (PrivateNetwork, IPAddressDeny…) or chrooted,
  only one name is filtered, outgoing connections are blocked, or HTTPS fails (proxy, clock, CA certificates).
- Runs when Setup check or Environment opens (result kept for 10 minutes; **Check again** tests anew). With update
  checks switched off it never contacts GitHub by itself and offers **Test now** instead.

## 1.0.6 — updates without curl

- **Check for updates and Update now work without the PHP curl extension.** When curl is missing or switched off,
  the updater talks to GitHub over PHP's own stream sockets (TLS with full certificate checks), or PHP's https
  wrapper when sockets are disabled and `allow_url_fopen` is on. The same rules apply on every route: GitHub hosts
  only, every redirect checked, size limit, SHA-256 and version check, self-test with automatic roll back.
  Upload from URL still needs curl (its address pinning depends on it).
- Setup check: curl that is installed but has `curl_init` / `curl_exec` in `disable_functions` now shows as
  "functions disabled", and its description says what still works.

## 1.0.5 — settings export / import, clearer copy/move results

- **Settings › Export / Import.** Export downloads every setting and user (with password hashes) as a .json file.
  Import shows what would change before anything happens, then asks for your password. Every value is checked like
  on the Settings page; values that don't fit the server keep their current value, a user whose own folder doesn't
  exist is skipped (never turned into an administrator), sign-in can't be switched off and address rules that would
  block you are refused. The current settings are saved first (the last three backups are kept, owner-only, hidden).
- **Copy / move keeps the app's own files.** Copying a backup of the app over the running one no longer reports
  "protected" errors: settings.php, the error log and caches of the running file manager are kept (also when they
  don't exist yet, so a copied settings.php can't bypass Import's checks), the dialog says so before you start, and
  the result is a note, not an error.
- Items hidden by the settings are reported as "kept" in the same way.
- **Security: links can't lead out of a user's folder.** For everyone but administrators, the root folder is now a
  hard boundary: a symbolic link that points outside it (or a path through one) can't be browsed, opened, downloaded,
  edited, written to, copied, moved, uploaded into or searched, and archives leave such links out. The file list shows
  "outside your folder" instead of the link's target. (Users could not create such links themselves; this closes it for
  links placed by someone with shell access, as in the original Tiny File Manager.)

## 1.0.4 — copy/move conflicts, updates, setup check, error log

### Copy and move
- Copy/move no longer fails silently when names already exist in the destination. New choice under
  Copy/Move: Skip (default), Overwrite (files replaced, folders merged) or Keep both ("name (1).ext"),
  for all items or per item. The dialog checks the destination first and marks the clashing items;
  the result message names every item that was skipped, renamed or refused, and why.
- Fixed: Copy silently overwrote an older file of the same name; Move reported success for skipped items.
- Security: copying never writes through a symbolic link in the destination (a link to a file is replaced
  as a link; a linked folder is never merged into).

### Updates
- Account menu shows the version and "Check for updates" (administrators). A daily background check
  (Settings > Advanced) puts a dot on the avatar when a newer release exists; the update dialog shows the
  release notes. Update now downloads the release from GitHub Releases, checks its SHA-256, version and
  PHP syntax, keeps the running version as a backup, replaces the file and self-tests it, rolling back
  automatically on failure. Roll back is offered afterwards.

### Setup check (new)
- Account menu > Setup check (also a tab in Environment): what the server needs for every feature
  (PHP extensions, upload limits, writable folders, HTTPS, shell_exec, Environment tools, sign-in) and the
  exact command to fix each missing part, for Debian/Ubuntu, RHEL-family and Alpine. Commands are shown
  and copied, never run. Includes a one-click test that an upload piece gets through the web server and PHP.

### Error log (new)
- Account menu > Error log (administrators): PHP warnings, uncaught exceptions and fatal errors, failed
  actions, settings problems and sign-in failures, grouped, searchable, downloadable, with "Copy as bug
  report". A red dot shows new errors. Stored next to settings.php in a file the web server can't serve,
  owner-only, rotated at 1 MB; never records passwords or tokens; sign-in failures limited per address.

### Environment
- Works when PHP has shell_exec disabled: versions from the package database, disks / processes / ports /
  interfaces / system details from /proc and /sys, SSH settings from sshd_config, updates from
  update-notifier. A "Limited view" notice explains the rest; health badges show "—" instead of a fake 0.
- Lists PHP-FPM pools started by their own service and reads combined php-fpm.conf files per section.
- Fixed: IPv4 loopback written as IPv6 (::ffff:127.0.0.1) was counted as a public port.

### Portability
- Fixed: the app failed to parse at all with short_open_tag=On (PHP's default without a php.ini).
- Fixed: hosts that disable functions such as set_time_limit, ini_set, chmod, symlink, curl_exec or
  readfile crashed on every page under PHP 8; the app now degrades feature by feature.
- settings.php and the error log are created owner-only even where chmod is disabled.

### Interface
- Link-styled buttons kept the link colour once visited (text invisible on primary buttons).

## 1.0.3 — security fix

- **Upload from URL (international names).** curl converts an international domain name to its `xn--` form, so the
  address pin set for the original spelling did not apply and curl looked the name up again. Names are now converted
  to the ASCII form before the check (or refused without the intl extension), only valid host names are accepted, and
  every connection is forced to the checked address with `CURLOPT_CONNECT_TO` before anything is sent. Proxies from
  the environment are no longer used.

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
