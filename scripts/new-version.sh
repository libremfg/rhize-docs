#!/usr/bin/env bash
#
# new-version.sh - cut a new Rhize docs version.
#
# Given a target version (X.Y.Z), the script picks one of two flows by
# comparing it to the current "latest" (the `cascade.v` in
# content/latest/_index.md):
#
# PROMOTE  (target > current latest, e.g. latest 4.4.0 -> cut 4.4.1)
#   1. Copy content/latest/ -> content/versions/v<latest>/ so the now-old
#      docs stay browsable (the copied _index.md keeps its own cascade.v).
#   2. Rewrite content/latest/_index.md cascade.v to <target>.
#
# BACKPORT (target < current latest, e.g. latest 4.4.0 -> cut 4.3.5)
#   1. Find <base> = highest already-released version below <target>.
#   2. Copy content/versions/v<base>/ -> content/versions/v<target>/ and
#      set that tree's cascade.v to <target>. content/latest/ is untouched.
#
# Both flows then:
#   - Insert a data/versionCompat.yaml entry for <target>, cloned from the
#     <base> entry, in version-sorted position (the file is newest-first).
#   - Scaffold content/releases/<x-y-z>.md via `hugo new`
#     (archetypes/releases.md).
#   - Write a placeholder static/checksums/v<target>-checksums.txt (the
#     checksums shortcode readFile()s it, so the build needs it to exist).
#
# Usage:
#   scripts/new-version.sh 4.4.1
#
# Run from anywhere; it locates the repo root itself. Review `git diff`
# and `git status` before committing.

set -euo pipefail

die() { printf 'error: %s\n' "$*" >&2; exit 1; }

[ $# -eq 1 ] || die "usage: $(basename "$0") <new-version>  (e.g. 4.4.1)"
NEW=$1

case $NEW in
  [0-9]*.[0-9]*.[0-9]*) ;;
  *) die "version must look like X.Y.Z, got '$NEW'" ;;
esac

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$REPO_ROOT"

LATEST_INDEX=content/latest/_index.md
COMPAT=data/versionCompat.yaml
VERSIONS_DIR=content/versions

[ -f "$LATEST_INDEX" ] || die "missing $LATEST_INDEX"
[ -f "$COMPAT" ] || die "missing $COMPAT"

# semantic X.Y.Z compare: prints -1 / 0 / 1 for $1 vs $2
vcmp() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    na = split(a, x, "."); nb = split(b, y, ".")
    for (i = 1; i <= 3; i++) {
      if ((x[i]+0) < (y[i]+0)) { print -1; exit }
      if ((x[i]+0) > (y[i]+0)) { print  1; exit }
    }
    print 0
  }'
}

# Current "latest" = the `v:` line inside the cascade frontmatter.
CURRENT=$(sed -n 's/^[[:space:]]*v:[[:space:]]*"\([0-9][^"]*\)".*/\1/p' "$LATEST_INDEX" | head -n1)
[ -n "$CURRENT" ] || die "could not read current version from $LATEST_INDEX"
[ "$NEW" != "$CURRENT" ] || die "$LATEST_INDEX already points at $NEW"

