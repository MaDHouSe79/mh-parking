local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Error al conseguir la id del ciudadano!",
        ["mis_id"]              = "[Error] Se requiere una identificación de jugador.",
        ["mis_amount"]          = "[Error] No hay una cantidad de vehículos que este jugador pueda estacionar con anticipación.",
        ["not_enough_money"]    = "Je hebt niet genoeg geld om de rekening te betalen!",
    },
    commands = {
        ["addvip"]              = "Agregar",
        ["removevip"]           = "Remover",
    },
    system = {
        ['update']              = "There is a update for qb-parking", 
        ["enable"]              = "Sistema de parking %{type} ahora esta habilitado",
        ["disable"]             = "Sistema de parking %{type} se ha deshabilitado",
        ["freeforall"]          = "Sistema de parking: ahora está habilitado para todos los jugadores..",
        ["parkvip"]             = "Sistema de parking: ahora solo está habilitado para VIP.",
        ["no_permission"]       = "Sistema de parking: No tiene permiso para estacionar..",
        ["offline"]             = "El sistema de parking está desconectado",
        ["update_needed"]       = "El sistema de parking está desactualizado....",
        ["already_vip"]         = "El jugador ya es vip!",
        ["vip_not_found"]       = "Jugador no encontrado!",
        ["vip_add"]             = "El jugador %{username} es agregado como vip!",
        ["vip_remove"]          = "El jugador %{username} es removido del vip!",
        ["max_allow_reached"]   = "El número máximo de vehículos permitidos para usted es %{max}",
        ["park_or_drive"]       = "Estacionar o conducir",
        ["already_reserved"]    = "This parking place has already been reserved.",
        ["parked_blip_info"]    = "Estacionado: %{modelname}",
        ["to_far_from_vehicle"] = "Estás demasiado lejos del vehículo.",
        ["open_create_menu"]    = "Abrir menú de creación de parque (solo administrador)",
        ["must_be_onduty"]      = "Debes ser indeber para usar esto.",
        ["not_the_right_job"]   = "No tienes el trabajo adecuado para hacer esto.",
    },
    success = {
        ["parked"]              = "Tu vehiculo esta estacionado",
        ["route_has_been_set"]  = "Hay un punto de referencia en la carpeta donde su vehículo está estacionado..",
        ["paid_park_space"]     = "Ha pagado %{pagado}.",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Dueño: ~y~%{owner}~s~",
        ["plate"]               = "Patente: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Presione F5 para comenzar a conducir",
        ["car_already_parked"]  = "Un vehículo con la misma placa ya ha estacionado.",
        ["car_not_found"]       = "Ningún vehículo encontrado",
        ["maximum_cars"]        = "Puede haber un máximo de %{amount} Los autos se pueden aparcar afuera en la calle, y se ha alcanzado el límite!",
        ["must_own_car"]        = "Debes poseer el coche para aparcarlo..",
        ["has_take_the_car"]    = "Su vehículo ha sido eliminado de la zona de estacionamiento.",
        ["only_cars_allowd"]    = "Solo puedes estacionar autos aquí",
        ["stop_car"]            = "Detenga su vehículo antes de estacionar",
        ["police_info"]         = "~r~Policia~s~ Información del vehículo\n",
        ["citizen_info"]        = "~g~Ciudadano~s~ Información del vehículo\n",
        ["paid_park_space"]     = "Usted alquila este espacio de estacionamiento por $%{paid} p/h",
        ["drive"]               = "Drive Vecihle",
        ["park"]                = "Park Vehicle",
        ["limit_for_player"]    = "Puede estacionar un máximo de %{amount} vehículo(s) en la calle!",
        ["not_allowed_to_park"] = "No se puede aparcar un vehículo aquí!",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Estacionado %{model}",
        ["message"]             = "Hola, %{username}<br /><br />Gracias por confiar en nuestro estacionamiento.!<br /><br />Para asegurarse de que no olvides dónde estacionaste tu auto..<br />¿También recibirá un correo electrónico de un recordatorio con la matrícula y la ubicación donde estacionó su automóvil aproximadamente?<br /><br />Dueño: %{username}<br />Modelo: %{model}<br />Patente: %{plate}<br />Ubicacion:%{street}<br /><br/><br/>%{company}",
    },

    discoord = {
        ["version"]   = "[qb-parking] - Running Version %{version}",
        ["found"]     = "[qb-parking] - Found %{count}/%{total} vehicles that are parked.",
        ["spawntime"] = "[qb-parking] - Spawn time %{spawntime} milliseconds.",
        ["timeloop"]  = "[qb-parking] - Parking Time Check Loop has started.",
    }
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
