local QBCore = exports['qb-core']:GetCoreObject()
local InvType = Config.CoreSettings.Inventory.Type or 'qb'
local NotifyType = Config.CoreSettings.Notify.Type or 'qb'
local CashSymbol = Config.CoreSettings.Misc.CashSymbol or '$'
local playerCooldowns = playerCooldowns or {}



--server debug function
function SVDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--get character name
function getCharacterName(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local info = Player.PlayerData.charinfo
        return (info.firstname or 'Unknown')..' '..(info.lastname or 'Unknown')
    end
    return 'Unknown'
end


--send logs
function sendLog(source, logType, message, level)
    local src = source
    local name = getCharacterName(src)
    local logsEnabled = Config.CoreSettings.Security.Logs.Enabled
    if not logsEnabled then return end
    local logging = Config.CoreSettings.Security.Logs.Type
    if logging == 'discord' then
        local webhookURL = '' -- set your discord webhook URL here
        if webhookURL == '' then print('^1| Lusty94_JobCenter | DEBUG | ERROR | Logging method is set to Discord but WebhookURL is missing!') return end
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "Lusty94_JobCenter Logs",
            avatar_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png",
            embeds = {{
                title = "**"..(logType or "Job Center Log").."**",
                description = message or ("Log triggered by **%s** (ID: %s)"):format(name, source),
                color = level == "warning" and 16776960 or level == "error" and 16711680 or 65280,
                footer = {
                    text = "Lusty94_JobCenter Logs • "..os.date("%Y-%m-%d %H:%M:%S"),
                    icon_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                thumbnail = {
                    url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                author = {
                    name = 'Lusty94_JobCenter Logs'
                }
            }}
        }), { ['Content-Type'] = 'application/json' })
    elseif logging == 'fm-logs' then
        if not GetResourceState('fm-logs') or GetResourceState('fm-logs') ~= 'started' then
            print('^1| Lusty94_JobCenter | DEBUG | ERROR | Unable to send log | fm-logs is not started!')
            return
        end
        exports['fm-logs']:createLog({
            LogType = logType or "Player",
            Message = message or 'Check Resource',
            Level = level or "info",
            Resource = GetCurrentResourceName(),
            Source = source,
        }, { Screenshot = false })
    end
end


--server notification
function SVNotify(src, msg, type, time, title)
    if NotifyType == nil then print('^1| Lusty94_JobCenter | DEBUG | ERROR | NotifyType is nil!') return end
    if not msg then msg = 'Notification sent with no message!' end
    if not type then type = 'success' end
    if not time then time = 5000 end
    if not title then title = 'Notification' end
    if NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, msg, type, time)
    elseif NotifyType == 'qs' then
        TriggerClientEvent('lusty94_jobcenter:client:notify', src, msg, type, time)
    elseif NotifyType == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, title, msg, time, type, Config.CoreSettings.Notify.Sound)
    elseif NotifyType == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = type, text = msg, style = { ['background-color'] = '#00FF00', ['color'] = '#FFFFFF' } })
    elseif NotifyType == 'ox' then 
        TriggerClientEvent('ox_lib:notify', src, ({ title = title, description = msg, position = 'top', duration = time, type = type, style = 'default'}))
    elseif NotifyType == 'lation' then
        TriggerClientEvent('lusty94_jobcenter:client:notify', src, msg, type, time)
    elseif NotifyType == 'wasabi' then
        TriggerClientEvent('lusty94_jobcenter:client:notify', src, msg, type, time)
    elseif NotifyType == 'custom' then
        -- Insert your own notify function here
    else
        print('^1| Lusty94_JobCenter | DEBUG | ERROR | Unknown notify type: ' .. tostring(NotifyType))
    end
end