# All versions we know about: current latest + every archived tree.
ALL_VERSIONS=$(
  { printf '%s\n' "$CURRENT"
    for d in "$VERSIONS_DIR"/v*/; do
      [ -d "$d" ] || continue
      b=${d#"$VERSIONS_DIR"/v}; printf '%s\n' "${b%/}"
    done
  } | sort -V -u
)

if [ "$(vcmp "$NEW" "$CURRENT")" -gt 0 ]; then
  FLOW=promote
  BASE=$CURRENT
else
  FLOW=backport
  # highest known version strictly below NEW
  BASE=""
  for v in $ALL_VERSIONS; do
    [ "$(vcmp "$v" "$NEW")" -lt 0 ] && BASE=$v
  done
  [ -n "$BASE" ] || die "no released version below $NEW to base a backport on"
fi

TARGET_TREE=$VERSIONS_DIR/v$NEW

printf 'Flow          : %s\n' "$FLOW"
printf 'Current latest : %s\n' "$CURRENT"
printf 'New version    : %s\n' "$NEW"
printf 'Base version   : %s\n\n' "$BASE"

# ---------------------------------------------------------------------------
# 1. Create / archive the version tree.
# ---------------------------------------------------------------------------
if [ "$FLOW" = promote ]; then
  ARCHIVE=$VERSIONS_DIR/v$CURRENT
  if [ -e "$ARCHIVE" ]; then
    printf 'skip archive: %s already exists\n' "$ARCHIVE"
  else
    mkdir -p "$VERSIONS_DIR"
    cp -R content/latest "$ARCHIVE"
    printf 'archived content/latest -> %s\n' "$ARCHIVE"
  fi

  sed -i "s/^\([[:space:]]*v:[[:space:]]*\)\"$CURRENT\"/\1\"$NEW\"/" "$LATEST_INDEX"
  grep -q "v: \"$NEW\"" "$LATEST_INDEX" || die "failed to bump $LATEST_INDEX"
  printf 'bumped %s cascade.v: %s -> %s\n' "$LATEST_INDEX" "$CURRENT" "$NEW"
else
  BASE_TREE=$VERSIONS_DIR/v$BASE
  [ -d "$BASE_TREE" ] || die "base tree $BASE_TREE not found"
  if [ -e "$TARGET_TREE" ]; then
    printf 'skip copy: %s already exists\n' "$TARGET_TREE"
  else
    cp -R "$BASE_TREE" "$TARGET_TREE"
    printf 'copied %s -> %s\n' "$BASE_TREE" "$TARGET_TREE"
  fi
  sed -i "s/^\([[:space:]]*v:[[:space:]]*\)\"$BASE\"/\1\"$NEW\"/" "$TARGET_TREE/_index.md"
  grep -q "v: \"$NEW\"" "$TARGET_TREE/_index.md" || die "failed to set cascade.v in $TARGET_TREE/_index.md"
  printf 'set %s cascade.v: %s -> %s\n' "$TARGET_TREE/_index.md" "$BASE" "$NEW"
fi

# ---------------------------------------------------------------------------
# 2. data/versionCompat.yaml - clone the <base> block, insert version-sorted.
# ---------------------------------------------------------------------------
if grep -q "^- version: \"$NEW\"" "$COMPAT"; then
  printf 'skip versionCompat: entry for %s already present\n' "$NEW"
else
  BASE_BLOCK=$(awk -v base="$BASE" '
    $0 == "- version: \"" base "\"" { grab = 1 }
    grab && /^- version: / && $0 != "- version: \"" base "\"" { exit }
    grab { print }
  ' "$COMPAT")
  [ -n "$BASE_BLOCK" ] || die "could not find $BASE block in $COMPAT"
  NEW_BLOCK=$(printf '%s\n' "$BASE_BLOCK" | sed "1s/\"$BASE\"/\"$NEW\"/")

  tmp=$(mktemp)
  awk -v newblock="$NEW_BLOCK" -v nv="$NEW" '
    function vcmp(a, b,   x, y, i) {
      split(a, x, "."); split(b, y, ".")
      for (i = 1; i <= 3; i++) {
        if ((x[i]+0) < (y[i]+0)) return -1
        if ((x[i]+0) > (y[i]+0)) return 1
      }
      return 0
    }
    /^- version: "/ {
      ver = $0; sub(/^- version: "/, "", ver); sub(/".*/, "", ver)
      if (!done && vcmp(ver, nv) < 0) { print newblock; done = 1 }
    }
    NF { seen = 1 }
    seen { print }                       # drop leading blank lines
    END { if (!done) print newblock }
  ' "$COMPAT" > "$tmp"
  mv "$tmp" "$COMPAT"
  printf 'added %s entry for %s (cloned from %s)\n' "$COMPAT" "$NEW" "$BASE"
fi

# ---------------------------------------------------------------------------
# 3. Scaffold the release-notes page from the Hugo archetype.
# ---------------------------------------------------------------------------
DASHED=$(printf '%s' "$NEW" | tr '.' '-')
RELNOTES=content/releases/$DASHED.md
if [ -f "$RELNOTES" ]; then
  printf 'skip release notes: %s already exists\n' "$RELNOTES"
elif ! command -v hugo >/dev/null 2>&1; then
  printf 'WARNING: hugo not found; run  hugo new %s  manually\n' "$RELNOTES"
else
  hugo new "$RELNOTES" >/dev/null
  printf 'scaffolded %s (archetypes/releases.md)\n' "$RELNOTES"
fi

# ---------------------------------------------------------------------------
# 4. Placeholder checksums file (the checksums shortcode readFile()s this,
#    so the build breaks without it). Replace with the real digests later.
# ---------------------------------------------------------------------------
CHECKSUMS=static/checksums/v$NEW-checksums.txt
if [ -f "$CHECKSUMS" ]; then
  printf 'skip checksums: %s already exists\n' "$CHECKSUMS"
else
  printf 'For checksums for %s, check with your Rhize contact.\n' "$NEW" > "$CHECKSUMS"
  printf 'wrote placeholder %s\n' "$CHECKSUMS"
fi

# ---------------------------------------------------------------------------
cat <<EOF

Done ($FLOW). Next steps:
  - Review: git status && git diff
  - Update the "$NEW" block in $COMPAT if any third-party versions changed.
  - Fill in the "Changes by service" sections in $RELNOTES.
  - Replace the placeholder in $CHECKSUMS with the real digests.
EOF

if [ "$FLOW" = backport ]; then
  cat <<EOF
  - Backport: the release-note 'weight' is auto-set as if this were the
    newest release. Adjust it to sit between $BASE and the next version up.
  - Backport: sanity-check $TARGET_TREE for any hard-coded "$BASE" strings.
EOF
fi
