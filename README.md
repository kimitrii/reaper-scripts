# Move new FX before the chosen FX

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