--add item
function addItem(src, item, amount, info)
    sendLog(src, "Security", ('Giving %sx%s to %s with info %s'):format(item, amount, getCharacterName(src), json.encode(info) or 'N/A'), "warning")
    SVDebug('^3| Lusty94_JobCenter | DEBUG | INFO | Adding '..amount..'x '..item..' to '..getCharacterName(src))
    if InvType == 'qb' then
        local canCarry = exports['qb-inventory']:CanAddItem(src, item, amount, false, info)
        if not canCarry then 
            SVNotify(src, Config.Language.Notifications.CantGive, 'error') 
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src) 
            return
        end
        exports['qb-inventory']:AddItem(src, item, amount, false, info)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif InvType == 'qs' then
        local canCarry = exports['qs-inventory']:CanAddItem(src, item, amount, false, info)
        if not canCarry then 
            SVNotify(src, Config.Language.Notifications.CantGive, 'error') 
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src) 
            return
        end
        exports['qs-inventory']:AddItem(src, item, amount, false, info)
        TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
    elseif InvType == 'ox' then
        local canCarry = exports.ox_inventory:CanCarryItem(src, item, amount, info)
        if not canCarry then
            SVNotify(src, Config.Language.Notifications.CantGive, 'error')
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
            return
        end
        exports.ox_inventory:AddItem(src, item, amount, info)
    elseif InvType == 'custom' then
        local canCarry = 'can carry method here'
        if not canCarry then
            SVNotify(src, Config.Language.Notifications.CantGive, 'error')
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
            return
        end
        --add items logic here
    else
        print('^1| Lusty94_JobCenter | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
    end
end


--remove item
function removeItem(src, item, amount)
    sendLog(src, "Security", ('Removing %sx%s from %s'):format(item, amount, getCharacterName(src)), "warning")
    SVDebug('^3| Lusty94_JobCenter | DEBUG | INFO | Removing '..amount..'x '..item..' from '..getCharacterName(src))
    if InvType == 'qb' then
        if exports['qb-inventory']:RemoveItem(src, item, amount) then
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
            return true
        else
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
            return false
        end
    elseif InvType == 'qs' then
        if exports['qs-inventory']:RemoveItem(src, item, amount) then
            TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
            return true
        else
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
            return false
        end
    elseif InvType == 'ox' then
        if exports.ox_inventory:RemoveItem(src, item, amount) then
            return true
        else
            TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
            return false
        end
    elseif InvType == 'custom' then
        --insert your own logic for removing items here remebering to return the correct boolean
    else
        print('^1| Lusty94_JobCenter | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
    end
end


--remove money
function removeMoney(src, account, amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return true end
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not account then return false end
    sendLog(src, "Security", ('Removing %s%s from %s in %s'):format(CashSymbol, amount, getCharacterName(src), account), "warning")
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Removing %s%.2f from %s^7'):format(CashSymbol, amount, getCharacterName(src)))
    if account == 'cash' or account == 'bank' then
        if InvType == 'ox' then
            if exports.ox_inventory:Search(src, 'count', 'money') >= amount then
                removeItem(src, 'money', amount)
                return true
            else
                TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
                SVDebug('^1| Lusty94_JobCenter | DEBUG | INFO | Player: '..getCharacterName(src)..' has insufficient funds')
                return false
            end
        elseif InvType == 'qb' or InvType == 'qs' then
            if Player.Functions.GetMoney(account) >= amount then
                if Player.Functions.RemoveMoney(account, amount) then
                    return true
                end
            else
                TriggerClientEvent('lusty94_jobcenter:client:toggleStatus', src)
                SVDebug('^1| Lusty94_JobCenter | DEBUG | INFO | Player: '..getCharacterName(src)..' has insufficient funds')
                return false
            end
        end
    end
    return false
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


--distance check coords
function IsPlayerNearCoords(src, targetCoords, playerCoords, maxDist, checkName)
    local dist = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(targetCoords.x, targetCoords.y, targetCoords.z))
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | Distance Check | %s to store: %.2f'):format(getCharacterName(src), dist))
    if dist > maxDist then
        print(('^1| Lusty94_JobCenter | DEBUG | WARNING | %s failed distance check (%s) | Distance: %.2f^7'):format(getCharacterName(src), checkName, dist))
        sendLog(src, "Security", ('%s failed distance check (%s) | Distance: %.2f'):format(getCharacterName(src), checkName, dist), "warning")
        if Config.CoreSettings.Security.KickPlayer then DropPlayer(src, 'Potential Exploiting Detected') end
        return false
    end
    return true
end


--check cooldown
function checkCooldown(src)
    local last = playerCooldowns[src]
    if not last then return 0 end
    local cooldown = (Config.CoreSettings.Misc.JobCooldownMinutes or 0) * 60
    if cooldown <= 0 then return 0 end
    local remaining = cooldown - (os.time() - last)
    return (remaining > 0) and math.ceil(remaining / 60) or 0
end


--set cooldown
function setCooldown(src)
    playerCooldowns[src] = os.time()
end


--get current licenses
lib.callback.register('lusty94_jobcenter:server:getLicences', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return {} end
    local data = Player.PlayerData.metadata or {}
    local info  = {}
    if data.licences then
        for k, v in pairs(data.licences) do info[k] = v end
    end
    if data.licenses then
        for k, v in pairs(data.licenses) do
            if info[k] == nil then info[k] = v end
        end
    end
    return info
end)


--check cooldown
lib.callback.register('lusty94_jobcenter:server:checkCooldown', function(src)
    return checkCooldown(src)
end)


--set job
lib.callback.register('lusty94_jobcenter:server:setJob', function(src, job, location)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not job or not location then return false end
    local coolDown = checkCooldown(src)
    if coolDown > 0 then SVNotify(src, (Config.Language.Notifications.Cooldown):format(coolDown), 'error') return false end
    local locationData = Config.Locations[location]
    if not locationData or not locationData.zone or not locationData.zone.coords then return false end
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if not IsPlayerNearCoords(src, locationData.zone.coords, playerCoords, Config.CoreSettings.Security.MaxDistance or 10.0, 'lusty94_jobcenter:server:setJob') then return false end
    Player.Functions.SetJob(job, 0)
    local JobInfo = QBCore.Shared.Jobs[job].label
    local name = getCharacterName(src)
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | %s switched to job: %s'):format(name, JobInfo))
    sendLog(src, 'Security', ('%s switched to job: %s'):format(name, JobInfo), 'info')
    setCooldown(src)
    return true
end)


--give license
lib.callback.register('lusty94_jobcenter:server:giveLicense', function(src, license, cost, location, paymentType, itemName)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not license or not cost or not location then return false end
    local locationData = Config.Locations[location]
    if not locationData or not locationData.zone or not locationData.zone.coords then return false end
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if not IsPlayerNearCoords(src, locationData.zone.coords, playerCoords, Config.CoreSettings.Security.MaxDistance or 10.0, 'lusty94_jobcenter:server:giveLicense') then return false end
    local meta = Player.PlayerData.metadata or {}
    meta.licences = meta.licences or {}
    if not removeMoney(src, paymentType, cost) then  SVNotify(src, (Config.Language.Notifications.CantAfford):format(CashSymbol, cost), 'error') return  false end
    meta.licences[license] = true
    Player.Functions.SetMetaData('licences', meta.licences)
    local info = {}
    if itemName == 'driving_license' or itemName == 'weapon_license' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.nationality = Player.PlayerData.charinfo.nationality
        info.citizenid = Player.PlayerData.citizenid
    elseif itemName == 'business_license' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname  = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.citizenid = Player.PlayerData.citizenid
        info.business = Player.PlayerData.job.name
        info.position = Player.PlayerData.job.grade.name
        info.phone = Player.PlayerData.charinfo.phone
    elseif itemName == 'my_custom_license' then
        --insert your own data here you want added
    end
    addItem(src, itemName, 1, info)
    SVNotify(src, (Config.Language.Notifications.ItemReceived):format(ItemLabel(itemName)), 'success')
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | %s purchased license: %s payment method: %s cost: %s location: %s'):format(getCharacterName(src), license, paymentType, cost, location))
    sendLog(src, 'Security', ('%s purchased license: %s payment method: %s cost: %s location: %s'):format(getCharacterName(src), license, paymentType, cost, location), 'info')
    return true
end)


--give document
lib.callback.register('lusty94_jobcenter:server:giveDocument', function(src, document, cost, location, paymentType, itemName)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or not document or not cost or not location then return false end
    local locationData = Config.Locations[location]
    if not locationData or not locationData.zone or not locationData.zone.coords then return false end
    local job = (Player.PlayerData.job and Player.PlayerData.job.name) or 'unemployed'
    if locationData.identity.requiredJob and job ~= locationData.identity.requiredJob then return false end
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    if not IsPlayerNearCoords(src, locationData.zone.coords, playerCoords, Config.CoreSettings.Security.MaxDistance or 10.0, 'lusty94_jobcenter:server:giveDocument') then return false end
    if not removeMoney(src, paymentType, cost) then  SVNotify(src, (Config.Language.Notifications.CantAfford):format(CashSymbol, cost), 'error') return  false end
    local info = {}
    if itemName == 'passport' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.nationality = Player.PlayerData.charinfo.nationality
        info.citizenid = Player.PlayerData.citizenid
    elseif itemName == 'lawyer_pass' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname  = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.citizenid = Player.PlayerData.citizenid
        info.business = Player.PlayerData.job.name
        info.position = Player.PlayerData.job.grade.name
        info.phone = Player.PlayerData.charinfo.phone
    elseif itemName == 'police_badge' or itemName == 'medic_badge' then
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname  = Player.PlayerData.charinfo.lastname
        info.business = Player.PlayerData.job.name
        info.position = Player.PlayerData.job.grade.name
    elseif itemName == 'my_custom_identity' then
        --insert your own data here you want added to custom items
    end
    addItem(src, itemName, 1, info)
    SVNotify(src, (Config.Language.Notifications.ItemReceived):format(ItemLabel(itemName)), 'success')
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | %s purchased identity document: %s payment method: %s cost: %s location: %s'):format(getCharacterName(src), document, paymentType, cost, location))
    sendLog(src, 'Security', ('%s purchased identity document: %s payment method: %s cost: %s location: %s'):format(getCharacterName(src), document, paymentType, cost, location), 'info')
    return true
end)


--license item names
local useableItems = {
    'driving_license',
    'weapon_license',
    'business_license',
    'passport',
    'lawyer_pass',
    'police_badge',
    'medic_badge',
    --if adding custom items make sure to list them as useable here
}


--useable items
for _, itemName in ipairs(useableItems) do
    QBCore.Functions.CreateUseableItem(itemName, function(src, item)
        TriggerEvent('lusty94_jobcenter:server:useItem', src, item)
    end)
end


--use item
RegisterNetEvent('lusty94_jobcenter:server:useItem', function(src, item)
    if not item or not item.name then return end
    local info = item.info or item.metadata or {}
    local title, data
    if item.name == 'driving_license' then
        title = 'Driver License'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Birth Date: %s'):format(info.birthdate or 'Unknown'),
            ('Nationality: %s'):format(info.nationality or 'Unknown'),
            ('CitizenID: %s'):format(info.citizenid or 'Unknown'),
        }
    elseif item.name == 'weapon_license' then
        title = 'Weapon License'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Birth Date: %s'):format(info.birthdate or 'Unknown'),
            ('Nationality: %s'):format(info.nationality or 'Unknown'),
            ('CitizenID: %s'):format(info.citizenid or 'Unknown'),
        }
    elseif item.name == 'passport' then
        title = 'Passport'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Birth Date: %s'):format(info.birthdate or 'Unknown'),
            ('Nationality: %s'):format(info.nationality or 'Unknown'),
            ('CitizenID: %s'):format(info.citizenid or 'Unknown'),
        }
    elseif item.name == 'business_license' then
        title = 'Business License'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Birth Date: %s'):format(info.birthdate or 'Unknown'),
            ('Phone Number: %s'):format(info.phone or 'Unknown'),
            ('CitizenID: %s'):format(info.citizenid or 'Unknown'),
            ('Business: %s'):format(info.business or 'Unemployed'),
            ('Position: %s'):format(info.position or 'Unknown'),
        }
    elseif item.name == 'lawyer_pass' then
        title = 'Lawyer Pass'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Birth Date: %s'):format(info.birthdate or 'Unknown'),
            ('Phone Number: %s'):format(info.phone or 'Unknown'),
            ('CitizenID: %s'):format(info.citizenid or 'Unknown'),
            ('Business: %s'):format(info.business or 'Unemployed'),
            ('Position: %s'):format(info.position or 'Unknown'),
        }
    elseif item.name == 'police_badge' then
        title = 'Police Badge'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Business: %s'):format(info.business or 'Unemployed'),
            ('Position: %s'):format(info.position or 'Unknown'),
        }
    elseif item.name == 'medic_badge' then
        title = 'Medical Badge'
        data = {
            ('First Name: %s'):format(info.firstname or 'Unknown'),
            ('Last Name: %s'):format(info.lastname or 'Unknown'),
            ('Business: %s'):format(info.business or 'Unemployed'),
            ('Position: %s'):format(info.position or 'Unknown'),
        }
    elseif item.name == 'my_custom_license' then
        --insert your own data here you want displayed for custom items
    else 
        return 
    end
    local message = ('%s\n\n%s'):format(title, table.concat(data, '\n\n'))
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    TriggerClientEvent('lusty94_jobcenter:client:ShowDocument', src)
    for _, id in pairs(QBCore.Functions.GetPlayers()) do
        local ped = GetPlayerPed(id)
        if #(coords - GetEntityCoords(ped)) <= 3.0 then
            SVNotify(id, message, 'success', 5000)
        end
    end
