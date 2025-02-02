typeset -U path PATH
path=(
    /opt/homebrew/bin
    /opt/homebrew/sbin
    /usr/local/bin
    /usr/bin
    /bin
    /usr/sbin
    /sbin
    $path
)
export PATH

# Ensure Homebrew is initialized early in login shell
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi