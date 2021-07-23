# Roblox Layers Plugin

This plugin allows you to show / hide parts and models temporarily in Studio.

Steps:
1. Install the Layers plugin and make its panel visible. Press Enable in the plugin.
2. [Add a tag to something you want to hide](https://devforum.roblox.com/t/tag-editor-plugin/101465)
3. Reselect the thing you want to hide. The Layers plugin will show that tag as an option.
4. Press "Hide"
5. The Layers plugin will remember that tag in that game from then on, so you can toggle that tag's visible at any time.

Some tips and quirks:
* Don't forget to press "Disable" in the plugin before publishing your game, otherwise you might get weird behavior in-game.
   * This plugin makes use of collision groups to make parts not collide with the built-in tools. Disabling the plugin will remove the associated collision group.
* Layer changes intentionally last through undo/redo. We have to store layer changes in history to prevent layer changes from getting partially undone/redone by Studio, so you'll get an empty undo/redo after using the layers plugin.
* Layer visible only affects Parts, Decals, and Textures for now.

## Installation

Option 1: Install the plugin from [the Marketplace](https://www.roblox.com/library/7139038317/Layers).

Option 2: Download the model (rbxm) from the [releases page](https://github.com/Corecii/roblox-layers-plugin/releases), then place it in your Plugins folder.