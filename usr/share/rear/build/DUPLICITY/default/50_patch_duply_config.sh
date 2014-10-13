#
# adapt duply TMP_DIR setting

# Patch all copied duply configs:
# - let duply use globel TEMP_DIR variable.

# important for the [n] hack below because we want non-existant patterns to simply disappear
shopt -s nullglob
DUPLY_PROFILE_FILES=$( find /etc/duply /root/.duply -name conf 2>/dev/null)
if test "$DUPLY_PROFILE_FILES" ; then
  grep -qE "^TEMP_DIR=\\$\{TMPDIR:-" /etc/duply/*/conf || \
    sed -ie "s/^#\?TEMP_DIR=\(.*\)$/TEMP_DIR=\${TMPDIR:-\1}/" $DUPLY_PROFILE_FILES
else
	Log "WARNING: duply profile file(s) missing"
fi