end)


-- /givelicense [id] [license]
lib.addCommand('givelicense', {
    help = 'Grant a license to a player',
    params = {
        { name = 'id',      type = 'number', help = 'Player ID' },
        { name = 'license', type = 'string', help = 'License name (driver, weapon or business)' },
    }
}, function(source, args)
    local src = source
    local issuer = QBCore.Functions.GetPlayer(src)
    if not issuer then return end
    local canIssue = (Config.CoreSettings and Config.CoreSettings.Misc and Config.CoreSettings.Misc.Licenses and Config.CoreSettings.Misc.Licenses.CanIssue) or {}
    local job = issuer.PlayerData.job
    local required = job and canIssue[job.name]
    if not required or (job.grade and (job.grade.level or 0) < required) then SVNotify(src, Config.Language.Notifications.NoAccess, 'error') return end
    local targetId = tonumber(args.id)
    local targetName = getCharacterName(targetId)
    local license  = tostring(args.license or ''):lower()
    if not targetId or license == '' then return end
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then SVNotify(src, Config.Language.Notifications.TargetNotAvailable, 'error') return end
    local meta = Target.PlayerData.metadata or {}
    meta.licences = meta.licences or {}
    if meta.licences[license] == nil then SVDebug('^1| Lusty94_JobCenter | DEBUG | ERROR | Invalid License Type | Ensure this license exists in qb-core/config') return end
    if meta.licences[license] == true then SVNotify(src, (Config.Language.Notifications.AlreadyHasLicense):format(targetName), 'error') return end
    meta.licences[license] = true
    Target.Functions.SetMetaData('licences', meta.licences)
    SVNotify(Target.PlayerData.source, (Config.Language.Notifications.LicenseGrantedPlayer):format(license), 'success')
    SVNotify(src, (Config.Language.Notifications.LicenseGrantedIssuer):format(license, targetName), 'success')
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | %s granted license: %s to %s'):format(getCharacterName(src), license, targetName))
    sendLog(src, 'Security', ('%s granted license: %s to %s'):format(getCharacterName(src), license, targetName), 'info')
end)


