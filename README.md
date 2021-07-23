# Roblox Layers Plugin

This plugin allows you to show / hide parts and models temporarily in Studio.

Some tips:
* Don't forget to press "Disable" in the plugin before publishing your game, otherwise you might get weird behavior in-game.
   * This plugin makes use of collision groups to make parts not collide with the built-in tools. Disabling the plugin will remove the associated collision group.
* Layer changes intentionally last through undo/redo. We have to store layer changes in history to prevent layer changes from getting partially undone/redone by Studio, so you'll get an empty undo/redo after using the layers plugin.

## Installation

Option 1: Install the plugin from [the Marketplace](https://www.roblox.com/library/7139038317/Layers).

Option 2: Download the model (rbxm) from the [releases page](https://github.com/Corecii/roblox-layers-plugin/releases), then place it in your Plugins folder.