# AutoInvite (redux)
**Version 0.5 — World of Warcraft 1.12 Addon**

Automatically invite players who whisper or type a keyword in guild chat. Supports comma-separated keyword lists, two matching modes, party/raid auto-management, VIP auto-promotion, auto raid conversion, and bulk invite lists.

---

## Features

- **Whisper scanning** — invite anyone who whispers a matching keyword
- **Guild chat scanning** — optionally scan guild chat for the same keywords
- **Comma-separated keyword lists** — set multiple keywords in one command
- **Exists mode** — match keyword anywhere in the message
- **Exact mode** — only match if the entire message equals the keyword
- **Both modes active simultaneously** — exists and exact lists work independently at the same time
- **VIP list** — automatically promote specific players to raid assistant when they join
- **Auto-raid conversion** — automatically convert party to raid when any member joins, if you are leader
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

Both lists are always active at the same time. A message only needs to match either list to trigger an invite.

| Command | Description |
|---------|-------------|
| `/ai exists <keywords>` | Set exists-mode keywords (comma-separated) |
| `/ai exact <keywords>` | Set exact-mode keywords (comma-separated) |

### Guild Chat

| Command | Description |
|---------|-------------|
| `/ai guild on` | Start scanning guild chat for keywords |
| `/ai guild off` | Stop scanning guild chat |
| `/ai guild toggle` | Toggle guild chat scanning — macro friendly |

### Auto-Raid Conversion

| Command | Description |
|---------|-------------|
| `/ai autoraid on` | Enable auto party-to-raid conversion |
| `/ai autoraid off` | Disable auto party-to-raid conversion |
| `/ai autoraid toggle` | Toggle auto-raid conversion — macro friendly |

### VIP List

| Command | Description |
|---------|-------------|
| `/ai vip add <name>` | Add a player to the VIP list |
| `/ai vip remove <name>` | Remove a player from the VIP list |
| `/ai vip list` | Show all players on the VIP list |
| `/ai vip clear` | Clear the entire VIP list |

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

### Running Both Modes Together
Both lists are checked on every message. You can use exists for common shorthand and exact for specific phrases you only want to match precisely.

```
/ai exists inv,come,join
/ai exact harder daddy,i have a small dick,masturbatorium
```

### Multi-Word Phrases
Both modes support multi-word phrases. The comma is the only delimiter — spaces are not split on.

### Case Sensitivity
All matching is case-insensitive. `INV`, `Inv`, and `inv` are treated the same.

---

## Auto-Raid Conversion

When enabled, the addon automatically converts your party to a raid whenever a player joins your group — as long as you are the party leader. The conversion is delayed slightly to ensure the client has fully processed the roster change before converting.

```
/ai autoraid on
/ai autoraid off
/ai autoraid toggle    -- great for macros
```

**Notes:**
- Only fires when you are the party leader
- Only converts if not already in a raid
- Only converts if at least one other player is in the party
- Runs independently of the main AutoInvite on/off status
- Uses a small timer delay to ensure reliable conversion

---

## VIP List

Players on the VIP list are automatically promoted to **raid assistant** when they join the group. The addon checks all current members against the VIP list any time the raid roster changes and promotes any that are not already assistant or higher.

```
/ai vip add Humak
/ai vip add Brewmaster
/ai vip list
```

**Notes:**
- VIP promotion only fires when AutoInvite is enabled (`/ai on`)
- Only fires when you are raid leader or party leader
- Players already at assistant or raid leader rank are not re-promoted
- The VIP list is saved per character and persists across sessions
- Names are case-insensitive when adding and removing

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

Guild chat scanning is **off by default**. When enabled, the same keyword lists used for whispers apply to guild chat. The setting persists across sessions and is restored automatically on login.

```
/ai guild on
/ai guild off
/ai guild toggle
```

---

## Macros

Several commands support `toggle` for easy macro use:

```
/ai guild toggle
/ai autoraid toggle
```

Example macro to toggle both at once:
```
/ai guild toggle
/ai autoraid toggle
```

---

## Quick Reference

```
/ai                       show status
/ai on / off              enable or disable
/ai exists <list>         set exists-mode keywords (comma-separated)
/ai exact <list>          set exact-mode keywords (comma-separated)
/ai guild on/off/toggle   toggle guild chat scanning
/ai autoraid on/off/toggle  toggle auto party-to-raid conversion
/ai party / raid          set group type
/ai vip add <name>        add player to VIP auto-promote list
/ai vip remove <name>     remove player from VIP list
/ai vip list              show VIP list
/ai vip clear             clear VIP list
/ai alist                 bulk invite A-List
/ai blist                 bulk invite B-List
```