local QBCore = exports['qb-core']:GetCoreObject()
local NotifyType = Config.CoreSettings.Notify.Type or 'qb'
local TargetType = Config.CoreSettings.Target.Type or 'qb'
local InvType = Config.CoreSettings.Inventory.Type or 'qb'
local CashSymbol = Config.CoreSettings.Misc.CashSymbol or '$'
local jobZones = {}
local jobPeds = {}
local jobBlips = {}


--sends a client debug print
function CLDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--sends a client notification
function CLNotify(msg, type, time, title)
    if NotifyType == nil then print('^1| Lusty94_JobCenter | DEBUG | ERROR: NotifyType is nil!') return end
    if not msg then msg = 'Notification sent with no message!' end
    if not type then type = 'success' end
    if not time then time = 5000 end
    if not title then title = 'Notification' end
    if NotifyType == 'qb' then
        QBCore.Functions.Notify(msg,type,time)
    elseif NotifyType == 'qs' then
        exports['qs-interface']:AddNotify(msg, title, time, 'fa-solid fa-clipboard')
    elseif NotifyType == 'okok' then
        exports['okokNotify']:Alert(title, msg, time, type, true)
    elseif NotifyType == 'mythic' then
        exports['mythic_notify']:DoHudText(type, msg)
    elseif NotifyType == 'ox' then
        lib.notify({ title = title, description = msg, position = 'top', type = type, duration = time})
        elseif NotifyType == 'lation' then
        exports.lation_ui:notify({title = title, message = msg, type = type, duration = time, icon = 'fa-solid fa-clipboard',})
    elseif NotifyType == 'wasabi' then
        exports.wasabi_notify:notify(title, msg, time, type)
    elseif NotifyType == 'custom' then
        --insert your custom notification function here
    else
        print('^1| Lusty94_JobCenter | DEBUG | ERROR | Unknown Notify Type Set In Config.CoreSettings.Notify.Type | '..tostring(NotifyType))
    end
end


--set busy status
function setBusy(toggle)
    busy = toggle
    CLDebug(('^3| Lusty94_JobCenter | DEBUG | Info | Busy Status %s'):format(tostring(busy)))
end


--lock inventory to prevent exploits
function LockInventory(toggle)
	if toggle then
        LocalPlayer.state:set("inv_busy", true, true)
    else 
        LocalPlayer.state:set("inv_busy", false, true)
    end
    CLDebug(('^3| Lusty94_JobCenter | DEBUG | Info | Inventory Lock %s'):format(tostring(toggle)))
end


