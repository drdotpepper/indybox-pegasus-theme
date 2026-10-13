.pragma library

// Palette, taken from the indybox.games stylesheet
var bg     = "#000000";
var fg     = "#f3f2ee";
var muted  = "#8c8b87";
var line   = "#2b2b29";
var plate  = "#0f0f0e";
var accent = "#ff7a00";   // orange: dot on the "i", hover/focus fill
var green  = "#6fcf4a";   // from the pixel burger icon

// Grid menu: dark navy backdrop and unselected tile panels
var navy      = "#06090d";
var panelFill = "#080f16";
var panelLine = "#535656";

// Colours the bouncing venue tag cycles through on each wall hit
var bounceColors = [accent, green, fg];

function upper(s) {
    return (s === undefined || s === null) ? "" : String(s).toUpperCase();
}

// Steam/itch data often already says "By Somebody"; we add our own "BY " label,
// so drop a leading "by " to avoid "BY BY SOMEBODY".
function cleanDev(s) {
    if (s === undefined || s === null) return "";
    return String(s).replace(/^\s*by\s+/i, "");
}

function playersLabel(n) {
    n = n || 1;
    return n > 1 ? ("1-" + n + " PLAYERS") : "1 PLAYER";
}

// Accepts https://, file:// or a plain Windows/Unix path (for x-qr in metadata)
function fileUrl(p) {
    if (!p) return "";
    p = String(p);
    if (/^(file|https?|qrc):/i.test(p)) return p;
    if (/^[A-Za-z]:[\\\/]/.test(p)) return "file:///" + p.replace(/\\/g, "/");
    if (p.charAt(0) === "/") return "file://" + p;
    return p;
}

// Safe read of a custom "x-something" field from game metadata
function extra(game, key) {
    return (game && game.extra && game.extra[key]) ? game.extra[key] : "";
}

// Best available picture for a game, most "screen-like" first
function shot(game) {
    if (!game || !game.assets) return "";
    var a = game.assets;
    return a.screenshot || a.titlescreen || a.background || a.banner || a.boxFront || "";
}
