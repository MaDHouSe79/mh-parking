-- ═══════════════════════════════════════════════════════════ --
--          MH-PARKING – 100% Statebag by MaDHouSe79           --
-- ═══════════════════════════════════════════════════════════ --
Database = {}

sql = {table = "player_vehicles", citizenid = "citizenid", state = "state"}
ply = {table = "players", citizenid = "citizenid"}

if GetResourceState('es_extended') == 'started' then
    sql = {table = "owned_vehicles", citizenid = "owner", state = "stored"}
    ply = {table = "users", citizenid = "identifier"}
elseif GetResourceState('qb-core') == 'started' then
    sql = {table = "player_vehicles", citizenid = "citizenid", state = "state"}
    ply = {table = "players", citizenid = "citizenid"}
end

MySQL.ready(function()
    MySQL.Async.execute('ALTER TABLE '..ply.table..' ADD COLUMN IF NOT EXISTS parkvip INT NULL DEFAULT 0')
    MySQL.Async.execute('ALTER TABLE '..ply.table..' ADD COLUMN IF NOT EXISTS parkmax INT NULL DEFAULT 0')
    MySQL.Async.execute('ALTER TABLE '..sql.table..' ADD COLUMN IF NOT EXISTS steerangle INT NULL DEFAULT 0')
    MySQL.Async.execute('ALTER TABLE '..sql.table..' ADD COLUMN IF NOT EXISTS street TEXT NULL DEFAULT NULL')
    MySQL.Async.execute('ALTER TABLE '..sql.table..' ADD COLUMN IF NOT EXISTS location TEXT NULL DEFAULT NULL')
    MySQL.Async.execute('ALTER TABLE '..sql.table..' ADD COLUMN IF NOT EXISTS parktime INT NULL DEFAULT 0')
    MySQL.Async.execute('ALTER TABLE '..sql.table..' ADD COLUMN IF NOT EXISTS time BIGINT NOT NULL DEFAULT 0')
    MySQL.Async.execute('ALTER TABLE '..sql.table..' ADD COLUMN IF NOT EXISTS isClamped INT NULL DEFAULT 0')
end)

function Database.ImpoundVehicle(plate, cost)
    MySQL.Async.execute('UPDATE '..sql.table..' SET '..sql.state..' = ?, depotprice = ?, location = ?, street = ?, parktime = ?, time = ?, isClamped = ? WHERE plate = ?', {
        0, cost, nil, nil, 0, 0, 0, plate
    })
end

function Database.ParkVehicle(plate, location, steerangle, street, mods, fuel, body, engine)
    local parktime = SV_Config.MaxTimeParking
    MySQL.Async.execute('UPDATE '..sql.table..' SET '..sql.state..' = ?, location = ?, street = ?, steerangle = ?, mods = ?, fuel = ?, body = ?, engine = ?, time = ?, parktime = ? WHERE plate = ?', {
        3, json.encode(location), street, steerangle, json.encode(mods), fuel, body, engine, os.time(), parktime, plate
    })
end

function Database.UnparkVehicle(plate)
    MySQL.Async.execute('UPDATE '..sql.table..' SET '..sql.state..' = ?, location = ?, street = ? WHERE plate = ?', {0, nil, nil, plate})
end

function Database.GetVehicleData(plate)
    return MySQL.single.await("SELECT * FROM "..sql.table.." WHERE plate = ? LIMIT 1", {plate})
end

function Database.GetVehicles()
    return MySQL.query.await("SELECT * FROM "..sql.table.." WHERE "..sql.state.." = ?", {3})
end

function Database.IsOwned(plate)
    local result = MySQL.single.await("SELECT * FROM "..sql.table.." WHERE plate = ? LIMIT 1", {plate})
    if result ~= nil then return result.citizenid or result.owner end
    return false
end

function Database.GetVehiclesForCitizenid(citizenid)
    return citizenid ~= false and MySQL.query.await("SELECT * FROM "..sql.table.." WHERE "..sql.state.." = ? AND "..sql.citizenid.." = ? ", {3, citizenid})
end

function Database.GetPlayerData(citizenid)
    return citizenid ~= false and MySQL.query.await("SELECT * FROM "..ply.table.." WHERE "..sql.citizenid.." = ?", {citizenid})[1]
end

function Database.UpdateWheelClamp(plate, state)
    return MySQL.Async.execute("UPDATE "..sql.table.." SET isClamped = ? WHERE plate = ?", {state, plate})
end

function Database.IsVehicleOwned(src, plate)
    local citizenid = GetIdentifier(src)
    return citizenid ~= false and MySQL.single.await("SELECT * FROM "..sql.table.." WHERE plate = ? AND "..sql.citizenid.." = ? LIMIT 1", {plate, citizenid})
end

function Database.GetPlayerVehicles(src)
    local citizenid = GetIdentifier(src)
    return citizenid ~= false and MySQL.Sync.fetchAll("SELECT * FROM "..sql.table.." WHERE "..sql.citizenid.." = ? AND "..sql.state.." = ?", {citizenid, 3})
end

function Database.GetMaxParking(src)
    local citizenid = GetIdentifier(src)
    local result = MySQL.single.await("SELECT * FROM "..sql.table.." WHERE "..sql.citizenid.." = ? LIMIT 1", {citizenid})
    if citizenid ~= false and result ~= nil and result.parkvip == 1 then return tonumber(result.parkmax) or SV_Config.DefaultMaxParking end
    return SV_Config.DefaultMaxParking
end

function Database.AddVip(src, amount)
    local citizenid = GetIdentifier(src)
    return citizenid ~= false and MySQL.Async.execute("UPDATE "..ply.table.." SET parkvip = ?, parkmax = ? WHERE "..ply.citizenid.." = ?", {1, amount, citizenid})
end

function Database.RemovedVip(src)
    local citizenid = GetIdentifier(src)
    return citizenid ~= false and MySQL.Async.execute("UPDATE "..ply.table.." SET parkvip = ?, parkmax = ? WHERE "..ply.citizenid.." = ?", {0, 0, citizenid})
end

function Database.IsPlayerAVip(src)
    local citizenid = GetIdentifier(src)
    if SV_Config.UseAsVip then
        local result = MySQL.single.await("SELECT * FROM "..ply.table.." WHERE "..ply.citizenid.." = ? LIMIT 1", {citizenid})
        if citizenid ~= false and result ~= nil and result.parkvip == 1 then return true end
        return false
    else
        return true
    end
end