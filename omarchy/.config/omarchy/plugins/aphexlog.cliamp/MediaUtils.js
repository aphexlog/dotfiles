// ==============================================================================
// Player Selection and Display Metadata
// ==============================================================================

// Match Cliamp's own bus name even when other music apps are also playing.
function selectPlayer(players) {
  var first = null
  for (var i = 0; i < players.length; i++) {
    var player = players[i]
    if (!player || !/^org\.mpris\.MediaPlayer2\.cliamp(?:\.|$)/.test(String(player.dbusName || ""))) continue
    if (player.isPlaying) return player
    if (!first) first = player
  }
  return first
}

function cleanText(value) {
  return String(value || "").slice(0, 512).replace(/[\u0000-\u001f\u007f]/g, " ")
}

// Waybar tooltips interpret Pango markup independently of escape:true labels.
function escapeMarkup(value) {
  return cleanText(value).replace(/&/g, "&amp;").replace(/</g, "&lt;")
    .replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&apos;")
}

function waybarStatus(connected, state, title, artist, controls) {
  return {
    text: "Cliamp",
    tooltip: "Cliamp" + (connected && title ? "\n" + escapeMarkup(title) : "")
      + (connected && artist ? " — " + escapeMarkup(artist) : "")
      + "\n" + escapeMarkup(controls),
    "class": !connected ? "idle" : state === "playing" ? "playing" : state === "paused" ? "paused" : "stopped"
  }
}
