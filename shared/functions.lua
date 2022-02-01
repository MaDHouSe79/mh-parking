-- Check if a player is allowd to park.
function IsAllowToPark(citizenid)
    if UseParkingSystem then
        if OnlyAllowVipPlayers then
            for k, v in pairs(Config.VipPlayers) do
                if v.citizenid == citizenid then
                    return true
                end
            end
        else
            return true
        end
    end
    return false
end

-- Check if a citizenid is an admin.
function IsAdmin(citizenid)
    for k, v in pairs(Config.VipPlayers) do
        if v.citizenid == citizenid and v.isAdmin then
            return true
        end
    end
    return false
end

