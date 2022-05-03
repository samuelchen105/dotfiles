###########
# For Mac #
###########

if [[ "$OSTYPE" == "darwin"* ]]; then
  # homebrew
  eval "$(/opt/homebrew/bin/brew shellenv)"

  # The next line updates PATH for the Google Cloud SDK.
  if [ -f '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'; fi

  # The next line enables shell command completion for gcloud.
  if [ -f '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'; fi
fi

# append golang to path
export PATH=$PATH:/usr/local/go/bin

# append $GOPATH/bin to path
export PATH=$PATH:$(go env GOPATH)/bin
