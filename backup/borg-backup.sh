#!/bin/sh
set -eu

: "${BORG_REPO:?Set BORG_REPO to the Borg repository URL}"
: "${BORG_RSH:?Set BORG_RSH to the SSH command}"
: "${BACKUP_WORKING_DIR:?Set BACKUP_WORKING_DIR to the source parent directory}"
: "${BACKUP_SOURCE:?Set BACKUP_SOURCE to the source path relative to BACKUP_WORKING_DIR}"
: "${BACKUP_ARCHIVE_PREFIX:?Set BACKUP_ARCHIVE_PREFIX}"
job="${1:?Pass the backup job name as the first argument}"
case "$job" in
    *[!a-zA-Z0-9_-]*|'') echo 'Invalid backup job name' >&2; exit 1 ;;
esac

export BORG_REPO BORG_RSH

# Keep archive paths and exclusion matching consistent with a relative source.
cd "$BACKUP_WORKING_DIR"
case "$BACKUP_SOURCE" in
    /*) echo 'BACKUP_SOURCE must be relative to BACKUP_WORKING_DIR' >&2; exit 1 ;;
esac
case "${BACKUP_SOURCE_2:-}" in
    /*) echo 'BACKUP_SOURCE_2 must be relative to BACKUP_WORKING_DIR' >&2; exit 1 ;;
esac

lock_dir="${HOME:?HOME must be set}/.cache"
mkdir -p "$lock_dir"
exec 9>"$lock_dir/borg-backup-$job.lock"
if ! flock -n 9; then
    echo "Backup job $job is already running" >&2
    exit 1
fi

archive="${BACKUP_ARCHIVE_PREFIX}-$(date +%Y-%m-%d_%H-%M-%S)-$$"
set -- create --stats --list --lock-wait "${BACKUP_LOCK_WAIT:-3600}"
if [ -n "${BACKUP_EXCLUDE:-}" ]; then
    set -- "$@" --exclude "$BACKUP_EXCLUDE"
fi
set -- "$@" "::$archive" "$BACKUP_SOURCE"
if [ -n "${BACKUP_SOURCE_2:-}" ]; then
    set -- "$@" "$BACKUP_SOURCE_2"
fi
exec borg "$@"
