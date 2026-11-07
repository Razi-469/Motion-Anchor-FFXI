# Motion-Anchor-FFXI v1.2

Ashita v4 Addon for FFXI to help relieve motion sickness and visual vertigo.

This addon was written in a pretty raw Lua code.

Instructions, download the "MotionAnchorFFXI v1.2.zip" file, and unzip it.

It contains a folder named "MotionAnchorFFXI", the folder contains 1 file "MotionAnchorFFXI.lua".

Place the "MotionAnchorFFXI" folder in your ashita addons directory.

Use /addon load MotionAnchorFFXI in game or in your default ashita script to load the addon.

A settings.lua file will be created inside of /addons/config/addons/-Character Folder-

*Warning* do not use this addon if you suffer from epilepsy or visually induced seizures.
High contrasting grid like visuals can make those symptoms worse.

The addon draws a static grid on the screen.

<img width="1920" height="1080" alt="Screenshot (9)" src="https://github.com/user-attachments/assets/d6f3d721-58e4-4e3c-b24f-87361a2c446e" />

Open the settings using /anchor.

<img width="1920" height="1080" alt="Screenshot (10)" src="https://github.com/user-attachments/assets/ddf65bcd-51c2-4f6c-a1ab-baf05a527782" />

Settings menu explained from top to bottom.

Revert to default button resets all settings to a default thin white line grid.

A checkbox to "Only show overlay while on chocobo".

When checked this will look to see if the entity is in state 5 (mounted).

If they are it will draw the grid, if not it will not draw the grid.

When unchecked the grid will be visible at all times.

Border customization.

Sets the Line Width, Color, and Transparency of the border around the edge of the screen.

(You can click on the colored block to open the RGB Slider for color customization if you want)

<img width="1920" height="1080" alt="Screenshot (11)" src="https://github.com/user-attachments/assets/8235a50c-da71-4538-b1c8-51f65b6238cf" />

<img width="1920" height="1080" alt="Screenshot (12)" src="https://github.com/user-attachments/assets/6d5b0248-f772-4913-aeae-a72743d9728e" />

Grid Customization.

Sets the Line Width, Color, and Transparency of the 6 Grid Lines.

<img width="1920" height="1080" alt="Screenshot (14)" src="https://github.com/user-attachments/assets/9d082ed4-b40f-46f2-9583-c17b5c742b61" />

<img width="1920" height="1080" alt="Screenshot (15)" src="https://github.com/user-attachments/assets/e9d7d0ab-1afd-474d-9280-96dff2986011" />

5x5 Grid Dot Matrix

Each button in this section selects an intersection of the grid lines and/or border.

You may select each point on the for customizatio.

Underneath the matrix you may select the shape to use as the dot.

Square, Circle, Diamond, Chevron Up, or Chevron Down.

Once desired shape is selected you can adjust the Width, Height, Color, and Transparency with the settings at the bottom.

You may click the button to copy the size, shape, and color settings to all dots on the grid.

Changing the shape will change the button label.

(O) for Circle

(#) for Square

(<>) for Diamond

(^) for Chevron Up

(v) for Chevron Down

(x) Focal Point

<img width="1920" height="1080" alt="Screenshot (16)" src="https://github.com/user-attachments/assets/1c8d16ff-cfb0-43ce-90ab-31ba1993e8cb" />

<img width="1920" height="1080" alt="Screenshot (17)" src="https://github.com/user-attachments/assets/c5afc943-9247-4e5a-8b5d-5fb9dd249834" />

<img width="1920" height="1080" alt="Screenshot (18)" src="https://github.com/user-attachments/assets/3d7416d4-b88b-47a4-9aab-3a41418b989f" />

<img width="1920" height="1080" alt="Screenshot (20)" src="https://github.com/user-attachments/assets/2af20595-8558-4b51-ac26-42110c6f1f05" />

Changing the color of the dot will change the color of the border around that button.

A checkbox is included for a focal point.

If a dot is selected and "Focal Point" is checked it will draw over the grid lines in the shape of that dot, with a transparent section creating a clear Focal Point for your eyes to focus.

<img width="1920" height="1080" alt="Screenshot (22)" src="https://github.com/user-attachments/assets/c3b1a212-8000-490e-ac6b-6bfe94c11777" />

There are no known conflicts between this addon and others.

As far as I'm aware it is backwards compatible with previous versions of Ashita.

The addon is very niche and should only be used for relieving symptoms of motion sickness.
This addon is not intended to enhance any visuals of the game screen and never will be.