---get an item image
function ItemImage(img)
	if InvType == 'ox' then
        if not tostring(img) then CLDebug('^1| Lusty94_JobCenter | DEBUG | ERROR | Item: '..tostring(img)..' is missing from ox_inventory/data/items.lua!^7') return "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"  end 
		return "nui://ox_inventory/web/images/"..img..'.png'
	elseif InvType == 'qb' or InvType == 'qs' then
		if not QBCore.Shared.Items[img] then CLDebug('^1| Lusty94_JobCenter | DEBUG | ERROR | Item: '..tostring(img)..' is missing from qb-core/shared/items.lua!^7') return "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"  end
		return "nui://qb-inventory/html/images/"..QBCore.Shared.Items[img].image
	elseif InvType == 'custom' then
        -- Insert your own methods for obtaining item images here
	else
        print('| Lusty94_JobCenter | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
	end
end


--get an item label
function ItemLabel(label)
	if InvType == 'ox' then
		local Items = exports['ox_inventory']:Items()
		if not Items[label] then CLDebug('^1| Lusty94_JobCenter | DEBUG | ERROR | Item: '..tostring(label)..' is missing from ox_inventory/data/items.lua!^7') return '❌ The item: '..tostring(label)..' is missing from your items.lua! ' end
		return Items[label]['label']
    elseif InvType == 'qb' or InvType == 'qs' then
		if not QBCore.Shared.Items[label] then CLDebug('^1| Lusty94_JobCenter | DEBUG | ERROR | Item: '..tostring(label)..' is missing from qb-core/shared/items.lua!^7') return '❌ The item: '..tostring(label)..' is missing from your items.lua! ' end
		return QBCore.Shared.Items[label]['label']
	elseif InvType == 'custom' then
        -- Insert your own methods for obtaining item labels here
	else
        print('| Lusty94_JobCenter | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
	end
end


--job center locations
CreateThread(function()
    for location, data in pairs(Config.Locations) do
        while not LocalPlayer.state.isLoggedIn do Wait(500) end
        local zone = data.zone
        if not zone or not zone.coords or type(zone.coords) ~= 'vector4' then CLDebug(('^1| Lusty94_JobCenter | DEBUG | ERROR | %s is missing vector4 coords'):format(location)) return end
        local pos = vector3(zone.coords.x, zone.coords.y, zone.coords.z)
        local heading = zone.coords.w or 0.0
        local radius = zone.radius or 1.0
        local label = (data.target and data.target.label) or 'Employment Info'
        local icon = (data.target and data.target.icon) or 'fa-solid fa-clipboard'
        local dist = (data.target and data.target.distance) or 3.0
        local scenario = (data.target and data.target.scenario) or 'WORLD_HUMAN_CLIPBOARD'
        if data.target and data.target.ped then
            local model = data.target.model
            if not model or model == '' then CLDebug(('^1| Lusty94_JobCenter | DEBUG | ERROR | %s ped is enabled but no model is defined'):format(location)) return end
            local pedModel = joaat(model)
            lib.requestModel(pedModel, 30000)
            local ped = CreatePed(0, pedModel, zone.coords.x, zone.coords.y, zone.coords.z - 1.0, heading, false, true)
            CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Location %s | Ped Model %s | Coords %s |'):format(location, model, pos))
            SetEntityAsMissionEntity(ped, true, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            if scenario then TaskStartScenarioInPlace(ped, scenario, 0, false) end
            jobPeds[location] = ped
            if TargetType == 'qb' then
                exports['qb-target']:AddTargetEntity(ped, {
                    options = {{
                        icon = icon,
                        label = label,
                        action = function()
                            openJobCenter(location)
                        end
                    }},
                    distance = dist
                })
            elseif TargetType == 'ox' then
                exports.ox_target:addLocalEntity(ped, {{
                    icon = icon,
                    label = label,
                    distance = dist,
                    onSelect = function()
                        openJobCenter(location)
                    end
                }})
            end
        else
            if TargetType == 'qb' then
                local name = 'jobcenter_'..location
                exports['qb-target']:AddCircleZone(name, pos, radius, {
                    name = name,
                    useZ = true,
                    debugPoly = zone.debug or false,
                }, {
                    options = {{
                        icon = icon,
                        label = label,
                        action = function()
                            openJobCenter(location)
                        end
                    }},
                    distance = dist
                })
                jobZones[location] = { zoneName = name }
            elseif TargetType == 'ox' then
                local zone = exports.ox_target:addSphereZone({
                    coords = pos,
                    radius = radius,
                    debug = zone.debug or false,
                    options = {{
                        icon = icon,
                        label = label,
                        distance = dist,
                        onSelect = function()
                            openJobCenter(location)
                        end
                    }}
                })
                jobZones[location] = { zoneName = zone }
            end
            CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Location %s | Targets Created For %s | Coords %s |'):format(location, TargetType:upper(), pos))
        end
        if data.blip and data.blip.enabled then
            local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
            SetBlipSprite(blip, data.blip.id or 5)
            SetBlipScale(blip, data.blip.scale or 0.6)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, data.blip.colour or 3)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(data.blip.title or location)
            EndTextCommandSetBlipName(blip)
            jobBlips[location] = blip
            CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Location %s | Blip Created |'):format(location))
        end
    end
end)


--progress circle
function progressCircle(location)
    local data = Config.Locations[location]
    if not data then return CLDebug(('^1| Lusty94_JobCenter | DEBUG | ERROR | Invalid Location %s |'):format(location)) end
    local progress = lib.progressCircle({
        duration = data.progress.duration,
        label = data.progress.label,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true, sprint = true, mouse = false },
        anim = {
            dict = data.progress.anim.anim,
            clip = data.progress.anim.dict,
            flag = data.progress.anim.flag,
        },
        prop = {
            model = data.progress.prop.model,
            bone = data.progress.prop.bone,
            pos = data.progress.prop.pos,
            rot = data.progress.prop.rot,
        },
    })
    if not progress then CLNotify(Config.Language.Notifications.Cancelled, 'error') return false end
    return progress
end


--payment method
function paymentMethod()
    local input = lib.inputDialog('Select Payment Method', {{
        type = 'select',
        label = 'Payment Method',
        name = 'method',
        required = true,
        options = {
            { label = 'Cash', value = 'cash' },
            { label = 'Bank', value = 'bank' },
        }
    }})
    if not input then CLNotify(Config.Language.Notifications.Cancelled, 'error') return nil end
    return tostring(input[1])
end


--get job rank
function getJobGrade(job)
    if not job then return 0 end
    local grade = job.grade
    if type(grade) == 'table' then
        return tonumber(grade.level) or 0
    elseif type(grade) == 'number' then
        return grade
    end
    return 0
end


--open job center
function openJobCenter(location)
    local data = Config.Locations[location]
    if not data then return CLDebug(('^1| Lusty94_JobCenter | DEBUG | ERROR | Invalid Location %s |'):format(location)) end
    local PlayerData = QBCore.Functions.GetPlayerData()
    local currentJob = PlayerData.job.name
    local playerGradeLevel = getJobGrade(PlayerData.job) 
    local currentLicenses = PlayerData.metadata.licenses or {}
    local options = {}
    if not data.jobs then CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | No job data provided for %s |'):format(location)) goto continue end
    if data.jobs then
        options[#options + 1] = {
            title = 'Available Jobs',
            icon = 'fa-solid fa-clipboard',
            description = 'View available employment offers',
            arrow = true,
            onSelect = function()
                local minutesLeft = lib.callback.await('lusty94_jobcenter:server:checkCooldown', false) or 0
                if minutesLeft > 0 then CLNotify((Config.Language.Notifications.Cooldown):format(minutesLeft), 'error') return end
                local jobMenu = {}
                for jobName, jobData in pairs(data.jobs) do
                    local jobLabel = QBCore.Shared.Jobs[jobName].label or 'Unknown'
                    local salary = QBCore.Shared.Jobs[jobName].grades['0'].payment or 0
                    local isCurrentJob = (currentJob == jobName)
                    jobMenu[#jobMenu + 1] = {
                        title = isCurrentJob and ('✅ %s'):format(jobName:gsub("^%l", string.upper)) or jobName:gsub("^%l", string.upper),
                        description = (jobData.info..'\nStarting salary is: %s%s' or 'No job description available'):format(CashSymbol, salary),
                        icon = 'fa-solid fa-circle-check',
                        disabled = isCurrentJob,
                        onSelect = function()
                            if isCurrentJob then CLNotify(Config.Language.Notifications.AlreadyHaveJob, 'error') return end
                            local confirm =  lib.alertDialog({
                                header = 'Employment Offer',
                                content = (Config.Language.Notifications.Confirmation):format(jobLabel, CashSymbol, salary),
                                centered = true,
                                cancel = true,
                            })
                            if confirm ~= 'confirm' then CLNotify(Config.Language.Notifications.Cancelled, 'error') return end
                            if not progressCircle(location) then return end
                            local success = lib.callback.await('lusty94_jobcenter:server:setJob', false, jobName, location)
                            if not success then return end
                            CLNotify((Config.Language.Notifications.NewJob):format(jobLabel), 'success')
                            CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Location %s | Changed Job To %s |'):format(location, jobLabel))
                        end
                    }
                end
                jobMenu[#jobMenu + 1] = {
                    title = '⬅️ Return',
                    icon = 'arrow-left',
                    description = 'Return to the main menu',
                    onSelect = function()
                        openJobCenter(location)
                    end
                }
                lib.registerContext({
                    id = 'lusty94_jobcenter_jobs',
                    title = 'Available Jobs',
                    options = jobMenu
                })
                lib.showContext('lusty94_jobcenter_jobs')
            end
        }
    end
    if not data.licenses then CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | No license data provided for %s |'):format(location)) goto continue end
    if data.licenses then
        options[#options + 1] = {
            title = 'Licenses',
            icon = 'fa-solid fa-id-card',
            description = 'Purchase available licenses',
            arrow = true,
            onSelect = function()
                local ownedLicences = lib.callback.await('lusty94_jobcenter:server:getLicences', false) or {}
                local licenseMenu = {}
                for licenseName, licenseData in pairs(data.licenses) do
                    local hasLicense = ownedLicences[licenseName] == true
                    local requiredRank = tonumber(licenseData.rank or 0)
                    local hasRank = (requiredRank == 0) or (playerGradeLevel >= requiredRank)
                    local itemName = licenseData.item
                    local cost = tonumber(licenseData.cost) or 0
                    licenseMenu[#licenseMenu + 1] = {
                        title = hasLicense and ('✅ %s'):format(licenseName:gsub("^%l", string.upper)) or licenseName:gsub("^%l", string.upper),
                        description = ('%s\nCost: %s%s'):format(licenseData.info or 'No license info provided', CashSymbol, cost),
                        icon = 'fa-solid fa-file-signature',
                        image = ItemImage(itemName),
                        disabled = (not hasLicense) or (not hasRank),
                        onSelect = function()
                            if not hasLicense then CLNotify(Config.Language.Notifications.NoAccess, 'error') return end
                            if not hasRank then CLNotify((Config.Language.Notifications.WrongRank):format(requiredRank), 'error') return end
                            if cost > 0 then
                                paymentType = paymentMethod()
                                if not paymentType then return end
                            end
                            if not progressCircle(location) then return end
                            local success = lib.callback.await('lusty94_jobcenter:server:giveLicense', false, licenseName, cost, location, paymentType, itemName)
                            if not success then return end
                            CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Location %s | License Type %s | Cost %s%s | Payment Type %s | Received Item %s |'):format(location, licenseName:upper(), CashSymbol, cost or 0, (paymentType and paymentType:upper()) or 'FREE', ItemLabel(itemName)))
                            ownedLicences = lib.callback.await('lusty94_jobcenter:server:getLicences', false) or {}
                        end
                    }
                end
                licenseMenu[#licenseMenu + 1] = {
                    title = '⬅️ Return',
                    icon = 'arrow-left',
                    description = 'Return to the main menu',
                    onSelect = function()
                        openJobCenter(location)
                    end
                }
                lib.registerContext({
                    id = 'lusty94_jobcenter_licenses',
                    title = 'Available Licenses',
                    options = licenseMenu
                })
                lib.showContext('lusty94_jobcenter_licenses')
            end
        }
    end
    if not data.identity then CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | No identity data provided for %s |'):format(location)) goto continue end
    if data.identity then
        options[#options + 1] = {
            title = 'Identification',
            icon = 'fa-solid fa-id-card',
            description = 'Purchase available forms of identification',
            arrow = true,
            onSelect = function()
                local identityMenu = {}
                local playerJobName = currentJob
                for identityName, identityData in pairs(data.identity) do
                    local requiresJob = identityData.requiredJob
                    local requiredRank = tonumber(identityData.rank or 0)
                    local job  = (not requiresJob) or (playerJobName == requiresJob)
                    local rank = (requiredRank == 0) or (playerGradeLevel >= requiredRank)
                    local desc = ''
                    local itemName = identityData.item
                    local cost = tonumber(identityData.cost) or 0
                    if requiresJob then desc = desc..('\nRequires job: %s'):format(requiresJob:gsub('^%l', string.upper)) end
                    if requiredRank > 0 then desc = desc..('\nRequires rank: %d+'):format(requiredRank) end
                    identityMenu[#identityMenu + 1] = {
                        title = ItemLabel(identityName),
                        description = ('%s\nCost: %s%s%s'):format(identityData.info or 'No info provided', CashSymbol, cost, desc),
                        icon = 'fa-solid fa-file-signature',
                        image = ItemImage(itemName),
                        disabled = (not job) or (not rank),
                        onSelect = function()
                            if not job then CLNotify(Config.Language.Notifications.NoAccess, 'error') return end
                            if not rank then CLNotify((Config.Language.Notifications.WrongRank):format(requiredRank), 'error') return end
                            if cost > 0 then
                                paymentType = paymentMethod()
                                if not paymentType then return end
                            end
                            if not progressCircle(location) then return end
                            local success = lib.callback.await('lusty94_jobcenter:server:giveDocument', false, identityName, cost, location, paymentType, itemName)
                            if not success then return end
                            CLDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | ID %s | Cost %s%s | Pay %s | Item %s |'):format(identityName:upper(), CashSymbol, cost, (paymentType and paymentType:upper()) or 'FREE', ItemLabel(itemName)))
                        end
                    }
                end
                identityMenu[#identityMenu + 1] = {
                    title = '⬅️ Return',
                    icon = 'arrow-left',
                    description = 'Return to the main menu',
                    onSelect = function()
                        openJobCenter(location)
                    end
                }
                lib.registerContext({
                    id = 'lusty94_jobcenter_id',
                    title = 'Available Identity Documents',
                    options = identityMenu
                })
                lib.showContext('lusty94_jobcenter_id')
            end
        }
    end
    ::continue::
    lib.registerContext({
        id = 'lusty94_jobcenter_main',
        title = location..' Services',
        options = options
    })
    lib.showContext('lusty94_jobcenter_main')
end


--show document
RegisterNetEvent('lusty94_jobcenter:client:ShowDocument', function()
    local playerPed = cache.ped
    local propname = 'prop_fib_badge'
    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local prop = CreateObject(GetHashKey(propname), x, y, z + 0.2, true, true, true)
    local bone = GetPedBoneIndex(playerPed, 28422)
    local dict = 'paper_1_rcm_alt1-9'
    local anim = 'player_one_dual-9'
    lib.requestAnimDict('paper_1_rcm_alt1-9', 30000)
    AttachEntityToEntity(prop, playerPed, bone, 0.12, 0.01, -0.06, -310.0, 10.0, 150.0, true, true, false, true, 1, true)
    lib.playAnim(playerPed, dict, anim, 3.0, -1, -1, 50, 0, false, 0, false)
    Wait(3500)
    DeleteEntity(prop)
    ClearPedTasks(playerPed)
end)


--toggle status
RegisterNetEvent('lusty94_jobcenter:client:toggleStatus', function()
    setBusy(false)
    LockInventory(false)
end)


--notify
RegisterNetEvent('lusty94_jobcenter:client:notify', function(msg, type, time)
    CLNotify(msg, type, time)
end)


--cleanup logic
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for location, peds in pairs(jobPeds) do
            if DoesEntityExist(peds) then
                if TargetType == 'qb' then
                    exports['qb-target']:RemoveTargetEntity(peds)
                elseif TargetType == 'ox' then
                    exports.ox_target:removeLocalEntity(peds)
                end
                DeleteEntity(peds)
            end
        end
        for location, zones in pairs(jobZones) do
            if zones.zoneName then
                if TargetType == 'ox' then
                    exports.ox_target:removeZone(zones.zoneName)
                elseif TargetType == 'qb' then
                    exports['qb-target']:RemoveZone(zones.zoneName)
                end
            end
        end
        for loc, blip in pairs(jobBlips) do
            if blip and DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        jobPeds = {}
        jobZones = {}
        jobBlips = {}
        print('^2| Lusty94_JobCenter | DEBUG | INFO | Resource Stopped')
    end
end)