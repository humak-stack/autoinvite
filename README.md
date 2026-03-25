# AutoInvite (redux)
**Version 0.5 — World of Warcraft 1.12 Addon**

Automatically invite players who whisper or type a keyword in guild chat. Supports comma-separated keyword lists, two matching modes, party/raid auto-management, and bulk invite lists.

---

## Features

- **Whisper scanning** — invite anyone who whispers a matching keyword
- **Guild chat scanning** — optionally scan guild chat for the same keywords
- **Comma-separated keyword lists** — set multiple keywords in one command
- **Exists mode** — match keyword anywhere in the message
- **Exact mode** — only match if the entire message equals the keyword
- **Party & Raid support** — auto-converts party to raid when full
- **A-List / B-List** — bulk invite predefined priority player lists
- **Per-character settings** — saved per realm and character name

---

## Installation

1. Place the `AutoInvite` folder in your `World of Warcraft\Interface\AddOns\` directory
2. The folder must contain: `AutoInvite.lua`, `AutoInvite.xml`, `AutoInvite.toc`, `PriorityList.lua`
3. Launch WoW 1.12 and enable the addon at the character select screen
4. Type `/ai` in-game to confirm it loaded

---

## Slash Commands

All commands use `/AutoInvite` or the shorthand `/ai`.

### General

| Command | Description |
|---------|-------------|
| `/ai` or `/ai status` | Show current status and all settings |
| `/ai on` | Enable automatic inviting |
| `/ai off` | Disable automatic inviting |
| `/ai party` | Set group type to 5-man party |
| `/ai raid` | Set group type to 40-man raid |

### Keyword Modes

| Command | Description |
|---------|-------------|
| `/ai exists <keywords>` | Match keyword anywhere in the message |
| `/ai exact <keywords>` | Message must exactly equal the keyword |

### Guild Chat

| Command | Description |
|---------|-------------|
| `/ai guild on` | Start scanning guild chat for keywords |
| `/ai guild off` | Stop scanning guild chat |

### Bulk Invite

| Command | Description |
|---------|-------------|
| `/ai alist` | Invite everyone in the A-List (up to 50 players) |
| `/ai blist` | Invite everyone in the B-List (up to 39 players) |

---

## Keyword Matching

### Exists Mode
The keyword is searched for anywhere inside the message. Case-insensitive.

```
/ai exists inv,inv me,come
```

| Message received | Result |
|-----------------|--------|
| `inv` | ✅ Match |
| `inv me please` | ✅ Match |
| `invite` | ✅ Match (contains `inv`) |
| `can i get an invite` | ✅ Match |

### Exact Mode
The entire message must equal one of the keywords exactly. Case-insensitive.

```
/ai exact inv,inv me
```

| Message received | Result |
|-----------------|--------|
| `inv` | ✅ Match |
| `inv me` | ✅ Match |
| `inv me please` | ❌ No match |
| `invite` | ❌ No match |

### Multi-Word Phrases
Both modes support multi-word phrases. The comma is the only delimiter — spaces are not split on.

```
/ai exists harder daddy,i have a small dick,masturbatorium
```

### Case Sensitivity
All matching is case-insensitive. `INV`, `Inv`, and `inv` are all treated the same.

---

## Party & Raid Logic

### Party Mode (`/ai party`)
- Invites if you are party leader and party has fewer than 4 members
- Invites freely if not yet in a group
- Rejects if party is full

### Raid Mode (`/ai raid`)
- Invites freely if not in a group
- Invites if party leader with fewer than 4 members
- Auto-converts party to raid when the 5th invite is triggered
- Invites as raid leader or officer if already in a raid under 40
- Rejects if raid is full or you lack leader/officer rank

---

## Priority Lists (A-List / B-List)

Edit `PriorityList.lua` to define your priority players. The addon will invite them in order and handle party-to-raid conversion automatically.

```
/ai alist    -- invite A-List (up to 50 players)
/ai blist    -- invite B-List (up to 39 players)
```

---

## Guild Chat Scanning

Guild chat scanning is **off by default**. When enabled, the same keyword list and mode used for whispers applies to guild chat. The setting persists across sessions and is restored automatically on login.

```
/ai guild on
/ai guild off
```

---

## Quick Reference

```
/ai                   show status
/ai on / off          enable or disable
/ai exists <list>     set exists-mode keywords (comma-separated)
/ai exact <list>      set exact-mode keywords (comma-separated)
/ai guild on / off    toggle guild chat scanning
/ai party / raid      set group type
/ai alist             bulk invite A-List
/ai blist             bulk invite B-List
```
