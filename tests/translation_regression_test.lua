-- ROM-free regression coverage for the translation fixes in this release.
-- Run from a Gen1Recomp checkout:
--   TRANSLATION_MOD_DIR=/absolute/path luajit /absolute/path/tests/translation_regression_test.lua

package.path = "./?.lua;./?/init.lua;" .. package.path

local T = require("tests.modkit")
local GameVersion = require("src.core.GameVersion")
local Strings = require("src.core.Strings")

local source = debug.getinfo(1, "S").source:gsub("^@", "")
local TEST_DIR = source:match("^(.*)/[^/]+$") or "."
local MOD_DIR = os.getenv("TRANSLATION_MOD_DIR")
  or TEST_DIR:match("^(.*)/tests$") or (TEST_DIR .. "/..")
local SDK_PATH, SDK_ROOT = MOD_DIR, "."
if MOD_DIR:sub(1, 1) == "/" then
  SDK_PATH, SDK_ROOT = MOD_DIR:sub(2), "/"
end
local speciesName = "GLUMANDA"

GameVersion.set("blue")
local run = T.sdk.loadMod(SDK_PATH, {
  data = T.fixtures.fresh(),
  dev = true,
  root = SDK_ROOT,
})

T.eq(#run.errors, 0, "translation mod loads cleanly")
T.check(run.mod and run.mod.manifest.id == "deutsch-blau",
  "the expected edition mod is active")

local charmander = run.data.pokemon.CHARMANDER
local bulbasaur = run.data.pokemon.BULBASAUR
local squirtle = run.data.pokemon.SQUIRTLE
T.eq(charmander and charmander.name, "GLUMANDA",
  "caught Charmander uses its German display and nickname suggestion")
T.eq(charmander and charmander.dexEntry and charmander.dexEntry.kind, "ECHSEN",
  "Charmander has the species-keyed Pokédex category")
T.eq(bulbasaur and bulbasaur.dexEntry and bulbasaur.dexEntry.kind, "SAMEN",
  "Bulbasaur no longer receives Nidoking's BOHRER category")
T.eq(squirtle and squirtle.dexEntry and squirtle.dexEntry.kind, "MINIKRÖTEN",
  "Squirtle has its verified German Pokédex category")

Strings.load(run.data)
T.eq(Strings("USE"), "OK", "USE cannot leak from the reviewed catalog")
T.eq(Strings("ATTACK"), "ANGR", "level-up ATTACK label is abbreviated")
T.eq(Strings("DEFENSE"), "VERT", "level-up DEFENSE label is abbreviated")
T.eq(Strings("SPEED"), "INIT", "level-up SPEED label is abbreviated")
T.eq(Strings("SPECIAL"), "SPEZ", "level-up SPECIAL label is abbreviated")
T.eq(Strings("Enemy %s", speciesName), "Gegn. " .. speciesName,
  "new enemy-name template is translated")
T.eq(Strings("%s is\nabout to use\v%s!", "ROCKO", speciesName),
  "ROCKO wird\n" .. speciesName .. " in den\vKampf schicken!",
  "current combined trainer-switch template is translated")
T.eq(Strings("2026 bois club games"), "2026 bois club games",
  "BOIS CLUB branding remains untranslated")

local Theme = require("src.ui.Theme")
Theme.load(run.data)
T.eq(Theme.choiceBox.tx, 13, "German choice box moves one tile left")
T.eq(Theme.choiceBox.tw, 7, "German choice box gives NEIN enough width")

local Font = require("src.render.Font")
local captured
local originalDraw = Font.__deutschOriginalDraw
Font.__deutschOriginalDraw = function(text)
  captured = text
end
Font.draw("USE", 0, 0)
T.eq(captured, "OK", "raw Font.draw USE is localized")
Font.__deutschOriginalDraw = originalDraw

local TextBox = require("src.render.TextBox")
local capturedText
local originalNew = TextBox.__deutschOriginalNew
TextBox.__deutschOriginalNew = function(_, text)
  capturedText = text
  return {}
end
TextBox.new({}, "USE")
T.eq(capturedText, "OK", "raw TextBox USE is localized")
TextBox.__deutschOriginalNew = originalNew

local slotWidth
local originalDrawBox = Font.drawBox
Font.drawBox = function(tx, _, tw, th)
  if tx == 13 and th == 5 then slotWidth = tw end
end
require("src.ui.SlotMachine").drawBottom({
  stage = "onemore",
  yesno = 1,
})
Font.drawBox = originalDrawBox
T.eq(slotWidth, 7, "slot-machine NEIN box is widened too")

run.release()
T.finish("deutsch-blau_translation_regression")
