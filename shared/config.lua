Config = {}

--
--██╗░░░░░██╗░░░██╗░██████╗████████╗██╗░░░██╗░█████╗░░░██╗██╗
--██║░░░░░██║░░░██║██╔════╝╚══██╔══╝╚██╗░██╔╝██╔══██╗░██╔╝██║
--██║░░░░░██║░░░██║╚█████╗░░░░██║░░░░╚████╔╝░╚██████║██╔╝░██║
--██║░░░░░██║░░░██║░╚═══██╗░░░██║░░░░░╚██╔╝░░░╚═══██║███████║
--███████╗╚██████╔╝██████╔╝░░░██║░░░░░░██║░░░░█████╔╝╚════██║
--╚══════╝░╚═════╝░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░░╚════╝░░░░░░╚═╝


-- Thank you for downloading this script!

-- Below you can change multiple options to suit your server needs.
-- If you do not want to use any of the pre-configured locations then remove all the necessary logic for them throughout this config file
-- Extensive documentation detailing this script and how to confiure it correclty can be found here: https://lusty94-scripts.gitbook.io/documentation/free/job-center


Config.CoreSettings = {
    Debug = { -- debug settings
        Prints = true, -- sends debug prints to f8 console and txadmin server console
    },
    Security = { -- security settings
        MaxDistance = 10.0, -- max distance permitted for security checks 10.0 seems reasonable
        KickPlayer = true, -- set to true to kick players for failed security checks
        Logs = {
            Enabled = false, -- enable logs for events with detailed information
            Type = 'fm-logs', -- type of logging, support for fm-logs(preferred) or discord webhook (not recommended)
            --use 'fm-logs' for fm-logs (if using this ensure you have setup the resource correctly and it is started before this script)
            --use 'discord' for discord webhooks (if using this make sure to set your webhook URL in the sendLog function in server/funcs.lua)
        },
    },
    Misc = { -- misc settings
        CashSymbol = '£', -- cash symbol used in your server
        JobCooldownMinutes = 10, -- time in minutes between job switches
        Licenses = { -- grant / revoke license settings
            CanIssue = { -- job names and their ranks
                police = 2, -- job name and rank required to grant or revoke
                gov = 2, -- job name and rank required to grant or revoke
            },
        },
    },
    Notify = { -- notification settings - support for qb-core notify okokNotify, mythic_notify, ox_lib notify, qs-notify, lation_ui, wasabi_notify (experimental not tested)
        --EDIT CLIENT/FUNCS.LUA & SERVER/FUNCS.LUA TO ADD YOUR OWN NOTIFY SUPPORT
        Type = 'ox',
        --use 'qb' for default qb-core notify
        --use 'okok' for okokNotify
        --use 'mythic' for mythic_notify
        --use 'ox' for ox_lib notify
        --use 'lation' for lation_ui
        --use 'wasabi' for wasabi_notify
        --use 'qs' for qs-notify (experimental not tested) (qs-interface)  -- some logic might need adjusting
        --use 'custom' for custom notifications
    },
    Target = { -- target settings - support for qb-target and ox_target  
        Type = 'qb',      
        -- EDIT CLIENT/FUNCS.LUA TO ADD YOUR OWN TARGET SUPPORT
        -- use 'qb' for qb-target
        -- use 'ox' for ox_target
        -- use 'custom' for custom target
    },
    Inventory = { -- inventory settings - support for qb-inventory ox_inventory and qs-inventory (experimental not tested)
        --EDIT CLIENT/FUNCS.LUA & SERVER/FUNCS.LUA TO ADD YOUR OWN INVENTORY SUPPORT
        Type = 'qb',
        --use 'qb' for qb-inventory
        --use 'ox' for ox_inventory version 2.41.0 (they removed support for qb-core after this)
        --use 'qs' for qs-inventory (experimental not tested)
        --use 'custom' for custom inventory
    },
}


