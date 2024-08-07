local bannedList = {}
local bannedListUrl = 'https://raw.githubusercontent.com/E9C50/FivemCnBan/master/ban_data.json'
-- local bannedListUrl = 'https://cnban.gtafivem.cn/bandata.json' -- 防止部分服务器无法访问GitHub，首选GitHub，备用这个地址（数据是同步一致的）

function getIdentifierByType(identifiers, type)
    for _, v in pairs(identifiers) do
        if string.find(v, type) then
            return v
        end
    end
    return ''
end

function checkBanList(identifiers)
    for key, value in pairs(bannedList) do
        if value['license'] == getIdentifierByType(identifiers, 'license') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'license2') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'discord') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'fivem') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'steam') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'live') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'xbl') then return true, value['reason'] end
        if value['license'] == getIdentifierByType(identifiers, 'ip') then return true, value['reason'] end
    end

    return false, ''
end

AddEventHandler('playerConnecting', function(name, reject, deferrals)
    deferrals.defer()
    deferrals.update(string.format('国服联合封禁系统正在检查您是否被封禁...', name))

    local identifiers = GetPlayerIdentifiers(source)
    local isBanned, reason = checkBanList(identifiers)

    if isBanned then
        reject('国服联合封禁：此账户因违反规定已被本服务器或其他服务器联合永久封禁！')
        CancelEvent()
    else
        deferrals.done()
    end
end)

CreateThread(function()
    PerformHttpRequest(bannedListUrl, function(statusCode, response, headers)
        if statusCode == 200 then
            bannedList = json.decode(response)
            print('FIVEM 国服联BAN系统：已加载到' .. tostring(#bannedList) .. '条封禁数据，并将会持续监听最新数据')
        else
            print('FIVEM 国服联BAN系统：获取联BAN数据失败！请确保您的服务器能正常访问GitHub，或者更换数据源！' .. statusCode)
        end
    end, "GET", "", { ["Content-Type"] = "application/json" })

    while true do
        PerformHttpRequest(bannedListUrl, function(statusCode, response, headers)
            if statusCode == 200 then
                bannedList = json.decode(response)
            end
        end, "GET", "", { ["Content-Type"] = "application/json" })

        Wait(1000 * 60 * 10)
    end
end)