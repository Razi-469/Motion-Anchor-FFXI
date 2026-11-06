addon.name     = 'MotionAnchorFFXI';
addon.author   = 'Razi-469';
addon.version  = '1.0';
addon.desc     = 'Creates a visual overlay anchor to help reduce motion sickness.';

local imgui = require('imgui');

--Creates Overlay;
local show_overlay = true;
local opacity = 0.4;
local grid_lines = 3;
local center_dot_size = 6.0;

--Commands are not included in this version, to be added for customization later;

--Checks to see if mounted state is true and returned false if not, and also if nil values or other entity pointers are detected;
local function is_mounted()
	local entity = GetPlayerEntity();
    if (entity == nil or entity.Pointer == 0) then
        return false;
    end
    return entity.StatusServer == 5;
end

--Renders the Overlay Display loop, grid display ends if character is not mounted;
ashita.events.register('d3d_present', 'present_cb', function ()
--If not mounted stop drawing the overlay
	if (not is_mounted()) then
		show_overlay = false
		else
		show_overlay = true
	end
    if (not show_overlay) then
        return;
    end

    --Sets up the full-screen transparent window overlay
    local io = imgui.GetIO();
    imgui.SetNextWindowPos({ 0, 0 });
    imgui.SetNextWindowSize({ io.DisplaySize.x, io.DisplaySize.y });

    local flags = ImGuiWindowFlags_NoDecoration +
                  ImGuiWindowFlags_NoInputs +
                  ImGuiWindowFlags_NoBackground +
                  ImGuiWindowFlags_NoMove +
                  ImGuiWindowFlags_NoSavedSettings +
                  ImGuiWindowFlags_NoFocusOnAppearing +
                  ImGuiWindowFlags_NoBringToFrontOnFocus;

    if (imgui.Begin('MotionAnchorOverlay', true, flags)) then
        local draw_list = imgui.GetBackgroundDrawList();
        local screen_w = io.DisplaySize.x;
        local screen_h = io.DisplaySize.y;
        local center_x = screen_w / 2.0;
        local center_y = screen_h / 2.0;

        local color = imgui.GetColorU32({ 1.0, 1.0, 1.0, opacity });

        --Draws the grid lines and center dot;
        for i = 1, grid_lines do
            local offset_x = (screen_w / (grid_lines + 1)) * i;
            local offset_y = (screen_h / (grid_lines + 1)) * i;

            --Vertical reference lines;
            draw_list:AddLine({ offset_x, 0 }, { offset_x, screen_h }, color, 1.0);
            --Horizontal reference lines;
            draw_list:AddLine({ 0, offset_y }, { screen_w, offset_y }, color, 1.0);
        end

        --Fixed center dot;
        local dot_color = imgui.GetColorU32({ 0.2, 0.8, 1.0, opacity + 0.2 });
        draw_list:AddCircleFilled({ center_x, center_y }, center_dot_size, dot_color);

        imgui.End();
    end
end);