-- /removelicense [id] [license]
lib.addCommand('removelicense', {
    help = 'Revoke a license from a player',
    params = {
        { name = 'id',      type = 'number', help = 'Player ID' },
        { name = 'license', type = 'string', help = 'License name (driver, weapon or business)' },
    }
}, function(source, args)
    local src = source
    local issuer = QBCore.Functions.GetPlayer(src)
    if not issuer then return end
    local canIssue = (Config.CoreSettings and Config.CoreSettings.Misc and Config.CoreSettings.Misc.Licenses and Config.CoreSettings.Misc.Licenses.CanIssue) or {}
    local job = issuer.PlayerData.job
    local required = job and canIssue[job.name]
    if not required or (job.grade and (job.grade.level or 0) < required) then SVNotify(src, Config.Language.Notifications.NoAccess, 'error') return end
    local targetId = tonumber(args.id)
    local targetName = getCharacterName(targetId)
    local license  = tostring(args.license or ''):lower()
    if not targetId or license == '' then return end
    local Target = QBCore.Functions.GetPlayer(targetId)
    if not Target then SVNotify(src, Config.Language.Notifications.TargetNotAvailable, 'error') return end
    local meta = Target.PlayerData.metadata or {}
    meta.licences = meta.licences or {}
    if meta.licences[license] == nil then SVDebug('^1| Lusty94_JobCenter | DEBUG | ERROR | Invalid License Type | Ensure this license exists in qb-core/config', 'error') return end
    if not meta.licences[license] then SVNotify(src, (Config.Language.Notifications.DoesntHaveLicense):format(targetName), 'error') return end
    meta.licences[license] = false
    Target.Functions.SetMetaData('licences', meta.licences)
    SVNotify(Target.PlayerData.source, (Config.Language.Notifications.LicenseRemovedPlayer):format(license), 'error')
    SVNotify(src, (Config.Language.Notifications.LicenseRemovedIssuer):format(license, targetName), 'success')
    SVDebug(('^3| Lusty94_JobCenter | DEBUG | INFO | %s removed license: %s from %s'):format(getCharacterName(src), license, targetName))
    sendLog(src, 'Security', ('%s removed license: %s from %s'):format(getCharacterName(src), license, targetName), 'info')
end)




--dont touch
AddEventHandler('playerDropped', function()
    local src = source
    playerCooldowns[src] = nil
end)


--dont touch
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        local src = source
        playerCooldowns = {}
    end
end)


--version check
local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Lusty94/UpdatedVersions/main/JobCenter/version.txt', function(err, newestVersion, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        if not newestVersion then print('^1[Lusty94_JobCenter]^7: Unable to fetch the latest version.') return end
        newestVersion = newestVersion:gsub('%s+', '')
        currentVersion = currentVersion and currentVersion:gsub('%s+', '') or "Unknown"
        if newestVersion == currentVersion then
            print(string.format('^2[Lusty94_JobCenter]^7: ^6You are running the latest version.^7 (^2v%s^7)', currentVersion))
        else
            print(string.format('^2[Lusty94_JobCenter]^7: ^3Your version: ^1v%s^7 | ^2Latest version: ^2v%s^7\n^1Please update to the latest version | Changelogs can be found in the support discord.^7', currentVersion, newestVersion))
        end
    end)
end
CheckVersion()