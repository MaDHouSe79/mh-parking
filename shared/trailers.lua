-- [[ ===================================================== ]] --
-- [[              MH Park System by MaDHouSe79             ]] --
-- [[ ===================================================== ]] --
Config.Trailers = {
    [712162987] =   {model = "trailersmall", name = "trailersmall", brand = "Trailer",     offset = {backwards = -5.70}},
    [524108981] =   {model = "boattrailer",  name = "boattrailer",  brand = "Boattrailer", offset = {backwards = -7.25}},
    [1835260592] =  {model = "boattrailer2", name = "boattrailer2", brand = "Boattrailer", offset = {backwards = -8.79}},
    [-877478386] =  {model = "trailers",     name = "trailers",     brand = "Trailers",    offset = {backwards = -6.1}},
    [-1579533167] = {model = "trailers2",    name = "trailers2",    brand = "Trailers",    offset = {backwards = -6.1}},
    [-2058878099] = {model = "trailers3",    name = "trailers3",    brand = "Trailers",    offset = {backwards = -6.1}},
    [-100548694] =  {model = "trailers4",    name = "trailers4",    brand = "Trailers",    offset = {backwards = -6.1}},
    [-1352468814] = {model = "trflat",       name = "trflat",       brand = "Trailers",    offset = {backwards = -6.1}},
    [2091594960] =  {model = "tr4",          name = "tr4",          brand = "Trailers",    offset = {backwards = -7.8}},
    [2078290630] =  {
        model = "tr2",          
        name = "tr2",          
        brand = "Trailers",    
        offset = {backwards = -7.8}, 
        parklist = { 
            [1] = { id = 1, coords = vector3(0.0, 4.8, 1.0), loaded = false, entity = nil }, 
            [2] = { id = 2, coords = vector3(0.0, 0.0, 1.1), loaded = false, entity = nil }, 
            [3] = { id = 3, coords = vector3(0.0, -5.1, 1.2), loaded = false, entity = nil },
            [4] = { id = 4, coords = vector3(0.0, 5.1, 3.0), loaded = false, entity = nil }, 
            [5] = { id = 5, coords = vector3(0.0, 0.0, 3.1), loaded = false, entity = nil }, 
            [6] = { id = 6, coords = vector3(0.0, -5.1, 3.2), loaded = false, entity = nil }
        }
    },
}

Config.TrailerBoats = {
    -- dinghy
    [1033245328] = {model = "dinghy",  name = "Dinghy", brand = "Trailers"},
    [276773164]  = {model = "dinghy2", name = "Dinghy", brand = "Trailers"},
    [509498602]  = {model = "dinghy3", name = "Dinghy", brand = "Trailers"},
    [867467158]  = {model = "dinghy4", name = "Dinghy", brand = "Trailers"},
    [3314393930] = {model = "dinghy5", name = "Dinghy", brand = "Trailers"},
    -- seashark
    [-1030275036] = {model = "seashark",  name = "Seashark", brand = "Trailers"},
    [3678636260]  = {model = "seashark2", name = "Seashark", brand = "Trailers"},
    [3983945033]  = {model = "seashark3", name = "Seashark", brand = "Trailers"},
}
