--[[
- Addon: MotionAnchorFFXI
- Description: FFXI Ashita Addon to help relieve the symptoms of motion sickness and visual vertigo
]]--

addon.name      = 'MotionAnchorFFXI';
addon.author    = 'Razi-469';
addon.version   = '1.2';

require('common');
local imgui = require('imgui');
local settings = require('settings');

local function TableToColorU32(rgba)
    local r = math.floor((rgba[1] or 1.0) * 255 + 0.5);
    local g = math.floor((rgba[2] or 1.0) * 255 + 0.5);
    local b = math.floor((rgba[3] or 1.0) * 255 + 0.5);
    local a = math.floor((rgba[4] or 1.0) * 255 + 0.5);
    return (a * 16777216) + (b * 65536) + (g * 256) + r;
end

local function CreateDefaultDots()
    local dots = {};
    for x = 0, 4 do
        dots[x] = {};
        for y = 0, 4 do
            dots[x][y] = {
                width = 0.5,  
                length = 0.5, 
                shape = 1,    
                color = { 1.0, 1.0, 1.0, 1.0 }, 
                isFocal = false, 
            };
        end
    end
    return dots;
end

local defaultSettings = {
    mountedOnly = false,
    border = {
        width = 0.5,
        color = { 1.0, 1.0, 1.0, 1.0 }, 
    },
    line = {
        width = 0.5,
        color = { 1.0, 1.0, 1.0, 1.0 }, 
    },
    dots = CreateDefaultDots(),
};

local function EnsureSettingsFileExists()

    local configPath = ('config/addons/%s/'):format(addon.name);
    
    local success, loaded = pcall(function()
        return settings.load(defaultSettings);
    end)

    if (not success or loaded == nil) then
        settings.save(defaultSettings);
        return settings.load(defaultSettings);
    end
    
    return loaded;
end

local gSettings = EnsureSettingsFileExists();
if (gSettings == nil) then
    gSettings = defaultSettings;
    settings.save(gSettings);
end

if (gSettings.mountedOnly == nil) then
    gSettings.mountedOnly = false;
end

if (gSettings.border == nil) then
    gSettings.border = {
        width = 0.5,
        color = { 1.0, 1.0, 1.0, 1.0 },
    };
end

if (gSettings.line == nil) then
    gSettings.line = {
        width = 0.5,
        color = { 1.0, 1.0, 1.0, 1.0 },
    };
end

if (gSettings.dots == nil or gSettings.dots[0] == nil) then
    gSettings.dots = CreateDefaultDots();
else
    for x = 0, 4 do
        for y = 0, 4 do
            if (gSettings.dots[x][y] == nil) then
                gSettings.dots[x][y] = {
                    width = 0.5,
                    length = 0.5,
                    shape = 1,
                    color = { 1.0, 1.0, 1.0, 1.0 },
                    isFocal = false,
                };
            else
                if (gSettings.dots[x][y].shape == nil or gSettings.dots[x][y].shape > 4) then
                    gSettings.dots[x][y].shape = 1;
                end
                if (gSettings.dots[x][y].width == nil) then
                    gSettings.dots[x][y].width = 0.5;
                end
                if (gSettings.dots[x][y].length == nil) then
                    gSettings.dots[x][y].length = 0.5;
                end
                if (gSettings.dots[x][y].isFocal == nil) then
                    gSettings.dots[x][y].isFocal = false;
                end
                if (gSettings.dots[x][y].color == nil) then
                    gSettings.dots[x][y].color = { 1.0, 1.0, 1.0, 1.0 };
                end
            end
        end
    end
end

local isWindowOpen = { false };
local selectedNode = { x = 2, y = 2 }; 

ashita.events.register('command', 'command_callback', function (e)
    if (e.command:lower():match('/anchor')) then
        isWindowOpen[1] = not isWindowOpen[1];
        e.blocked = true;
    end
end);

