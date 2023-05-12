# ============================================================================================
# Homebrew
# ============================================================================================

if [[ "$OSTYPE" == "darwin"* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ============================================================================================
# Golang
# ============================================================================================

# append golang to path (if not installed by package manager)
# export PATH=$PATH:/usr/local/go/bin

# append $GOPATH/bin to path
if command -v go &> /dev/null; then
  export PATH=$PATH:$(go env GOPATH)/bin
fi

# ============================================================================================
# Google Cloud SDK
# ============================================================================================

# enable kubectl new gcloud auth plugin
# export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# ============================================================================================
# Auto Generated Below...
# ============================================================================================
