-- Pixel Fade Animation Creator 

local srcSprite = app.sprite
local srcCel = app.activeCel
if not srcSprite or not srcCel or not srcCel.image then
  app.alert("Open a sprite and select a cel first.")
  return
end

local dlg = Dialog("Create Pixel Fade Animation")
dlg:label{ text="Pixel Fade Animation Creator" }
dlg:number{ id="frames", text="5", value=5, min=2, max=1000 }
dlg:button{ text="OK", focus=true }
dlg:button{ text="Cancel" }

if not dlg:show() then return end
local frameCount = math.max(2, math.min(1000, dlg.data.frames or 20))

local isIndexed = (srcSprite.colorMode == ColorMode.INDEXED)
local transparentIndex = srcSprite.transparentColor
local function isOpaquePixel(px)
  if isIndexed then
    return px ~= transparentIndex
  else
    return app.pixelColor.rgbaA(px) > 0
  end
end
local TRANSPARENT = isIndexed and transparentIndex or app.pixelColor.rgba(0,0,0,0)

local w, h = srcSprite.width, srcSprite.height
local srcImg = srcCel.image

-- Create new sprite and take its default layer
local animSprite = Sprite(w, h, srcSprite.colorMode)
animSprite:setPalette(srcSprite.palettes[1]) -- keep same palette in Indexed mode
local layer = animSprite.layers[1]

-- Frame 1: copy source image into a new cel
local firstImg = Image(srcSprite.spec)
firstImg:drawImage(srcImg, srcCel.position)
animSprite:newCel(layer, 1, firstImg, Point(0,0))

-- Collect all non-transparent pixel coordinates (on canvas)
local pixelList = {}
local pos = srcCel.position
local imgW, imgH = srcImg.width, srcImg.height

for y = 0, imgH-1 do
  for x = 0, imgW-1 do
    local px = srcImg:getPixel(x, y)
    if isOpaquePixel(px) then
      local cx = x + pos.x
      local cy = y + pos.y
      if cx >= 0 and cy >= 0 and cx < w and cy < h then
        pixelList[#pixelList+1] = { x = cx, y = cy }  -- canvas coords
      end
    end
  end
end

-- Shuffle pixels (Fisher–Yates)
math.randomseed(os.time())
for i = #pixelList, 2, -1 do
  local j = math.random(i)
  pixelList[i], pixelList[j] = pixelList[j], pixelList[i]
end

local total = #pixelList
local perFrame = math.max(1, math.ceil(total / (frameCount - 1)))

-- Build subsequent frames
for fi = 2, frameCount do
  animSprite:newFrame()

  -- Copy previous frame's cel image
  local prevCel = layer:cel(fi-1)
  local img = Image(prevCel.image) -- duplicates pixels

  -- Erase a chunk of pixels for this frame
  local startIdx = (fi - 2) * perFrame + 1
  local endIdx = math.min(startIdx + perFrame - 1, total)
  for i = startIdx, endIdx do
    local p = pixelList[i]
    if p then
      img:drawPixel(p.x, p.y, TRANSPARENT)
    end
  end

  -- Place the modified image in a cel at this frame
  animSprite:newCel(layer, fi, img, prevCel.position)
end

app.alert("Animation created in new sprite.\nFile → Save As to export.")

