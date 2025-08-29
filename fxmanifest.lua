fx_version 'cerulean'

game 'gta5'

author 'Lusty94'

name 'lusty94_outfits'

description 'Job Center Script For QB-Core'

version '1.0.0'

lua54 'yes'

client_script {
    'client/funcs.lua',
}


server_scripts { 
    'server/funcs.lua',
    '@oxmysql/lib/MySQL.lua',
}


shared_scripts { 
    'shared/config.lua',
    '@ox_lib/init.lua'
}


escrow_ignore {
    'shared/**.lua',
    'client/**.lua',
    'server/**.lua',
}