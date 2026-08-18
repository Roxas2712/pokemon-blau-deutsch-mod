-- Draw the German GYM/POKE MART sign lettering onto the player's own
-- imported overworld tileset. The mod ships only this 48-pixel recipe, never
-- the underlying ROM-derived sheet.
local BLACK = {
  { 125, 18 }, { 127, 18 }, { 123, 19 }, { 125, 19 }, { 122, 20 },
  { 125, 20 }, { 123, 21 }, { 125, 21 }, { 120, 22 }, { 125, 22 },
  { 122, 26 }, { 125, 26 }, { 120, 27 }, { 122, 27 }, { 125, 27 },
  { 122, 28 }, { 122, 29 }, { 122, 30 }, { 38, 35 },
}

local WHITE = {
  { 123, 18 }, { 124, 18 }, { 121, 19 }, { 126, 19 }, { 124, 20 },
  { 121, 21 }, { 124, 21 }, { 127, 21 }, { 121, 22 }, { 122, 22 },
  { 124, 22 }, { 127, 22 }, { 121, 26 }, { 123, 26 }, { 127, 26 },
  { 121, 27 }, { 124, 27 }, { 126, 27 }, { 127, 27 }, { 120, 28 },
  { 121, 28 }, { 123, 28 }, { 126, 28 }, { 127, 28 }, { 123, 29 },
  { 127, 29 }, { 123, 30 }, { 43, 35 }, { 40, 37 },
}

local function paint(image, pixels, shade)
  for _, point in ipairs(pixels) do
    image:setPixel(point[1], point[2], shade, shade, shade, 1)
  end
end

return function(ctx)
  local path = "tilesets/overworld.png"
  if not ctx.exists(path) then return end
  local image = ctx.readImage(path)
  paint(image, BLACK, 0)
  paint(image, WHITE, 1)
  ctx.writeImage(image, path)
end

