-- Deutsch für Pokémon Blaue Edition in Gen1Recomp.
--
-- Translates the imported US Pokémon Blue dataset without modifying or
-- redistributing the player's ROM.
return function(mod)
  local GameVersion = require("src.core.GameVersion")
  if GameVersion.get() ~= "blue" then
    mod.log:info("Deutsch für Pokémon Blau: in dieser Edition nicht aktiv")
    return
  end

  -- mod:read is the supported way into your own directory; the catalogs are
  -- plain Lua tables, so read and run them rather than require()ing them.
  local function catalog(name)
    local rel = "lang/" .. name .. ".lua"
    local body = mod:read(rel)
    if not body then return {} end
    local chunk, err = loadstring(body, rel)
    if not chunk then
      mod.log:warn("%s has a syntax error: %s", rel, tostring(err))
      return {}
    end
    local ok, table_ = pcall(chunk)
    if not ok or type(table_) ~= "table" then
      mod.log:warn("%s did not return a table: %s", rel, tostring(table_))
      return {}
    end
    return table_
  end

  -- An empty value means "not translated yet", never "translate to blank".
  local function each(name, apply)
    local n = 0
    for key, value in pairs(catalog(name)) do
      if type(value) == "string" and value ~= "" then
        apply(key, value)
        n = n + 1
      end
    end
    return n
  end

  -- The mod override supplies the complete original German ROM font.  These
  -- mappings expose its native umlaut and international character slots.
  local germanCharmap = catalog("charmap")
  local germanStatusLabels = catalog("status_labels")
  for seq, code in pairs(germanCharmap) do
    mod.content.font:register("charmap:" .. seq, { seq = seq, code = code })
  end

  -- In-game runtime surfaces may read edition metadata directly instead of
  -- going through Strings(). Keep those names German once the mod is active.
  local blueInfo = GameVersion.VERSIONS.blue
  blueInfo.label = "Blau"
  blueInfo.displayName = "Pokémon Blaue Edition"
  blueInfo.launcherName = "Blaue Edition"

  -- ---- text ---------------------------------------------------------
  local counts = {}
  counts.dialogue = each("dialogue", function(id, value)
    mod.content.text:override(id, value)
  end)
  local germanStrings = catalog("strings")
  counts.strings = 0
  for source, value in pairs(germanStrings) do
    if type(value) == "string" and value ~= "" then
      mod.content.strings:override(source, value)
      counts.strings = counts.strings + 1
    end
  end
  -- These labels are generated dynamically by the naming screen and are
  -- therefore not present in the engine-string extraction worksheet.
  mod.content.strings:register("lower case", "klein")
  mod.content.strings:register("UPPER CASE", "GROSS")
  counts.namingLabels = 2
  counts.species = each("species_names", function(id, value)
    mod.content.pokemon:patch(id, { name = value })
  end)
  counts.dexKinds = each("dex_kinds", function(id, value)
    mod.content.pokemon:patch(id, { dexEntry = { kind = value } })
  end)
  counts.moves = each("move_names", function(id, value)
    mod.content.moves:patch(id, { name = value })
  end)
  counts.items = each("item_names", function(id, value)
    mod.content.items:patch(id, { name = value })
  end)
  counts.trainers = each("trainer_names", function(id, value)
    mod.content.trainers:patch(id, { name = value })
  end)
  counts.statuses = each("status_labels", function(id, value)
    mod.content.statuses:patch(id, { label = value, hudLabel = value })
  end)
  counts.types = each("type_names", function(id, value)
    mod.content.type_chart:patch(id, { name = value })
  end)

  -- Town Map names are ROM data but not part of the generator's standard
  -- translation catalogs, so patch the imported location records directly.
  local locations = {}
  counts.maps = each("map_names", function(id, value)
    locations[id] = { name = value }
  end)
  if next(locations) then
    mod.content.field:patch("townMap", { locations = locations })
  end

  -- "NEIN" needs one more interior tile than the English "NO". Move the
  -- shared choice box one tile left and widen it while keeping its right
  -- edge aligned with the original screen.
  mod.content.field:patch("theme", {
    choiceBox = { tx = 13, ty = 7, tw = 7, th = 5 },
  })

  -- TitleState accepts a direct file path for rebranded ribbons.  Its
  -- descriptor path bypasses the generated-asset resolver, so point it at
  -- the original German "BLAUE EDITION" art explicitly.
  mod.content.field:patch("title", {
    versionRibbon = mod.path .. "/overrides/title/blue_version.png",
    germanFullVersionRibbon = true,
  })

  -- Red/Blue's renderer normally selects only the "Red" and "Version"
  -- portions of a shared English ribbon.  German Blue stores "BLAUE EDITION"
  -- across all ten tiles, so redraw that complete original strip.
  local TitleState = require("src.ui.TitleState")
  if not TitleState.__deutschOriginalDraw then
    TitleState.__deutschOriginalDraw = TitleState.draw
    TitleState.draw = function(self)
      TitleState.__deutschOriginalDraw(self)
      if self.title and self.title.germanFullVersionRibbon
          and self.version and not self.yellow then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 48, 64, 80, 8)
        love.graphics.draw(self.version, 48, 64)
      end
      love.graphics.setColor(1, 1, 1, 1)
    end
  end

  -- Battle modules reproduce the US ROM's PlaceMoveUsersName behavior by
  -- inserting "Enemy " after the string catalog has already been applied.
  -- They also pass the English stat-name table as dynamic text.  Localize
  -- those engine-generated fragments centrally, then enforce the original
  -- two-line/18-glyph battle-box layout for every composed message.
  local Strings = require("src.core.Strings")
  local Font = require("src.render.Font")
  local BattleState = require("src.battle.BattleState")
  local SlotMachine = require("src.ui.SlotMachine")

  -- The slot machine owns a second hard-coded YES/NO box instead of using
  -- Theme.choiceBox. Widen only that box during its draw call so NEIN never
  -- overwrites the right border.
  if not SlotMachine.__deutschOriginalDrawBottom then
    SlotMachine.__deutschOriginalDrawBottom = SlotMachine.drawBottom
    SlotMachine.drawBottom = function(self)
      local originalDrawBox = Font.drawBox
      Font.drawBox = function(tx, ty, tw, th, ...)
        if (self.stage == "intro" or self.stage == "onemore")
            and tx == 13 and tw == 6 and th == 5 then
          tw = 7
        end
        return originalDrawBox(tx, ty, tw, th, ...)
      end
      local ok, err = xpcall(function()
        SlotMachine.__deutschOriginalDrawBottom(self)
      end, tostring)
      Font.drawBox = originalDrawBox
      if not ok then error(err, 0) end
    end
  end

  -- The German cartridge widens BATTLE_MENU_TEMPLATE two tiles to the left:
  -- box (6,12)-(19,17), text at (8,14), cursors at columns 7/12.  The
  -- English geometry hard-coded by Gen1Recomp starts at column 8, so the
  -- original six-letter "FLUCHT" runs through its right border.  Replace
  -- only the classic normal command menu; Safari and wide/3D battles either
  -- already use the full width or have enough room.
  if not BattleState.__deutschOriginalDrawTextArea then
    BattleState.__deutschOriginalDrawTextArea = BattleState.drawTextArea
    BattleState.drawTextArea = function(self)
      if self.phase ~= "menu" or self.safari then
        return BattleState.__deutschOriginalDrawTextArea(self)
      end

      Font.drawBox(0, 12, 20, 6)
      Font.drawBox(6, 12, 14, 6)
      love.graphics.setColor(0, 0, 0, 1)
      Font.draw(Strings("FIGHT"), 64, 112)
      Font.drawCode(0xE1, 104, 112)
      Font.drawCode(0xE2, 112, 112)
      Font.draw(Strings("ITEM"), 64, 128)
      Font.draw(Strings("RUN"), 104, 128)

      if self.demo then
        Font.drawCode(0xED, 56,
          (self.demoTimer or 0) <= 80 and 112 or 128)
      else
        local col = (self.menuIndex - 1) % 2
        local row = math.floor((self.menuIndex - 1) / 2)
        Font.drawCode(0xED, col == 0 and 56 or 96, 112 + row * 16)
      end
      love.graphics.setColor(1, 1, 1, 1)
    end
  end

  local editionNames = {
    ["Blue"] = "Blau",
    ["BLUE"] = "BLAU",
    ["Pokemon Blue"] = "Pokémon Blaue Edition",
    ["Pokémon Blue"] = "Pokémon Blaue Edition",
    ["Blue Version"] = "Blaue Edition",
    ["BLUE VERSION"] = "BLAUE EDITION",
    ["Blue Edition"] = "Blaue Edition",
    ["BLUE EDITION"] = "BLAUE EDITION",
    ["POKéMON BLUE"] = "POKéMON BLAUE EDITION",
  }
  local function localizeEditionName(text)
    if type(text) ~= "string" then return text end
    text = editionNames[text] or text
    text = text:gsub("%f[%a]POKéMON BLUE%f[%A]", "POKéMON BLAUE EDITION")
    text = text:gsub("%f[%a]BLUE VERSION%f[%A]", "BLAUE EDITION")
    text = text:gsub("%f[%a]Blue Version%f[%A]", "Blaue Edition")
    return text
  end

  local function localizeRuntimeText(text)
    if type(text) ~= "string" then return text end
    text = germanStrings[text] or text
    return localizeEditionName(text)
  end

  -- Some hand-ported screens pass raw English literals directly instead of
  -- going through Strings(). Translate reviewed exact rows at both final
  -- display seams; this also covers labels such as USE on older builds.
  local TextBox = require("src.render.TextBox")
  if not TextBox.__deutschOriginalNew then
    TextBox.__deutschOriginalNew = TextBox.new
    TextBox.new = function(game, text, onDone, opts)
      return TextBox.__deutschOriginalNew(
        game, localizeRuntimeText(text), onDone, opts)
    end
  end

  -- Battle HUDs read the translated statuses registry, but the party and
  -- summary menus draw mon.status (the internal PSN/SLP/etc. id) directly.
  -- Translate those exact status ids at the final font seam so every menu
  -- displays the German three-letter label without changing save/mechanics.
  if not Font.__deutschOriginalDraw then
    Font.__deutschOriginalDraw = Font.draw
    Font.draw = function(text, x, y)
      text = localizeRuntimeText(text)
      if type(text) == "string" and germanStatusLabels[text] then
        text = germanStatusLabels[text]
      end
      return Font.__deutschOriginalDraw(text, x, y)
    end
  end

  -- The imported US charmap already maps "é" to $BA, while the German ROM
  -- stores it at $BC.  Registry rows are merged beside the original row and
  -- Font.load sorts equal-length sequences without a deterministic tie-break,
  -- so the US code could still win and draw the German $BA glyph ("à").  Pin
  -- every German sequence to its verified German-ROM slot after splitting.
  if not Font.__deutschOriginalSplit then
    Font.__deutschOriginalSplit = Font.split
    Font.split = function(text)
      local spans = Font.__deutschOriginalSplit(text)
      for _, span in ipairs(spans) do
        local seq = text:sub(span.from, span.to)
        local code = germanCharmap[seq]
        if code then span.code = code end
      end
      return spans
    end
  end

  local battleTerms = {
    ["ATTACK"] = "ANGR",
    ["DEFENSE"] = "VERT",
    ["SPEED"] = "INIT",
    ["SPECIAL"] = "SPEZ",
    ["ACCURACY"] = "GENA",
    ["EVADE"] = "FLU",
    ["FOE"] = "GEGNER",
    ["OLD MAN"] = "ALTER MANN",
  }

  local function generatedBattleTerms(text)
    text = localizeRuntimeText(text)
    text = text:gsub("Enemy ", "Gegn. ")
    for source, translated in pairs(battleTerms) do
      text = text:gsub("%f[%a]" .. source .. "%f[%A]", translated)
    end
    return text
  end

  local function wrapBattleLine(line)
    local result = {}
    line = line:gsub("^ +", ""):gsub(" +$", "")
    while #Font.split(line) > 18 do
      local spans = Font.split(line)
      local cut, nextSpan = 18, 19
      for i = 18, 2, -1 do
        if line:sub(spans[i].from, spans[i].to) == " " then
          cut, nextSpan = i - 1, i + 1
          break
        end
      end
      result[#result + 1] = line:sub(spans[1].from, spans[cut].to)
      line = nextSpan <= #spans and line:sub(spans[nextSpan].from) or ""
      line = line:gsub("^ +", "")
    end
    result[#result + 1] = line
    return result
  end

  local function localizeBattleText(text)
    if type(text) ~= "string" then return text end
    -- Safety net for the trainer-switch fragment. In the normal path
    -- sayChoice rejoins it with the following Pokémon name, but if another
    -- mod displays the row early it must still never leak English.
    text = text:gsub("^(.-) is\nabout to use$", "%1 wird nun\neinsetzen:")
    text = text:gsub("^(.-) is about to use$", "%1 wird nun\neinsetzen:")
    text = generatedBattleTerms(text)
    local result, pos, lineNumber = {}, 1, 0
    while true do
      local controlAt = text:find("[\n\v\f]", pos)
      local line = controlAt and text:sub(pos, controlAt - 1)
                                or text:sub(pos)
      local wrapped = wrapBattleLine(line)
      for index, part in ipairs(wrapped) do
        if index > 1 then
          result[#result + 1] = lineNumber == 0 and "\n" or "\v"
          lineNumber = lineNumber + 1
        end
        result[#result + 1] = part
      end
      if not controlAt then break end
      local control = text:sub(controlAt, controlAt)
      if control == "\f" then
        result[#result + 1] = control
        lineNumber = 0
      else
        -- A third physical line uses the ROM's CONT behavior so it scrolls
        -- into the two-line box instead of appearing outside of it.
        result[#result + 1] =
          control == "\n" and lineNumber > 0 and "\v" or control
        lineNumber = lineNumber + 1
      end
      pos = controlAt + 1
    end
    return table.concat(result)
  end

  if not BattleState.__deutschOriginalStartMessage then
    BattleState.__deutschOriginalStartMessage = BattleState.startMessage
    BattleState.startMessage = function(self, item)
      if item and item.text then
        item.text = localizeBattleText(item.text)
      end
      return BattleState.__deutschOriginalStartMessage(self, item)
    end
  end

  -- EnemySendOutFirstMon builds _TrainerAboutToUseText as three independent
  -- English queue entries ("TRAINER is / about to use", "MON!", then the
  -- switch question).  Rejoin those fragments before they are displayed so
  -- the result follows the German ROM's complete sentence:
  --   TRAINER wird / MON in den / Kampf schicken!
  if not BattleState.__deutschOriginalSayChoice then
    BattleState.__deutschOriginalSayChoice = BattleState.sayChoice
    BattleState.sayChoice = function(self, text, onChoose)
      local queue = self.queue or {}
      local trainerName = self.trainer and self.trainer.name

      -- Find the last two text rows instead of assuming they are the final
      -- two queue entries. Animation/wait rows may be inserted between them
      -- by the battle flow or another compatible presentation mod.
      local monIndex, aboutIndex
      for index = #queue, 1, -1 do
        if type(queue[index].text) == "string" then
          if not monIndex then
            monIndex = index
          else
            aboutIndex = index
            break
          end
        end
      end
      local about = aboutIndex and queue[aboutIndex] or nil
      local mon = monIndex and queue[monIndex] or nil
      local nextName = mon and mon.text:match("^(.-)!$") or nil
      local aboutText = about and about.text
      local isSwitchQuestion = type(text) == "string"
        and (text:find("change POKéMON", 1, true)
          or text:find("POKéMON wechseln", 1, true))
      local isTrainerSwitch = type(aboutText) == "string"
        and type(trainerName) == "string"
        and isSwitchQuestion
        and (aboutText:find("about to use", 1, true)
          or aboutText:find("einsetzen:", 1, true)
          or aboutText:find("setzt gleich ein:", 1, true))
      if isTrainerSwitch and nextName and nextName ~= "" then
        about.text = trainerName .. " wird\n" .. nextName
          .. " in den\vKampf schicken!"
        table.remove(queue, monIndex)
        text = "Möchtest Du das\nPOKéMON wechseln?"
      end
      return BattleState.__deutschOriginalSayChoice(self, text, onChoose)
    end
  end

  -- German defaults for a new game. Player-entered names and existing saves
  -- remain untouched.
  mod.content.field:patch("boot", {
    playerName = "BLAU",
    rivalName = "ROT",
  })

  -- ---- name entry ---------------------------------------------------
  -- The naming screen's letter grid.  Leave lang/naming.lua returning nil
  -- to keep the English alphabet.
  local grid = catalog("naming")
  if grid.upper then
    mod.hooks:wrap("ui.naming.grid", function(next, base, ctx)
      base = next(base, ctx)
      local want = ctx.lower and grid.lower or grid.upper
      return want or base
    end)
  end

  mod.events:on("game.ready", function()
    local total = 0
    for _, n in pairs(counts) do total = total + n end
    mod.log:info("Deutsch: %d Einträge geladen", total)
  end)
end
