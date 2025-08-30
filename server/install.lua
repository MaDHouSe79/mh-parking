Citizen.CreateThread(function()
    Wait(5000)
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `player_parking` (
            `id` int(10) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `citizenname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `model` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `modelname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `plate` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `steerangle` int(15) NOT NULL DEFAULT 0,
            `fuel` int(15) NOT NULL DEFAULT 0,
            `engine` int(15) NOT NULL DEFAULT 0,
            `body` int(15) NOT NULL DEFAULT 0,
            `oil` int(15) NOT NULL DEFAULT 0,
            `data` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
            `coords` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
            `time` bigint(20) NOT NULL,
            `cost` int(10) NOT NULL DEFAULT 0,
            `parktime` int(10) NOT NULL DEFAULT 0,
            `parking` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
            PRIMARY KEY (`id`) USING BTREE
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;   
    ]])
end)

Citizen.CreateThread(function()
    Wait(5100)
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS `player_parking_vips` (
            `id` int(10) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `citizenname` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
            `maxparking` int(10) NOT NULL DEFAULT 0,
            `hasparked` int(10) NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`) USING BTREE
        ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci ROW_FORMAT=DYNAMIC;      
    ]])
end)