ashita.events.register('d3d_present', 'd3d_present_callback', function ()

    local showGrid = true;
    if (gSettings.mountedOnly) then
        local entity = GetPlayerEntity();
        if (entity == nil or entity.Pointer == 0 or entity.StatusServer ~= 5) then
            showGrid = false;
        end
    end

    local io = imgui.GetIO();
    local screenWidth = io.DisplaySize.x;
    local screenHeight = io.DisplaySize.y;

    if (screenWidth > 0 and screenHeight > 0 and showGrid) then

        local stepX = screenWidth / 4;
        local stepY = screenHeight / 4;

        local drawList = imgui.GetBackgroundDrawList();


        local function IsInsideFocalPoint(px, py)
            for ix = 0, 4 do
                for iy = 0, 4 do
                    local node = gSettings.dots[ix][iy];
                    if (node ~= nil and node.isFocal) then
                        local npx = ix * stepX;
                        local npy = iy * stepY;
                        local aW = screenWidth * ((node.width or 0.5) / 100.0);
                        local aH = screenHeight * ((node.length or 0.5) / 100.0);
                        local hW = aW / 2.0;
                        local hL = aH / 2.0;

                        if (px >= npx - hW and px <= npx + hW and py >= npy - hL and py <= npy + hL) then
                            return true;
                        end
                    end
                end
            end
            return false;
        end

        local packedBorderColor = TableToColorU32(gSettings.border.color);
        local packedLineColor = TableToColorU32(gSettings.line.color);

        drawList:AddRect(
            { 0, 0 },
            { screenWidth, screenHeight },
            packedBorderColor,
            0.0,
            0,
            gSettings.border.width
        );

        for i = 1, 3 do
            local x = i * stepX;
            local segmentSize = 10;
            for y = 0, screenHeight, segmentSize do
                local yEnd = math.min(y + segmentSize, screenHeight);
                local midY = (y + yEnd) / 2;
                if (not IsInsideFocalPoint(x, midY)) then
                    drawList:AddLine({ x, y }, { x, yEnd }, packedLineColor, gSettings.line.width);
                end
            end
        end

        for j = 1, 3 do
            local y = j * stepY;
            local segmentSize = 10;
            for x = 0, screenWidth, segmentSize do
                local xEnd = math.min(x + segmentSize, screenWidth);
                local midX = (x + xEnd) / 2;
                if (not IsInsideFocalPoint(midX, y)) then
                    drawList:AddLine({ x, y }, { xEnd, y }, packedLineColor, gSettings.line.width);
                end
            end
        end

        for ix = 0, 4 do
            for iy = 0, 4 do
                local node = gSettings.dots[ix][iy];
                if (node ~= nil and not node.isFocal) then
                    local px = ix * stepX;
                    local py = iy * stepY;
                    
                    local actualWidth = screenWidth * ((node.width or 0.5) / 100.0);
                    local actualHeight = screenHeight * ((node.length or 0.5) / 100.0);
                    
                    local halfW = actualWidth / 2.0;
                    local halfL = actualHeight / 2.0;
                    local shapeType = node.shape or 1;

                    local packedDotColor = TableToColorU32(node.color);

                    if (shapeType == 0) then

                        drawList:AddRectFilled(
                            { px - halfW, py - halfL },
                            { px + halfW, py + halfL },
                            packedDotColor
                        );
                    elseif (shapeType == 1) then

                        drawList:PathClear();
                        local numSegments = 24;
                        for s = 0, numSegments - 1 do
                            local theta = (s / numSegments) * (2.0 * math.pi);
                            local ox = px + (halfW * math.cos(theta));
                            local oy = py + (halfL * math.sin(theta));
                            drawList:PathLineTo({ ox, oy });
                        end
                        drawList:PathFillConvex(packedDotColor);
                    elseif (shapeType == 2) then

                        drawList:AddTriangleFilled(
                            { px, py - halfL },
                            { px + halfW, py },
                            { px - halfW, py },
                            packedDotColor
                        );
                        drawList:AddTriangleFilled(
                            { px, py + halfL },
                            { px + halfW, py },
                            { px - halfW, py },
                            packedDotColor
                        );
                    elseif (shapeType == 3) then

                        local stroke = math.max(2.0, halfW * 0.1);
                        drawList:AddLine({ px - halfW, py + halfL }, { px, py - halfL }, packedDotColor, stroke);
                        drawList:AddLine({ px, py - halfL }, { px + halfW, py + halfL }, packedDotColor, stroke);
                    elseif (shapeType == 4) then

                        local stroke = math.max(2.0, halfW * 0.1);
                        drawList:AddLine({ px - halfW, py - halfL }, { px, py + halfL }, packedDotColor, stroke);
                        drawList:AddLine({ px, py + halfL }, { px + halfW, py - halfL }, packedDotColor, stroke);
                    end
                end
            end
        end
    end

    if (isWindowOpen[1]) then
        imgui.SetNextWindowSize({ 380, 740 }, ImGuiCond_FirstUseEver);
        if (imgui.Begin('Motion Anchor Settings', isWindowOpen)) then
            
            if (imgui.Button('Revert to Default')) then
                gSettings.mountedOnly = false;
                gSettings.border.width = 0.5;
                gSettings.border.color = { 1.0, 1.0, 1.0, 1.0 };
                gSettings.line.width = 0.5;
                gSettings.line.color = { 1.0, 1.0, 1.0, 1.0 };
                
                for x = 0, 4 do
                    for y = 0, 4 do
                        gSettings.dots[x][y] = {
                            width = 0.5,
                            length = 0.5,
                            shape = 1,
                            color = { 1.0, 1.0, 1.0, 1.0 },
                            isFocal = false,
                        };
                    end
                end
                settings.save();
            end

            imgui.Separator();

            local mountedBool = { gSettings.mountedOnly };
            if (imgui.Checkbox('Only show overlay while on Chocobo', mountedBool)) then
                gSettings.mountedOnly = mountedBool[1];
                settings.save();
            end

            imgui.Spacing();

            imgui.Text('Border Customization');
            imgui.Separator();
            local borderWidth = { gSettings.border.width };
            if (imgui.SliderFloat('Border Width', borderWidth, 0.5, 100.0, '%.1f')) then
                gSettings.border.width = borderWidth[1];
                settings.save();
            end

            local borderColor = { gSettings.border.color[1], gSettings.border.color[2], gSettings.border.color[3], gSettings.border.color[4] };
            if (imgui.ColorEdit4('Border Color (RGB)', borderColor)) then
                gSettings.border.color[1] = borderColor[1];
                gSettings.border.color[2] = borderColor[2];
                gSettings.border.color[3] = borderColor[3];
                settings.save();
            end

            local borderAlpha = { gSettings.border.color[4] };
            if (imgui.SliderFloat('Border Transparency', borderAlpha, 0.0, 1.0, '%.2f')) then
                gSettings.border.color[4] = borderAlpha[1];
                settings.save();
            end

            imgui.Spacing();

            imgui.Text('Grid Customization');
            imgui.Separator();
            local lineWidth = { gSettings.line.width };
            if (imgui.SliderFloat('Grid Line Width', lineWidth, 0.5, 100.0, '%.1f')) then
                gSettings.line.width = lineWidth[1];
                settings.save();
            end

            local lineColor = { gSettings.line.color[1], gSettings.line.color[2], gSettings.line.color[3], gSettings.line.color[4] };
            if (imgui.ColorEdit4('Grid Color (RGB)', lineColor)) then
                gSettings.line.color[1] = lineColor[1];
                gSettings.line.color[2] = lineColor[2];
                gSettings.line.color[3] = lineColor[3];
                settings.save();
            end

            local lineAlpha = { gSettings.line.color[4] };
            if (imgui.SliderFloat('Grid Transparency', lineAlpha, 0.0, 1.0, '%.2f')) then
                gSettings.line.color[4] = lineAlpha[1];
                settings.save();
            end

            imgui.Spacing();

            imgui.Text('Select which Grid Point to Customize');
            imgui.Separator();

            imgui.PushStyleVar(ImGuiStyleVar_FrameBorderSize, 2.0);

            for iy = 0, 4 do
                for ix = 0, 4 do
                    if (ix > 0) then
                        imgui.SameLine();
                    end

                    local isSelected = (selectedNode.x == ix and selectedNode.y == iy);
                    local node = gSettings.dots[ix][iy];
                    
                    if (node ~= nil and node.color ~= nil) then
                        imgui.PushStyleColor(ImGuiCol_Border, { node.color[1], node.color[2], node.color[3], node.color[4] });
                    else
                        imgui.PushStyleColor(ImGuiCol_Border, { 0.6, 0.6, 0.6, 0.8 });
                    end

                    local shapeSymbol = '[#]'; 
                    if (node ~= nil) then
                        if (node.isFocal) then
                            shapeSymbol = '[X]';
                        else
                            local sType = node.shape or 1;
                            if (sType == 0) then shapeSymbol = '[#]';
                            elseif (sType == 1) then shapeSymbol = '[O]';
                            elseif (sType == 2) then shapeSymbol = '[<>]';
                            elseif (sType == 3) then shapeSymbol = '[^]';
                            elseif (sType == 4) then shapeSymbol = '[v]';
                            end
                        end
                    end

                    local btnLabel = string.format('%s##dot_%d_%d', shapeSymbol, ix, iy);
                    
                    if (isSelected) then
                        imgui.PushStyleColor(ImGuiCol_Button, { 0.2, 0.6, 0.9, 1.0 });
                    end

                    if (imgui.Button(btnLabel, { 58, 28 })) then
                        selectedNode.x = ix;
                        selectedNode.y = iy;
                    end

                    if (isSelected) then
                        imgui.PopStyleColor(1);
                    end

                    imgui.PopStyleColor(1);
                end
            end

            imgui.PopStyleVar(1);

            imgui.Spacing();

            local activeNode = gSettings.dots[selectedNode.x][selectedNode.y];
            if (activeNode ~= nil) then
                imgui.Separator();

                imgui.AlignTextToFramePadding();
                imgui.Text('Dot Shape');
                imgui.SameLine();
                imgui.SetNextItemWidth(170);
                local currentShape = { activeNode.shape or 1 };
                if (imgui.Combo('##DotShapeCombo', currentShape, 'Square\0Circle\0Diamond\0Chevron Up\0Chevron Down\0')) then
                    activeNode.shape = currentShape[1];
                    settings.save();
                end

                local focalBool = { activeNode.isFocal };
                if (imgui.Checkbox('Focal Point', focalBool)) then
                    activeNode.isFocal = focalBool[1];
                    settings.save();
                end

                if (imgui.Button('Apply Size to All Dots')) then
                    for x = 0, 4 do
                        for y = 0, 4 do
                            gSettings.dots[x][y].width = activeNode.width;
                            gSettings.dots[x][y].length = activeNode.length;
                        end
                    end
                    settings.save();
                end

                if (imgui.Button('Apply Shape to All Dots')) then
                    for x = 0, 4 do
                        for y = 0, 4 do
                            gSettings.dots[x][y].shape = activeNode.shape;
                        end
                    end
                    settings.save();
                end

                if (imgui.Button('Apply Color to All Dots')) then
                    for x = 0, 4 do
                        for y = 0, 4 do
                            gSettings.dots[x][y].color = {
                                activeNode.color[1],
                                activeNode.color[2],
                                activeNode.color[3],
                                activeNode.color[4]
                            };
                        end
                    end
                    settings.save();
                end

                imgui.Spacing();

                local dotW = { activeNode.width or 0.5 };
                if (imgui.SliderFloat('Width (% Screen)', dotW, 0.1, 100.0, '%.1f%%')) then
                    activeNode.width = dotW[1];
                    settings.save();
                end

                local dotL = { activeNode.length or 0.5 };
                if (imgui.SliderFloat('Height (% Screen)', dotL, 0.1, 100.0, '%.2f%%')) then
                    activeNode.length = dotL[1];
                    settings.save();
                end

                local dotColor = { activeNode.color[1], activeNode.color[2], activeNode.color[3], activeNode.color[4] };
                if (imgui.ColorEdit4('Dot Color (RGB)', dotColor)) then
                    activeNode.color[1] = dotColor[1];
                    activeNode.color[2] = dotColor[2];
                    activeNode.color[3] = dotColor[3];
                    settings.save();
                end

                local dotAlpha = { activeNode.color[4] };
                if (imgui.SliderFloat('Dot Transparency', dotAlpha, 0.0, 1.0, '%.2f')) then
                    activeNode.color[4] = dotAlpha[1];
                    settings.save();
                end
            end

        end
        imgui.End();
    end
end);