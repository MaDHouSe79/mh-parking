-- Check if a player is allowd to park.
function IsAllowToPark(citizenid)
    local state = false
    if UseParkingSystem then
        if OnlyAllowVipPlayers then
            for k, v in pairs(Config.VipPlayers) do
                if v.citizenid == citizenid then
                    state = true
                end
            end
        else
            state =  true
        end
    else
        state =  false
    end
    return state
end

function IsAdmin(citizenid)
    for k, v in pairs(Config.VipPlayers) do
        if v.citizenid == citizenid and v.isAdmin then
            return true
        end
    end
	return false
end