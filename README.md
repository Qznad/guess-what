# guess-what
[Working Title] – Early Multiplayer Horror Build

## 8/4/2025 
  # 🛠️ Recent Updates

  - Added **object throwing and holding** mechanics
  - Implemented **door interaction** (open/close)
  - Started building a **dark base map** for the game
## 8/5/2025
  # 🛠️ New Features & Improvements

  - Interactive Lever and Wheel : Added lever and wheel objects that players can spin or switch to trigger events such as opening doors, activating lights, or lowering bridges.
    
  - Enhanced InteractionComponent : Updated to support event triggering when levers, wheels, or switches are used — making it easy to connect game elements dynamically.
    
  - Item Pickup System : Items can now be picked up by the player. This is the groundwork for a full inventory system planned for future updates.
    
  - Visual Feedback with Shader Outline : Implemented a pixel-perfect outline shader (from Perfect Outline Shader) that highlights items when the player is within 10 meters, improving item visibility and interaction clarity.
    
  - Dynamic Reticle Feedback :
    - Implemented dynamic reticle changes :
      - Simple dot when idle
      - Open hand when able to interact with an object
      - Holding hand when interacting or holding an object
        
  - Player Flashlight : Added a toggleable flashlight for the player, controlled with the “F” key for better visibility in dark areas.
    
  - Acknowledgments :
    Special thanks to Crooked Smile Studios for the excellent Godot tutorials .
  # 🎨 Assets & Resources Used
  - Reticle Textures : The dynamic reticle icons (simple dot, open hand, holding hand) use the Cursor Pixel Pack by Kenney:
      https://kenney.nl/assets/cursor-pixel-pack
  - Outline Shader : The pixel-perfect outline shader script was adapted from this excellent resource:
      https://godotshaders.com/shader/pixel-perfect-outline-shader/
## 8/6/2025 
  # 🛠️ Recent Updates
  - fixed some bugs related to interaction objects (some still need fixing )
  - added monster as a player 3 meters tall can't crouch through vents but he's fast , always have a red flashlight on which is 35 meter range and stronger then normal player
  - recreated the map in a cleaner way
      # THINGS TO DO :
      - add server handling for early testing
      - add inventory system to player
      - ability to prone as a monster
      - spawn points to the player and monster
      - fix interactions bugs
      - add a main menu
      - add dynamic sounds (walking sound , flashlight on and off , monster walking sound , etc ... )
      - add voice chat , and text chat
      - create model for players
    the list still long but these are the goals for now
