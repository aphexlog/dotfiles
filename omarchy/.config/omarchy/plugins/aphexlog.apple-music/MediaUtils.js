// ==============================================================================
// Player Selection and Display Metadata
// ==============================================================================

function cleanText(value) {
  return String(value || "").slice(0, 512).replace(/[\u0000-\u001f\u007f]/g, " ")
}

function appleUrl(value) {
  return /^https:\/\/music\.apple\.com(?:[/?#]|$)/i.test(String(value || ""))
}

function appleArtwork(value) {
  var url = String(value || "")
  return url.length <= 2048 && /^https:\/\/(?:[a-z0-9-]+\.)*mzstatic\.com\//i.test(url) ? url : ""
}

function isBrowser(player) {
  return /chrom|brave|vivaldi|firefox|edge|opera|helium/i.test(
    String(player.identity || "") + " " + String(player.desktopEntry || ""))
}

function isApplePlayer(player) {
  if (!player) return false
  var identity = String(player.identity || "") + " " + String(player.desktopEntry || "")
  if (/(^|[\s._-])(cider|apple[\s._-]?music)([\s._-]|$)/i.test(identity)) return true
  var metadata = player.metadata || {}
  if (appleUrl(metadata["xesam:url"])) return true
  // Chromium does not always expose the page URL. Apple's artwork identifies
  // its media session without falling back to an arbitrary playing browser tab.
  return isBrowser(player) && appleArtwork(player.trackArtUrl) !== ""
}

function selectPlayer(players) {
  var first = null
  for (var i = 0; i < players.length; i++) {
    var player = players[i]
    if (!isApplePlayer(player)) continue
    if (player.isPlaying) return player
    if (!first) first = player
  }
  return first
}

// Waybar tooltips use Pango markup; label text is escaped by the module itself.
function escapeMarkup(value) {
  return cleanText(value).replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
}

function waybarStatus(player, controls) {
  var title = player ? cleanText(player.trackTitle) : ""
  var artist = player ? cleanText(player.trackArtist) : ""
  var playing = !!(player && player.isPlaying)
  return {
    text: "󰀵  " + (title ? (playing ? "󰏤 " : "󰐊 ") + title : "Apple Music"),
    tooltip: "Apple Music" + (title ? "\n" + escapeMarkup(title) : "")
      + (artist ? " — " + escapeMarkup(artist) : "") + "\n" + escapeMarkup(controls),
    "class": player ? (playing ? "playing" : "paused") : "idle"
  }
}