Config.Locations = {
    ['City Hall'] = { -- the key is the location name
        zone = { -- zone settings
            debug = false, -- enable zone debug if ped is disabled
            coords = vector4(-542.52, -197.17, 38.24, 88.64), -- must be vector4
            size = vector3(2.0, 2.0, 2.0), -- must be vector3
            name = 'cityhall', -- name must be unique and lowercase with no spaces etc
            radius = 1.0, -- radius of target zone if not using ped
        },
        target = { -- ped settings
            ped = false, -- enalbe ped in this location if set to false just the zone spawns
            model = 'a_m_m_prolhost_01', -- ped model
            scenario = 'WORLD_HUMAN_AA_COFFEE', -- scenario to play if a ped is used
            icon = 'fa-solid fa-clipboard', -- target icon
            label = 'Employment Info', -- target label
            distance = 3.0, -- target distance
        },
        blip = { -- blip settings
            enabled = true, -- set to true to enable blips for this location
            id = 126, -- blip id
            colour = 3, -- blip colour
            scale = 0.6, -- blip scale
            title = 'City Hall Services', -- blip title
        },
        progress = { -- progressCircle settings
            duration = 5000, -- duration of progress circle
            label = 'Filling out required information', -- progress circle label
            anim = { -- animation settings
                anim = 'missheistdockssetup1clipboard@base', -- anim name
                dict = 'base', -- anim dict
                flag = 49, -- anim flag
            },
            prop = { -- prop settings
                model = 'prop_notepad_01', -- prop name
                bone = 18905, -- bone index
                pos = vec3(0.1, 0.02, 0.05), -- prop position must be vec3
                rot = vec3(10.0, 0.0, 0.0), -- prop rotation must be vec3
            },
        },
        jobs = { -- job settings
            ['bus'] = { -- the key is the job name
                info = 'Collect and drop off passengers', -- job description
            },
            ['trucker'] = { -- the key is the job name
                info = 'Complete various deliveries', -- job description
            },
            ['tow'] = { -- the key is the job name
                info = 'Tow stranded vehicles to repair stations', -- job description
            },
            ['garbage'] = { -- the key is the job name
                info = 'Collect and dispose of rubbish', -- job description
            },
            ['vineyard'] = { -- the key is the job name
                info = 'Collect fruits and process into various products', -- job description
            },
            ['hotdog'] = { -- the key is the job name
                info = 'Get your hotdogs, hotdogs here!', -- job description
            },
            ['taxi'] = { -- the key is the job name
                info = 'Collect and drop off passengers', -- job description
            },
            --add more jobs as required for this location making sure the jobs you add are in qb-core/shared/jobs.lua file
        },
        licenses = { -- license settings
            ['driver'] = { -- the key is the license name
                info = 'Allows you to drive vehicles on the public roads', -- license description
                cost = 1000, -- license cost
                item = 'driving_license', -- item name to give
            },
            ['business'] = { -- the key is the license name
                info = 'Allows you to own a public business', -- license description
                cost = 5000, -- license cost
                item = 'business_license', -- item name to give
                rank = 3, -- job rank required to get license
            },
            ['weapon'] = { -- the key is the license name
                info = 'Allows you to legally own a firearm, just don\'t be stupid!', -- license description
                cost = 10000, -- license cost
                item = 'weapon_license', -- item name to give
            },
            --add more licenses as required for this location making sure the licenses you add are in the license metadata table in qb-core/config.lua
        },
        identity = { -- identity settings
            ['passport'] = { -- the key is the document name
                info = 'An important identity document which allows travel to other countries', -- document description
                cost = 500, -- document cost
                item = 'passport', -- item name to give
            },
            ['lawyerpass'] = { -- the key is the document name
                info = 'A legal document showing your lawyer status', -- document description
                cost = 0, -- document cost
                item = 'lawyerpass', -- item name to give
                requiredJob = 'lawyer', -- required job to get this document
                rank = 0, -- job rank required to get document
            },
            ['police_badge'] = { -- the key is the document name
                info = 'An official Police badge', -- document description
                cost = 0, -- document cost
                item = 'police_badge', -- item name to give
                requiredJob = 'police', -- required job to get this document
                rank = 1, -- job rank required to get document
            },
            ['medic_badge'] = { -- the key is the document name
                info = 'An official Medical badge', -- document description
                cost = 0, -- document cost
                item = 'medic_badge', -- item name to give
                requiredJob = 'ambulance', -- required job to get this document
                rank = 1, -- job rank required to get document
            },
            --add more licenses as required for this location making sure the licenses you add are in the license metadata table in qb-core/config.lua
        },
    },
    ['Legion Square'] = { -- the key is the location name
        zone = { -- zone settings
            debug = false, -- enable zone debug if ped is disabled
            coords = vector4(243.46, -1073.5, 29.29, 3.36), -- must be vector4
            size = vector3(2.0, 2.0, 2.0), -- must be vector3
            name = 'legionsquare', -- name must be unique and lowercase with no spaces etc
            radius = 1.0, -- radius of target zone if not using ped
        },
        target = { -- ped settings
            ped = true, -- enalbe ped in this location if set to false just the zone spawns
            model = 'a_m_m_hasjew_01', -- ped model
            scenario = 'WORLD_HUMAN_CLIPBOARD', -- scenario to play if a ped is used
            icon = 'fa-solid fa-clipboard', -- target icon
            label = 'Employment Info', -- target label
            distance = 3.0, -- target distance
        },
        blip = { -- blip settings
            enabled = true, -- set to true to enable blips for this location
            id = 126, -- blip id
            colour = 3, -- blip colour
            scale = 0.6, -- blip scale
            title = 'Legion Employment', -- blip title
        },
        progress = { -- progressCircle settings
            duration = 5000, -- duration of progress circle
            label = 'Filling out required information', -- progress circle label
            anim = { -- animation settings
                anim = 'missheistdockssetup1clipboard@base', -- anim name
                dict = 'base', -- anim dict
                flag = 49, -- anim flag
            },
            prop = { -- prop settings
                model = 'prop_notepad_01', -- prop name
                bone = 18905, -- bone index
                pos = vec3(0.1, 0.02, 0.05), -- prop position must be vec3
                rot = vec3(10.0, 0.0, 0.0), -- prop rotation must be vec3
            },
        },
        jobs = { -- job settings
            ['bus'] = { -- the key is the job name
                info = 'Collect and drop off passengers', -- job description
            },
            ['trucker'] = { -- the key is the job name
                info = 'Complete various deliveries', -- job description
            },
            ['tow'] = { -- the key is the job name
                info = 'Tow stranded vehicles to repair stations', -- job description
            },
            ['garbage'] = { -- the key is the job name
                info = 'Collect and dispose of rubbish', -- job description
            },
            ['vineyard'] = { -- the key is the job name
                info = 'Collect fruits and process into various products', -- job description
            },
            ['hotdog'] = { -- the key is the job name
                info = 'Get your hotdogs, hotdogs here!', -- job description
            },
            ['taxi'] = { -- the key is the job name
                info = 'Collect and drop off passengers', -- job description
            },
            --add more jobs as required for this location making sure the jobs you add are in qb-core/shared/jobs.lua file
        },
        licenses = { -- license settings
            ['driver'] = { -- the key is the license name
                info = 'Allows you to drive vehicles on the public roads', -- license description
                cost = 1000, -- license cost
                item = 'driving_license', -- item name to give
            },
            ['business'] = { -- the key is the license name
                info = 'Allows you to own a public business', -- license description
                cost = 5000, -- license cost
                item = 'business_license', -- item name to give
            },
            ['weapon'] = { -- the key is the license name
                info = 'Allows you to legally own a firearm, just don\'t be stupid!', -- license description
                cost = 10000, -- license cost
                item = 'weapon_license', -- item name to give
            },
            --add more licenses as required for this location making sure the licenses you add are in the license metadata table in qb-core/config.lua
        },
        identity = { -- indentity settings
            ['passport'] = { -- the key is the item name
                info = 'An important identity document which allows travel to other countries', -- license description
                cost = 500, -- license cost
                item = 'passport', -- item name to give
            },
            ['lawyerpass'] = { -- the key is the item name
                info = 'A legal document showing your lawyer status', -- license description
                cost = 0, -- license cost
                item = 'lawyerpass', -- item name to give
                requiredJob = 'lawyer', -- required job to get this document
                rank = 0, -- job rank required to get document
            },
            ['police_badge'] = { -- the key is the item name
                info = 'An official Police badge', -- license description
                cost = 0, -- license cost
                item = 'police_badge', -- item name to give
                requiredJob = 'police', -- required job to get this document
                rank = 1, -- job rank required to get document
            },
            ['medic_badge'] = { -- the key is the item name
                info = 'An official Medical badge', -- license description
                cost = 0, -- license cost
                item = 'medic_badge', -- item name to give
                requiredJob = 'ambulance', -- required job to get this document
                rank = 1, -- job rank required to get document
            },
            --add more identity documents as required for this location dont forget to add the data if using custom items
        },
    },
}


Config.Language = {
    Notifications = {
        Busy = 'You are already doing something',
        Cancelled = 'Action cancelled',
        CantGive = 'Cant give item',
        NoAccess = 'You do not have access to this',
        CantAfford = 'You cant afford that (%s%s required)',
        WrongWrank = 'Requires job grade %d+ or higher',
        AlreadyHaveJob = 'You already have this job',
        NewJob = 'Congratulations on your new job at %s',
        Cooldown = 'You must wait %s minutes before doing that again',
        ItemReceived = 'You received a %s',
        Confirmation = 'You have selected the job: %s\n\nThe starting salary is: %s%s\n\nAre you sure you want to accept this?',
        TargetNotAvailable = 'The target id selected is not available',
        AlreadyHasLicense = '%s already has that license!',
        DoesntHaveLicense = '%s does not have that license!',
        LicenseGrantedPlayer = 'Your %s license has been granted',
        LicenseGrantedIssuer = '%s license issued to %s successfully',
        LicenseRemovedPlayer = 'Your %s license has been removed!',
        LicenseRemovedIssuer = 'Removed %s license from %s',
    }
}