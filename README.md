# Reaper Custom Scripts by Kimitri

A collection of custom **REAPER scripts** designed to speed up workflow, improve mixing organization, and bring a touch of creativity to music production.  

These scripts are lightweight, easy to install, and each one focuses on solving a very specific problem. 

<details>
 <summary><b>Move new FX before the chosen FX</b></summary>

This REAPER script automatically moves any **newly added FX** in a track **before a chosen FX** (for example, a VU Meter) – but **only when there is a change** in the FX chain.  

## ✨ Features
- Prompts the user to select a **target FX** (by full or partial name).  
- Any newly added FX will automatically be moved **before that FX**.  
- The chosen FX name is saved, so you only need to select it once.  
- Works across all tracks in the project.  

## 🎚 Motivation
This script was created to simulate the workflow of **legendary analog mixing consoles**, where each channel had a **dedicated VU meter**.  
- The VU meter should always stay at the **end of the FX chain**.  
- This way, every time you add a new FX to a track, you can still monitor whether the signal is exceeding **0 dB VU** *after* that effect.  
- It is especially useful when using plugins that support **“Show embedded UI in MCP”**, such as **VU Meter (ZenoMOD)**, since you can always keep visual feedback right inside the mixer.  

## 🛠 Installation
1. Copy the script file (`VU_FX_Keeper.lua`) into your REAPER Scripts folder; 

2. In REAPER, open the **Action List**, click *Load…*, and select the script.  
3. Run the script (or set it to run at startup).  

## ⚙️ Usage
1. The first time you run it, you will be asked to type the name (or part of the name) of the FX you want to use as the reference.  
- Example: `"VU Meter"`  
2. From then on, whenever you add new FX to a track, they will be moved to **just before that chosen FX**.  
3. To change the chosen FX, delete the saved state:  
- Menu: *Extensions > ReaScript console output > Clear extstate* (or by editing the code).  



</details>

<details>
 <summary><b>Insert Track with Next Palette Color</b></summary>

This REAPER script automatically assigns a **track color** based on a predefined palette inside the code.  
Each time it is run, it applies the **next color in sequence**, cycling through the palette you defined.  

## ✨ Features
- Uses a **custom color palette** (defined directly in the script).  
- Applies the **next color** in the palette to the selected tracks.  
- Remembers the last color used, so the sequence continues consistently.  

## 🎚 Motivation
Keeping tracks visually organized is crucial in large projects.  
This script lets you quickly cycle through a set of **hand-picked colors** so every new track you add is immediately colorized, without manual selection.  

## 🛠 Installation
1. Copy the script file (`SetNextColor.lua`) into your REAPER Scripts folder.  
2. In REAPER, open the **Action List**, click *Load…*, and select the script.  

## ⚙️ Usage
1. Import the script into the Action List.  
2. Create a **Custom Action** in the following order:  
   - `Track: Insert new track`  
   - `Script: ColonizeTrack.lua`  
3. Give this custom action a clear name, such as **"New Track (Colorized)"**.  
4. Assign it to a toolbar button or a keyboard shortcut.  
5. From now on, whenever you run this action, it will:  
   - Insert a new track  
   - Automatically colorize it with the **next color in your palette**.  
 

</details>
