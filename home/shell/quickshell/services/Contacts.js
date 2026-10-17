.pragma library

// The phone book of the holocall simulator. Each contact has scripts: nodes
// keyed by id, played from "start". A node says a line (a string, or a
// function of the live context `c`), then goes to `then`, offers `choices`
// ({ text, next }), or ends the call. `when` keeps a script for the moments it
// fits. The context: c.part (MORNING...), c.late, c.weather, c.temp, c.unit,
// c.eddies, c.breaches, c.cpu, c.notifs, c.uptimeDays, c.os, c.place.

function pick(list) {
  return list[Math.floor(Math.random() * list.length)]
}

var contacts = [
  {
    id: "jackie", name: "JACKIE WELLES", role: "MERC // HEYWOOD", tone: "warn", monogram: "JW",
    missed: "Call me back, choom. Got somethin' preem lined up.",
    declined: "Busy, huh? A'ight, a'ight. Mama Welles is cookin' tonight if you change your mind.",
    scripts: [
      {
        nodes: {
          start: { say: c => c.late ? "Hey V, still up? Course you are. Night City don't sleep, why should we?" : "V! Mi amigo! Good " + c.part.toLowerCase() + ", choom.", then: "pitch" },
          pitch: { say: "Listen, Dex called. Says he's got a job, big one. The kind that puts us in the major leagues.", choices: [
            { text: "I'm listening.", next: "in" },
            { text: "Last time Dex had a 'big one' we nearly flatlined.", next: "doubt" },
            { text: "Not today, Jackie.", next: "no" }
          ] },
          in: { say: "Knew it! Meet me at Lizzie's. And V... wear somethin' nice. We're gonna be legends.", end: true },
          doubt: { say: "Nearly. Nearly's the key word, V. We walked out, didn't we? Think about it. Call me.", end: true },
          no: { say: "Your loss, choom. Mama's empanadas are still on, though. Don't make me eat 'em all alone.", end: true }
        }
      },
      {
        nodes: {
          start: { say: c => "Hey V, you seein' this weather? " + (c.weather ? c.weather.toLowerCase() + ", " + c.temp + "°" + c.unit + "." : "Can't even tell anymore.") + " Perfect day for a ride.", choices: [
            { text: "Where to?", next: "where" },
            { text: "I'd rather stay in.", next: "stay" }
          ] },
          where: { say: "Badlands. Open road, no NCPD, maybe a coyote or two. Bring snacks.", end: true },
          stay: { say: "Suit yourself. Gonna go show Misty my new ride then. She'll pretend she's not impressed.", end: true }
        }
      }
    ]
  },
  {
    id: "judy", name: "JUDY ALVAREZ", role: "BD TECHIE // MOX", tone: "secondary", monogram: "JA",
    missed: "Hey, it's Judy. Got a BD you gotta see. Call me.",
    declined: "Okay, okay. Ping me when you're free.",
    scripts: [
      {
        nodes: {
          start: { say: "Hey V. You busy? I just finished editing a braindance. Raw, no filters. I need a second pair of eyes.", choices: [
            { text: "What's on it?", next: "what" },
            { text: "Your edits are always flawless, Judy.", next: "flatter" }
          ] },
          what: { say: "Diving off Laguna Bend. The old town under the water... I wanted someone to see it the way I do.", then: "invite" },
          flatter: { say: "Flattery, huh? Gonna cost you a beer at Lizzie's. Seriously though, come by. I want you to feel it.", then: "invite" },
          invite: { say: c => c.late ? "It's late, I know. The Mox don't sleep either. Door's open." : "Lizzie's, back room. Bring nothing, just your head.", end: true }
        }
      },
      {
        nodes: {
          start: { say: c => "Hey, I tuned your optics feed through my rig. That " + c.os + " palette? Not bad. Who picked those colours?", choices: [
            { text: "I did.", next: "you" },
            { text: "The deck did. It reads the wallpaper.", next: "deck" }
          ] },
          you: { say: "Huh. Didn't peg you for an artist. Keep surprising me, V.", end: true },
          deck: { say: "A colour algorithm reading the wallpaper? That's... actually really clever. Send me the code sometime.", end: true }
        }
      }
    ]
  },
  {
    id: "panam", name: "PANAM PALMER", role: "NOMAD // ALDECALDOS", tone: "alt", monogram: "PP",
    missed: "V, it's Panam. Call me back. Now.",
    declined: "Fine. I'll handle it myself. Like always.",
    scripts: [
      {
        nodes: {
          start: { say: "V. Need a favor. Raffen Shiv took something of mine, and I want it back. Tonight.", choices: [
            { text: "What did they take?", next: "what" },
            { text: "I'm in. Send me the coords.", next: "in" },
            { text: "Can it wait?", next: "wait" }
          ] },
          what: { say: "My car. My car, V. Nobody steals from Panam Palmer and keeps driving.", then: "in" },
          in: { say: "Knew I could count on you. Sunset Motel, an hour. Bring something with a big magazine.", end: true },
          wait: { say: "It can't. But fine, I'll go alone. If I'm not back, tell Saul it was his fault.", end: true }
        }
      }
    ]
  },
  {
    id: "rogue", name: "ROGUE AMENDIARES", role: "FIXER // THE AFTERLIFE", tone: "danger", monogram: "RA",
    missed: "Rogue. I don't call twice.",
    declined: "Your call, merc. Plenty of others want this one.",
    scripts: [
      {
        nodes: {
          start: { say: c => "Merc. Heard you're sitting on €$ " + c.eddies + ". Not bad. Not enough to get noticed at the Afterlife, though.", choices: [
            { text: "What's the job?", next: "job" },
            { text: "I get noticed just fine.", next: "cocky" }
          ] },
          job: { say: "Arasaka convoy, Corpo Plaza, no witnesses. Clean in, clean out. Pays well enough to change your life.", then: "close" },
          cocky: { say: "Cocky. I like that. It's also how most legends end up as drink names. There's a job, if you want it.", then: "close" },
          close: { say: "Details are on your shard. Don't make me regret calling.", end: true }
        }
      }
    ]
  },
  {
    id: "regina", name: "REGINA JONES", role: "FIXER // WATSON", tone: "ok", monogram: "RJ",
    missed: "Regina here. Cyberpsycho sighting in Watson. Call me.",
    declined: "Understood. I'll find someone else for this one.",
    scripts: [
      {
        when: c => c.cpu >= 70,
        nodes: {
          start: { say: c => "V, NCPD scanners are lighting up. Something's running hot on your deck, " + c.cpu + "% synapse load. Cyberpsychos have started that way.", choices: [
            { text: "I'll find what's burning.", next: "fix" },
            { text: "It's just a compile, Regina.", next: "compile" }
          ] },
          fix: { say: "Good. Try qh overheat. And V... no casualties, if you can help it.", end: true },
          compile: { say: "A compile. Of course it is. Keep an eye on it anyway.", end: true }
        }
      },
      {
        nodes: {
          start: { say: "V. Got a cyberpsycho holed up in Kabuki. Non-lethal, I want them alive. Trauma Team won't touch it.", choices: [
            { text: "Non-lethal. Got it.", next: "ok" },
            { text: "Why do you care so much?", next: "why" }
          ] },
          why: { say: "Because they're people, V. People who got lost in their chrome. Someone has to bring them back.", then: "ok" },
          ok: { say: "I'm sending the location. Be careful. They won't be.", end: true }
        }
      }
    ]
  },
  {
    id: "wakako", name: "WAKAKO OKADA", role: "FIXER // WESTBROOK", tone: "tertiary", monogram: "WO",
    missed: "Wakako. A gig awaits. Do not keep an old woman waiting.",
    declined: "Hm. Patience is a virtue I no longer have.",
    scripts: [
      {
        nodes: {
          start: { say: c => "V-san. Your inbox overflows with " + c.notifs + " unread messages. A disorganized merc is a dead merc.", choices: [
            { text: "I'll clean it up.", next: "ok" },
            { text: "Was there a gig, or...?", next: "gig" }
          ] },
          ok: { say: "Good. Then come to my parlor. Bring tea. The good kind.", end: true },
          gig: { say: "Impatient. Like all the young. Tyger Claws are moving product through Japantown. I want it stopped.", end: true }
        }
      }
    ]
  },
  {
    id: "viktor", name: "VIKTOR VEKTOR", role: "RIPPERDOC // WATSON", tone: "ok", monogram: "VV",
    missed: "Kid, it's Vik. Swing by when you can.",
    declined: "Alright, alright. The clinic's not going anywhere.",
    scripts: [
      {
        when: c => c.uptimeDays >= 3,
        nodes: {
          start: { say: c => "Kid. Your deck's been running " + c.uptimeDays + " days straight. Even chrome needs to rest.", choices: [
            { text: "I'll reboot tonight. Promise.", next: "ok" },
            { text: "It runs fine, Vik.", next: "fine" }
          ] },
          ok: { say: "Good. And eat something that didn't come out of a vending machine.", end: true },
          fine: { say: "That's what they all say. Right before they end up on my table. Reboot it, kid.", end: true }
        }
      },
      {
        nodes: {
          start: { say: "Kid, how's the new chrome settling in? Any headaches, glitches, voices?", choices: [
            { text: "All good, doc.", next: "good" },
            { text: "...Voices?", next: "voices" }
          ] },
          good: { say: "Glad to hear it. Come by for a checkup anyway. Misty made tea.", end: true },
          voices: { say: "That was a joke. ...Mostly. Come see me, kid. Today.", end: true }
        }
      }
    ]
  },
  {
    id: "delamain", name: "DELAMAIN", role: "AI // DELAMAIN CAB", tone: "primary", monogram: "DL",
    missed: "Delamain here. I trust you are well. Do not hesitate to call for transport.",
    declined: "Very well. Delamain remains at your disposal.",
    scripts: [
      {
        nodes: {
          start: { say: c => "Good " + c.part.toLowerCase() + ". Delamain here. Current conditions in " + (c.place || "Night City") + ": " + (c.weather ? c.weather.toLowerCase() + ", " + c.temp + "°" + c.unit : "unknown") + ". May I offer transport?", choices: [
            { text: "Take me to the Afterlife.", next: "afterlife" },
            { text: "Just checking in, Delamain.", next: "check" }
          ] },
          afterlife: { say: "An excellent choice. A vehicle is on its way. Please refrain from discharging firearms inside the cab.", end: true },
          check: { say: c => "How thoughtful. All my vehicles are operational. Well... nearly all of them. Have a pleasant " + c.part.toLowerCase() + ".", end: true }
        }
      }
    ]
  },
  {
    id: "misty", name: "MISTY OLSZEWSKI", role: "ESOTERICA // WATSON", tone: "tertiary", monogram: "MO",
    missed: "The cards wanted to talk to you. Call me back.",
    declined: "The cards say you're busy. They're rarely wrong.",
    scripts: [
      {
        nodes: {
          start: { say: "V, I drew a card for you this morning. Want to hear it?", choices: [
            { text: "Sure, read it.", next: "card" },
            { text: "I don't believe in tarot.", next: "skeptic" }
          ] },
          card: { say: () => pick([
            "The Fool. A new journey, a leap into the unknown. Look before you jump. Or don't.",
            "The Tower. Something you built is about to fall. Maybe that's a good thing.",
            "The Star. Hope, after a long night. Hold onto it.",
            "Death. Don't panic. It means change, not the end. Usually.",
            "The Lovers. A choice of the heart is coming. Choose honestly.",
            "The Hermit. Time to look inward. Turn off the screens for a while.",
            "Wheel of Fortune. Luck turns. Be ready when it turns your way."
          ]), end: true },
          skeptic: { say: "That's okay. The cards believe in you. That's what counts.", end: true }
        }
      }
    ]
  },
  {
    id: "johnny", name: "JOHNNY SILVERHAND", role: "ROCKERBOY // ???", tone: "danger", monogram: "JS", glitch: true,
    missed: "Ignorin' me? Cute. I live in your head, V.",
    declined: "Hang up all you want. I'm not going anywhere.",
    scripts: [
      {
        nodes: {
          start: { say: "Wake up, samurai. We have a city to burn.", choices: [
            { text: "Johnny? How are you calling me?", next: "how" },
            { text: "Get out of my deck.", next: "out" },
            { text: "What do you want?", next: "want" }
          ] },
          how: { say: "Your deck's a sieve, V. Blackwall's got more holes than Arasaka's conscience.", then: "want" },
          out: { say: "Your deck? Cute. I was here first, technically.", then: "want" },
          want: { say: c => c.breaches > 0 ? "Saw your breach scores. " + c.breaches + " runs. Not bad. Now point that deck at Arasaka Tower." : "To see you do somethin' that matters. Start by breachin' somethin'. Anything.", choices: [
            { text: "Not happening.", next: "end" },
            { text: "...Let's talk about it.", next: "talk" }
          ] },
          end: { say: "Never fade away, V. Never fade away.", end: true },
          talk: { say: "Now we're talkin'. Grab your gear. And somethin' to smoke.", end: true }
        }
      }
    ]
  }
]

function find(id) {
  for (var i = 0; i < contacts.length; i++) if (contacts[i].id === id) return contacts[i]
  return null
}
