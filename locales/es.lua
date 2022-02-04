local Translations = {
    error = {
        ["citizenid_error"]     = "[ERROR] Error al conseguir la id del ciudadano!",
    },
    system = {
        ["enable"]              = "Sistema de parking %{type} ahora esta habilitado",
        ["disable"]             = "Sistema de parking %{type} se ha deshabilitado",
        ["freeforall"]          = "Sistema de parking: ahora está habilitado para todos los jugadores..",
        ["parkvip"]             = "Sistema de parking: ahora solo está habilitado para VIP.",
        ["no_permission"]       = "Sistema de parking: No tiene permiso para estacionar..",
        ["offline"]             = "El sistema de parking está desconectado",
        ["update_needed"]       = "El sistema de parking está desactualizado....",
        ["already_vip"]         = "El jugador ya es vip!",
        ["vip_not_found"]       = "Jugador no encontrado!",
        ["vip_add"]             = "El jugador %{username} se agrego como vip!",
        ["vip_remove"]          = "El jugador %{username} se es removido del vip!",
    },
    success = {
        ["parked"]              = "Tu vehiculo esta estacionado",
        ["route_has_been_set"]  = "Hay un punto de referencia en la carpeta donde su vehículo está estacionado..",
    },
    info = {
        ["companyName"]         = "Beunhaas BV",
        ["owner"]               = "Dueño: ~y~%{owner}~s~",
        ["plate"]               = "Patente: ~g~%{plate}~s~",
        ["model"]               = "~b~%{model}~s~",
        ["press_drive_car"]     = "Presione F5 para comenzar a conducir",
        ["car_already_parked"]  = "Un vehículo con la misma placa ya ha estacionado.",
        ["car_not_found"]       = "Ningún vehículo encontrado",
        ["maximum_cars"]        = "Puede haber un máximo de ~r~%{value}~s~ Los autos se pueden aparcar afuera en la calle, y se ha alcanzado el límite, ¡debe estacionar este vehículo en el estacionamiento!",
        ["must_own_car"]        = "Debes poseer el coche para aparcarlo..",
        ["has_take_the_car"]    = "Su vehículo ha sido eliminado de la zona de estacionamiento.",
        ["only_cars_allowd"]    = "Solo puedes estacionar autos aquí",
        ["stop_car"]            = "Detenga su vehículo antes de estacionar",
    },
    mail = {
        ["sender"]              = "%{company}",
        ["subject"]             = "Estacionado %{model}",
        ["message"]             = "Hola, %{username}<br /><br />Gracias por confiar en nuestro estacionamiento.!<br /><br />Para asegurarse de que no olvides dónde estacionaste tu auto..<br />¿También recibirá un correo electrónico de un recordatorio con la matrícula y la ubicación donde estacionó su automóvil aproximadamente?<br /><br />Dueño: %{username}<br />Modelo: %{model}<br />Patente: %{plate}<br />Ubicacion:%{street}<br /><br/><br/>%{company}",
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
