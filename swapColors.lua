-- Pixel Color Swapper Script
-- Swaps two colors in currently selected pixels

local sprite = app.activeSprite
local image = app.activeImage
if not sprite then
  app.alert("No sprite...")
  return
end

-- Check if there's a selection using the proper method
local sel = sprite.selection
if not sel or sel.isEmpty then
  -- Alternative way to check for selection
  local doc = app.activeDocument
  if doc then
    local sel2 = doc.selection
    if not sel2 or sel2:isEmpty() then
      app.alert("Please select an area first!")
      return
    end
  else
    app.alert("Please select an area first!")
    return
  end
end

-- Create dialog with color picker interface
local dlg = Dialog("Swap Colors in Selection")
dlg:label{ text="Select colors to swap:" }
dlg:color{ id="color1", color=app.foreground_color, show_alpha=false }
dlg:color{ id="color2", color=app.background_color, show_alpha=false }
dlg:button{ text="OK", focus=true }
dlg:button{ text="Cancel" }

if dlg:show() then
  local color1 = dlg.data.color1
  local color2 = dlg.data.color2
  
  if color1 == color2 then
    app.alert("Please select different colors!")
    return
  end

  -- Get the selection bounds
  local bounds = sel.bounds
 
  -- Swap colors in the selected area
  local changedCount = 0
  
  for y = bounds.y, bounds.y + bounds.height - 1 do
    for x = bounds.x, bounds.x + bounds.width - 1 do
      if sel:contains(x, y) then
        local pixelColor = Color(image:getPixel(x, y))
        if pixelColor == Color(color1) then
          image:putPixel(x, y, color2)
          changedCount = changedCount + 1
        elseif pixelColor == Color(color2) then
          image:putPixel(x, y, color1)
          changedCount = changedCount + 1
        end
      end
    end
  end
  
  -- Refresh the display
  if changedCount > 0 then
    app.refresh()
    
    app.alert("Swapped " .. changedCount .. " pixels!")
  else
    app.alert("No pixels of selected colors found in selection!")
  end
  
else
  -- User cancelled
  return
end
