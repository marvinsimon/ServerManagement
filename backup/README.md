# Scheduled Borg backups

This setup creates a separate Borg 1.x archive for each application job. The
examples cover the Immich library and the Paperless `data` and `media` folders.
The Paperless example does **not** back up its database and is not a complete
Paperless backup. This setup does not create database backups, initialize
repositories, or prune archives. Ensure Immich's own database backups are
current and included in its library.

## Configure on the server

Install Borg 1.x and `flock` (provided by `util-linux` on CentOS). Confirm the
service user can access all sources, the SSH key, and the existing Borg
repository without prompts. Test SSH host-key verification as that user first;
`BatchMode=yes` prevents unattended SSH prompts. If the Borg repository is
encrypted, configure passphrase access securely as well.

1. Create `/etc/borg-backup` and copy `immich.env.example` and
   `paperless.env.example` there as `immich.env` and `paperless.env`. Replace
   the placeholders in both files. Source paths must be relative to
   `BACKUP_WORKING_DIR`, preserving relative archive paths. A job supports one
   required source and an optional `BACKUP_SOURCE_2`. `BACKUP_EXCLUDE` is
   optional and accepts one Borg pattern applied to both sources.
2. Restrict access to each configuration, for example with
   `sudo chmod 600 /etc/borg-backup/immich.env /etc/borg-backup/paperless.env`.
   Keep the SSH private key separate and readable by the service user. Never
   commit real credentials or keys.
3. Copy `borg-backup@.service.example` to
   `/etc/systemd/system/borg-backup@.service`. Replace `REPLACE_WITH_USER` and
   the `ExecStart` path with the service account and absolute path to the
   script in your checkout. Ensure the account can execute the script and
   access its parent directories. Systemd reads the environment files before
   starting the service, so they may remain root-readable only.
4. Copy `borg-backup@.timer` to `/etc/systemd/system/borg-backup@.timer`, then:

   ```sh
   sudo systemctl daemon-reload
   sudo systemctl enable --now borg-backup@immich.timer borg-backup@paperless.timer
   ```

Each timer defaults to 02:00 in the server's local time zone. `Persistent=true`
runs a missed backup when the timer becomes active. Each job has its own lock,
but Borg also locks the repository: `BACKUP_LOCK_WAIT` controls how many seconds
it waits for that lock (default 3600). A job fails if the wait expires. To
stagger schedules, run `sudo systemctl edit borg-backup@paperless.timer` and add:

```ini
[Timer]
OnCalendar=
OnCalendar=*-*-* 04:00:00
```

Then run `sudo systemctl restart borg-backup@paperless.timer`. Choose a time
appropriate for your backup duration; persistent catch-up runs can still overlap.

If migrating from the earlier single-job example, disable the old timer first
(`sudo systemctl disable --now borg-backup.timer`) and move its settings into
`/etc/borg-backup/immich.env`. Otherwise both schedules may run.

## Test and monitor

Test each job separately and inspect its result, for example:

```sh
sudo systemctl start borg-backup@immich.service
sudo systemctl status borg-backup@immich.service
sudo journalctl -u borg-backup@immich.service -n 100 --no-pager
sudo systemctl start borg-backup@paperless.service
sudo systemctl status borg-backup@paperless.service
sudo journalctl -u borg-backup@paperless.service -n 100 --no-pager
systemctl list-timers 'borg-backup@*'
```

Borg exit status 1 indicates a warning and is treated as a service failure;
investigate it as well as errors. Logs include file names because `--list` is
enabled. Verify each archive with Borg's `list` and `extract` commands and test
restoring files. Confirm the Immich exclusion matches the intended thumbnails
directory: a pattern that does not match silently includes it. Backups
accumulate until you configure and test a separate retention policy.
