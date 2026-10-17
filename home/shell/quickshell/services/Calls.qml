pragma Singleton

import QtQuick
import Quickshell
import "Contacts.js" as Contacts

// Incoming calls from any messenger, shown as the game's holocall. Apps that
// follow the notification spec tag them call.incoming. Discord has no call
// notification at all: a call only shows up as the message notification of
// the DM's call message, "<name> started a call." / "<name> a commencé un
// appel.", so that text is matched, plus the usual "is calling you" wordings.
// A call rings until its app closes the notification (Discord does when its
// window opens that DM), the app's window gets the focus, a call.ended /
// missed call notification of the same app comes in, it is answered or
// ignored, or 45 s pass: Discord never says the caller hung up.
//
// The holocall simulator rides on the same window: the contacts of the game
// (Contacts.js) call in now and then, or get called from the PHONE, and talk
// through their scripts in subtitles, with dialogue choices.
Singleton {
  id: calls

  property bool active: false
  // ringing, dialing (outgoing), connected or ended
  property string phase: "ringing"
  readonly property bool ringing: active && phase === "ringing"
  // a contact of the simulator rather than a real call
  property bool simulated: false
  property var contact: null
  property bool outgoing: false
  // the subtitle on screen and who says it ("V" for you)
  property string speaker: ""
  property string line: ""
  property var choices: []
  property var script: null
  property var node: null
  property var pending: null
  // null for a test call
  property var notification: null
  property string caller: ""
  property string app: ""
  property string entry: ""
  property string image: ""
  property string appIcon: ""
  property var actions: []
  property real since: 0

  readonly property var ringWords: /incoming (?:voice |video |audio )?call|(?:is )?calling you|is calling|appel (?:vocal |audio |vid[ée]o )?entrant|vous appelle|t['’]appelle/i
  readonly property var endWords: /missed (?:voice |video )?call|call ended|appel (?:vocal |vid[ée]o )?manqu[ée]|appel termin[ée]/i
  // anchored at the end: "started a call that lasted 5 minutes." is history, not a ring
  readonly property var discordRing: /\s(?:started a call|a commenc[ée] un appel)\.?\s*$/i

  function category(n) {
    return n.hints && n.hints.category ? String(n.hints.category) : ""
  }

  function text(n) {
    return (n.summary || "") + "\n" + (n.body || "")
  }

  function isDiscordRing(n) {
    const sender = (n.appName || "") + " " + (n.desktopEntry || "")
    return /discord/i.test(sender) && discordRing.test(n.body || "")
  }

  function isCall(n) {
    const c = category(n)
    if (c === "call.incoming") return true
    if (c === "call.ended" || c === "call.unanswered") return false
    if (isDiscordRing(n)) return true
    // whatever the category: messengers file their calls under im.* too
    return ringWords.test(text(n)) && !endWords.test(text(n))
  }

  function isHangUp(n) {
    const c = category(n)
    return c === "call.ended" || c === "call.unanswered" || endWords.test(text(n))
  }

  // "Jackie Welles is calling you" -> "Jackie Welles"; for Discord the body
  // names the caller, the summary of a group DM is "Name (Group)"
  function callerOf(n) {
    if (isDiscordRing(n))
      return (n.body || "").replace(discordRing, "").trim() || (n.summary || "").replace(/\s*\([^)]*\)\s*$/, "") || "UNKNOWN"
    const words = new RegExp(ringWords.source, "ig")
    const clean = s => s.replace(words, "").replace(/^[\s:—–\-·|]+|[\s:—–\-·|.!…]+$/g, "")
    return clean(n.summary || "") || clean(n.body || "") || n.appName || "UNKNOWN"
  }

  function ring(n) {
    // a real call cuts any simulated one
    step.stop()
    simulated = false
    contact = null
    choices = []
    line = ""
    phase = "ringing"
    notification = n
    caller = callerOf(n)
    app = n.appName || ""
    entry = n.desktopEntry || ""
    image = n.image || ""
    appIcon = n.appIcon ? Quickshell.iconPath(n.appIcon, true) : ""
    actions = n.actions || []
    start()
  }

  // a contact of the simulator calls in; by name or id, anyone when empty
  function test(name) {
    const wanted = String(name || "").toLowerCase()
    const c = Contacts.contacts.find(k => k.id === wanted || k.name.toLowerCase() === wanted || k.name.toLowerCase().indexOf(wanted) === 0)
    incoming(c ? c.id : randomContact().id)
  }

  function randomContact() {
    // Johnny is rare: the wall does not open often
    const pool = Contacts.contacts.filter(k => k.id !== "johnny" || Math.random() < 0.15)
    return pool[Math.floor(Math.random() * pool.length)]
  }

  function simulate(id, out) {
    if (active) stop()
    const c = Contacts.find(id)
    if (!c) return
    notification = null
    simulated = true
    contact = c
    outgoing = out
    caller = c.name
    app = out ? "" : "HOLOCALL"
    entry = ""
    image = ""
    appIcon = ""
    actions = []
    speaker = ""
    line = ""
    choices = []
    phase = out ? "dialing" : "ringing"
    start()
    if (out) after(2200 + Math.random() * 2400, connect)
  }

  function incoming(id) {
    simulate(id, false)
  }

  function dial(id) {
    simulate(id, true)
  }

  function start() {
    since = Date.now()
    active = true
    if (phase === "ringing") timeout.restart()
  }

  // what the scripts know about the deck
  function context() {
    const hour = new Date().getHours()
    return {
      hour: hour,
      part: hour < 5 ? "NIGHT" : hour < 12 ? "MORNING" : hour < 18 ? "AFTERNOON" : hour < 22 ? "EVENING" : "NIGHT",
      late: hour < 5 || hour >= 23,
      weather: Weather.ready ? Weather.condition : "",
      temp: Weather.temp,
      unit: Settings.tempUnit,
      place: Weather.place,
      eddies: Stats.format(Stats.eddies),
      breaches: Stats.breaches,
      cpu: Math.round(Sys.cpu * 100),
      notifs: Notifs.count,
      uptimeDays: Sys.uptime.indexOf("D") > 0 ? parseInt(Sys.uptime) : 0,
      os: Theme.osInfo.name || "CYBERDECK"
    }
  }

  function say(value) {
    return typeof value === "function" ? value(context()) : String(value)
  }

  // the next step of the conversation, after the line had time to be read
  function after(ms, fn) {
    pending = fn
    step.interval = ms
    step.restart()
  }

  function readTime(text) {
    return 1500 + text.length * 48
  }

  // ANSWER on a simulated ring, or the other end picking up
  function connect() {
    if (!active || !simulated) return
    timeout.stop()
    phase = "connected"
    since = Date.now()
    Sounds.play("menu-open")
    const c = context()
    const fit = contact.scripts.filter(s => !s.when || s.when(c))
    script = (fit.length > 0 ? fit : contact.scripts)[Math.floor(Math.random() * (fit.length > 0 ? fit.length : contact.scripts.length))]
    after(700, () => go("start"))
  }

  function go(id) {
    node = script.nodes[id]
    if (!node) return hangUp()
    speaker = contact.name
    line = say(node.say)
    choices = []
    const wait = readTime(line)
    if (node.choices) after(Math.min(wait, 2600), () => { choices = node.choices.map(o => say(o.text)) })
    else if (node.end) after(wait + 600, hangUp)
    else after(wait, () => go(node.then))
  }

  // V answers with the picked line, the contact goes on from there
  function choose(index) {
    if (!node || !node.choices || index < 0 || index >= node.choices.length || choices.length === 0) return
    const option = node.choices[index]
    Sounds.play("click")
    choices = []
    speaker = "V"
    line = say(option.text)
    after(readTime(line) - 300, () => go(option.next))
  }

  // a click on the subtitle skips the wait, not a choice
  function skip() {
    if (step.running) {
      step.stop()
      const fn = pending
      pending = null
      if (fn) fn()
    }
  }

  function hangUp() {
    if (!active) return
    phase = "ended"
    choices = []
    speaker = ""
    line = ""
    Sounds.play("menu-close")
    after(1600, stop)
  }

  // DECLINE: the contact takes it badly, by text
  function decline() {
    if (simulated && contact && phase === "ringing") sms(contact.declined)
    stop()
  }

  // a text message from the contact, through the notification server
  function sms(body) {
    if (!contact || !body) return
    Quickshell.execDetached(["notify-send", "--app-name=PHONE", "--icon=phone", contact.name, body])
  }

  // a call.ended or missed call of the app that is ringing
  function hangUpOn(n) {
    if (active && isHangUp(n) && (n.appName || "") === app) stop()
  }

  // invoking closes the notification, which takes its actions with it: stop first
  function answer(action) {
    stop()
    action.invoke()
  }

  // stops the deck ringing; the app keeps its own call window
  function stop() {
    active = false
    notification = null
    actions = []
    timeout.stop()
    step.stop()
    pending = null
    simulated = false
    choices = []
    line = ""
    phase = "ringing"
  }

  // the window of the ringing app, by its niri app_id
  function isAppWindow(w) {
    const id = w && w.app_id ? String(w.app_id).toLowerCase() : ""
    return id !== "" && (id === entry.toLowerCase() || id === app.toLowerCase())
  }

  // Quickshell lists a notification only after onNotification returns, so the
  // list cannot tell a closed call from a new one: its closed signal can
  Connections {
    target: calls.notification
    ignoreUnknownSignals: true
    function onClosed(reason) { calls.stop() }
  }

  // going to the app to pick up silences the deck
  Connections {
    target: Niri
    function onFocusedWindowIdChanged() {
      if (calls.active && calls.isAppWindow(Niri.focusedWindow)) calls.stop()
    }
  }

  // a simulated call nobody picks up leaves a text behind
  Timer {
    id: timeout
    interval: 45000
    onTriggered: {
      if (calls.simulated && calls.phase === "ringing") calls.sms(calls.contact.missed)
      calls.stop()
    }
  }

  Timer {
    id: step
    onTriggered: {
      const fn = calls.pending
      calls.pending = null
      if (fn) fn()
    }
  }

  // now and then a contact calls on their own, never over CAMO or a lock
  Timer {
    id: random
    running: Settings.randomCalls
    repeat: true
    interval: calls.nextGap()
    onTriggered: {
      interval = calls.nextGap()
      if (!calls.active && !Lock.locked && !Hud.dnd && !Hud.breachOpen) calls.incoming(calls.randomContact().id)
    }
  }

  // minutes between random calls, around the picked frequency
  function nextGap() {
    const base = Settings.callFrequency === "often" ? 20 : Settings.callFrequency === "sometimes" ? 50 : 110
    return Math.round(base * (0.6 + Math.random() * 0.8) * 60000)
  }
}
