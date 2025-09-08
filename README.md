# Reaper Custom Scripts by Kimitri

A collection of custom **REAPER scripts** designed to speed up workflow, improve mixing organization, and bring a touch of creativity to music production.  

These scripts are lightweight, easy to install, and each one focuses on solving a very specific problem. 

### 📥 Download
You can download the full **REAPER configuration file** containing my **custom workflow, this repository scripts setting up correctly, key mappings, and settings** from the [Releases](https://github.com/kimitrii/reaper-scripts/releases) page.  

#### How to Install
1. Go to the [Releases page](https://github.com/kimitrii/reaper-scripts/releases).  
2. Download the `.ReaperConfigZip` file.  
3. In REAPER, open:
   Options > Preferences > General > Import Configuration  
4. Select the downloaded `.ReaperConfigZip`.  
5. Choose what to import (scripts, menus, toolbars, actions).  
6. Restart REAPER and enjoy the workflow. ✅

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

<details>
 <summary><b>Auto Receive Sends to AUX</b></summary>

This REAPER script automatically creates **sends from all relevant tracks** to a newly selected track **inside a chosen AUX folder**.  

It simulates the workflow of **Ableton Live’s return tracks**, where every new auxiliary channel is instantly available for sends, without requiring manual routing.  

## ✨ Features
- Prompts the user to set the **AUX folder name** once (e.g., `"AUX"` or `"Bus"`).  
- The folder name is **saved permanently** and remembered between REAPER sessions.  
- When you select a track inside the AUX folder, all eligible tracks will automatically create a send to it.  
- Avoids duplicates (existing sends are ignored).  
- Ignores folder parents (only child tracks are connected).  

## 🎚 Motivation
Coming from **Ableton Live**, auxiliary tracks (*Return Tracks*) are always ready to receive sends from every track in the project.  

By default, REAPER requires manual routing for each new AUX track.  
This script brings back the **Ableton-style behavior**:  
- Create a new AUX track inside your chosen folder.  
- Select it once.  
- Instantly, all other tracks in the project (except other AUX tracks and folders) will send to it.  

This way, you can build flexible effect chains (reverbs, delays, parallel compression, etc.) with just **one click or shortcut**, instead of repeatedly setting up sends.  

## 🛠 Installation
1. Copy the script file (`AutoReceiveSends.lua`) into your REAPER Scripts folder.  
2. In REAPER, open the **Action List**, click *Load…*, and select the script.  

## ⚙️ Usage
1. The first time you run the script, you’ll be asked to enter the name of your **AUX folder** (e.g., `"AUX"`).  
   - This name is saved permanently for future sessions.  
2. Organize your project so all your auxiliary tracks are inside this folder.  
3. Select a track inside the AUX folder.  
4. Run the script (via Action List, a toolbar button, or a keyboard shortcut).  
   - All eligible tracks in your project will now send to the selected AUX track.  
5. To change the chosen folder name, clear the saved state or edit the script.  

</details>

<details>
 <summary><b>Create Sends from Selected Track to AUX Children</b></summary>

This REAPER script automatically creates **sends from the selected track** to **all tracks inside a chosen AUX folder**.  

It is especially useful if you want to quickly route a single track to multiple auxiliary effect tracks at once (reverbs, delays, parallel chains, etc.), without manually creating each send.  

## ✨ Features
- Prompts the user to set the **AUX folder name** once (e.g., `"AUX"` or `"Bus"`).  
- The folder name is **saved permanently** and remembered between REAPER sessions.  
- When you select a track outside the AUX folder and run the script, it will:  
  - Find your AUX folder.  
  - Collect all its child tracks.  
  - Create sends from the selected track to each child track.  
- Avoids duplicates (existing sends are ignored).  

## 🎚 Motivation
In DAWs like **Ableton Live**, return tracks are globally accessible, but in REAPER, you often have to create multiple sends manually.  

This script speeds up that process by letting you route a track to **all AUX tracks inside a folder** in just one action.  
It’s perfect for workflows where you have multiple effect returns grouped under one folder (for example: *Reverb AUX*, *Delay AUX*, *Parallel Compression AUX*).  

## 🛠 Installation
1. Copy the script file (`SendToAUXChildren.lua`) into your REAPER Scripts folder.  
2. In REAPER, open the **Action List**, click *Load…*, and select the script.  

## ⚙️ Usage
1. The first time you run it, you will be asked for the name of your AUX folder (e.g. `"AUX"`).  
   - The name will be remembered for future sessions.  

2. There are two main ways to use it:  

   - **Manual** → Select any track *outside* the AUX folder and run the script.  
   - **Automatic (recommended)** → Create a *Custom Action* so every new track is instantly routed to AUX sends:  
     1. Go to **Actions > Show Action List > New Action > New Custom Action**.  
     2. Add the following actions in order:  
        - `Track: Insert new track`  
        - `Script: ColorizeTrack.lua` (optional, for consistent colors)  
        - `Script: AutoSendSendsToAUX.lua`  
     3. Save it as **New Track** (or any name you like).  
     4. Assign it to a shortcut key or toolbar button.  

👉 From now on, every time you create a new track using this custom action, it will **already come with all the correct sends** to your AUX folder children.  

</details> 

</details>
