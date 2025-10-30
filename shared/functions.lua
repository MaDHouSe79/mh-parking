-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
function Trim(value)
    if not value then
        return nil
    end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function GetPlate(vehicle)
    if vehicle == nil then
        return nil
    end
    if not DoesEntityExist(vehicle) then
        return nil
    end
    return Trim(GetVehicleNumberPlateText(vehicle))
end

function GetDistance(pos1, pos2)
    if pos1 ~= nil and pos2 ~= nil then
        return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
    end
end

function FirstToUpper(str)
    if str ~= nil then
        return (str:gsub("^%l", string.upper))
    else
        return
    end
end
