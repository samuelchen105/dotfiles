# === Configurations ===

# Setup theme
source $"($nu.default-config-dir)/themes/default.nu"
$env.config.highlight_resolved_externals = true

# Setup config
$env.config.table = {
  mode: "light"
  index_mode: "auto"
}
$env.config.hooks.display_output = { table }

$env.config.shell_integration = {
  osc8: false # disables underlined clickable file links
}