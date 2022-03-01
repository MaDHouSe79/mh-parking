## ---------------------------------------------Updates------------------------------------------------
## Fix Update and some changes 👊😉👍 27-2-2022
- you can still park where ever you want, just set Config.UseParkZones to false
- players still not be bable to park on pre-created parking places. 
- Cause this can be prived or job or paid or even free or what if it is a not park place at all.
- You can all do this at this moment, i build a build mode in it so you can easy place more parking places.
- You can also use polyzone to get more performes out of the mod, (for huge server)

## Fixes
- No dubble vehicle spawning, vehicles keys are now succes added to the owner of the vehicle.


## NOTE
- Remove your old [player_parking] database table and change it with this table below.
- Or rename [player_parking] to [player_parking_vehicles].
- but if you dont have the coords in your than you need to update the table to this table.
```sql
CREATE TABLE `player_parking_vehicles`  (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `citizenname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `model` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `modelname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fuel` int(15) NOT NULL DEFAULT 0,
  `oil` int(15) NOT NULL DEFAULT 0,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;
```


## Polyzone NOTE
- Vehicles only showup when you inside a park zone, the same for the park markers and names.
- You can sill add park spaces that are paid or free or just no park space at all.
- to create a parking spot fist use the command [/park-build] to enable the build mode, so you can lineup the markers.
- Then you typ [/park-create] to open the NUI menu, and create your parking spot.
- All parking locations are saved in de folder [configs] you can also find the polyzones.lua file if you want to make any changes. 


## All Commands
- [/park]              -- 👉 User/Admin
- [/park-names]        -- 👉 User/Admin
- [/park-lotnames]     -- 👉 User/Admin
- [/park-notification] -- 👉 User/Admin
- [/park-system]       -- 👉 Admin
- [/park-usevip]       -- 👉 Admin
- [/park-addvip]       -- 👉 Admin
- [/park-removevip]    -- 👉 Admin
- [/park-create]       -- 👉 Admin
- [/park-build]        -- 👉 Admin


## 😎 Special thanks for helping me with testing 👊😉👍
- 💪 GUS
- 💪 Jazerra
- 💪 ameN
- 💪 MulGirtab
- 💪 DannyJ
- 💪 MasonJason310
- 💪 Enxsistanz
- 💪 !ExiledVibe!
- 💪 FARRUKO

## 🙈 My Youtube & My Discord 👊😉👍
- [Youtube](https://www.youtube.com/channel/UC6431XeIqHjswry5OYtim0A)
- [Discord](https://discord.gg/cEMSeE9dgS)
