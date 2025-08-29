


## Script Support

📌 **Important:**  
- **Support** is provided **via Discord tickets** for **PAID** resources **ONLY**: [Join the Discord](https://discord.gg/BJGFrThmA8)  
- ❌ **Any tickets created for free scripts will be immediately closed.**  
- 💬 **For free script support**, please use the **gated channels** in Discord.  
- **Extensive documentation** for this script can be found by clicking [here](https://lusty94-scripts.gitbook.io/documentation/free/job-center)





## OVERVIEW

🏠 Lusty94 Job Center 

A fully modular job center for players to visit and view available employment offers and their current salaries.
Players can purchase useable identity documents such as a passport, police or medic badges.
Players can also purchase granted licenses such as driving, weapon and business licenses.
Commands for defined jobs to allow granting and revoking of licenses to players.
Cooldowns to prevent job switching abuse
Infinitely expandable for your server requirements






## FEATURES

``Multi Location Job Centers``
- Define as many locations as you wish each fully configurable
- Optional choice of target zone or ped to interact with
- Locations can have just jobs available, just licenes or just identity documents or all of them the choice is yours


``Unlimited Employment Offers``
- Define as many jobs as you wish each with their own unique job information
- Salary is displayed direct from jobs.lua
- Confirmation of employment offer for applicant
- Configurable cooldown timer for job switches


``Unlimited Licene Types``
- Define as many licenes as you wish 
- Commands for defined jobs to grant and remove license types to players
- Choice of payment type cash or bank
- Option to set licenes to be free and cost 0 which skips payment type input


``Unlimited Identity Documents``
- Define as many identity documents as you wish each with their own unique information
- Option to job lock documents
- Option to rank lock job required documents
- Add custom data to each item and create as many useable documents as you want
- Useable documents display information to nearby players


``Security Focused``
- Respective security checks where required
- Optional logging via fm-logs or Discord
- Optional kick punishment for exploiters
- Configurable job switching cooldown timer





## DEPENDENCIES

- Ensure all depenedencies are start BEFORE this script

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [ox_lib](https://github.com/overextended/ox_lib/releases/)
- [qb-target](https://github.com/qbcore-framework/qb-target) or [ox_target](https://github.com/overextended/ox_target/releases/)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) or [ox_inventory](https://github.com/overextended/ox_inventory/releases/) or supported scripts
- [fm-logs](https://github.com/FiveMerr/fm-logs) only required if used for logging





## INSTALLATION

- Ensure all depenedencies are start BEFORE this script
- Add the related items list inside [ITEMS] folder to your items.lua
- Add the images inside [IMAGES] folder to your inventory images folder
- Configure the core settings to suit your server requirements
- Configure the job center locations to suit your server requirements
- Configure jobs required at each location ensuring these are in your jobs.lua file
- Configure licenses required at each location ensuring these are in your qb-core/config.lua licenses metadata table
- Configure identity documents required at each location ensuring the required data is added to the neccessary callbacks and events
- If using the logging system ensure you have set this up correctly (for Discord logs ensure you have set your webhook URL in SERVER/FUNCS.LUA)
- For detailed configurations and advanced setups, refer to the official documentation.
- Due to the give license and remove license commands being similair to the commands used in qb-policejob it is advised to remove those commands in qb-policejob/server/commands.lua





## CHANGELOGS

Version 1.0.0
- Initial release