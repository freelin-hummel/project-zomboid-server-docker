SandboxVars = {
    VERSION = 6,
    -- Changing this also sets the "Population Multiplier" in Advanced Zombie Options. Default = Normal
    -- 1 = Insane
    -- 2 = Very High
    -- 3 = High
    -- 4 = Normal
    -- 5 = Low
    -- 6 = None
    Zombies = 4,
    -- How zombies are distributed across the map. Default = Urban Focused
    -- 1 = Urban Focused
    -- 2 = Uniform
    Distribution = 1,
    -- Controls whether some randomization is applied to zombie distribution.
    ZombieVoronoiNoise = true,
    -- How frequently new zombies are added to the world. Default = Normal
    -- 1 = High
    -- 2 = Normal
    -- 3 = Low
    -- 4 = None
    ZombieRespawn = 2,
    -- Zombie allowed to migrate to empty cells.
    ZombieMigrate = true,
    -- Default = 1 Hour, 30 Minutes
    -- 1 = 15 Minutes
    -- 2 = 30 Minutes
    -- 3 = 1 Hour
    -- 4 = 1 Hour, 30 Minutes
    -- 5 = 2 Hours
    -- 6 = 3 Hours
    -- 7 = 4 Hours
    -- 8 = 5 Hours
    -- 9 = 6 Hours
    -- 10 = 7 Hours
    -- 11 = 8 Hours
    -- 12 = 9 Hours
    -- 13 = 10 Hours
    -- 14 = 11 Hours
    -- 15 = 12 Hours
    -- 16 = 13 Hours
    -- 17 = 14 Hours
    -- 18 = 15 Hours
    -- 19 = 16 Hours
    -- 20 = 17 Hours
    -- 21 = 18 Hours
    -- 22 = 19 Hours
    -- 23 = 20 Hours
    -- 24 = 21 Hours
    -- 25 = 22 Hours
    -- 26 = 23 Hours
    -- 27 = Real-time
    DayLength = 4,
    StartYear = 1,
    -- Month in which the game starts. Default = July
    -- 1 = January
    -- 2 = February
    -- 3 = March
    -- 4 = April
    -- 5 = May
    -- 6 = June
    -- 7 = July
    -- 8 = August
    -- 9 = September
    -- 10 = October
    -- 11 = November
    -- 12 = December
    StartMonth = 7,
    -- Day of the month in which the games starts.
    StartDay = 9,
    -- Hour of the day in which the game starts. Default = 9 AM
    -- 1 = 7 AM
    -- 2 = 9 AM
    -- 3 = 12 PM
    -- 4 = 2 PM
    -- 5 = 5 PM
    -- 6 = 9 PM
    -- 7 = 12 AM
    -- 8 = 2 AM
    -- 9 = 5 AM
    StartTime = 2,
    -- Whether the time of day changes naturally, or it's always day/night. Default = Normal
    -- 1 = Normal
    -- 2 = Endless Day
    -- 3 = Endless Night
    DayNightCycle = 1,
    -- Whether weather changes or remains at a single state. Default = Normal
    -- 1 = Normal
    -- 2 = No Weather
    -- 3 = Endless Rain
    -- 4 = Endless Storm
    -- 5 = Endless Snow
    -- 6 = Endless Blizzard
    ClimateCycle = 1,
    -- Whether fog occurs naturally, never occurs, or is always present. Default = Normal
    -- 1 = Normal
    -- 2 = No Fog
    -- 3 = Endless Fog
    FogCycle = 1,
    -- How long after the default start date (July 9, 1993) that plumbing fixtures (eg. sinks) stop being infinite sources of water. Default = 0-30 Days
    -- 1 = Instant
    -- 2 = 0-30 Days
    -- 3 = 0-2 Months
    -- 4 = 0-6 Months
    -- 5 = 0-1 Year
    -- 6 = 0-5 Years
    -- 7 = 2-6 Months
    -- 8 = 6-12 Months
    -- 9 = Disabled
    WaterShut = 2,
    -- How long after the default start date (July 9, 1993) that the world's electricity turns off for good. Default = 0-30 Days
    -- 1 = Instant
    -- 2 = 0-30 Days
    -- 3 = 0-2 Months
    -- 4 = 0-6 Months
    -- 5 = 0-1 Year
    -- 6 = 0-5 Years
    -- 7 = 2-6 Months
    -- 8 = 6-12 Months
    -- 9 = Disabled
    ElecShut = 2,
    -- How long alarm batteries can last for after the power shuts off. Default = 0-30 Days
    -- 1 = Instant
    -- 2 = 0-30 Days
    -- 3 = 0-2 Months
    -- 4 = 0-6 Months
    -- 5 = 0-1 Year
    -- 6 = 0-5 Years
    AlarmDecay = 2,
    -- How long after the default start date (July 9, 1993) that plumbing fixtures (eg. sinks) stop being infinite sources of water. Min: -1 Max: 2147483647 Default: 14
    WaterShutModifier = 14,
    -- How long after the default start date (July 9, 1993) that the world's electricity turns off for good. Min: -1 Max: 2147483647 Default: 14
    ElecShutModifier = 14,
    -- How long alarm batteries can last for after the power shuts off. Min: -1 Max: 2147483647 Default: 14
    AlarmDecayModifier = 14,
    -- Any food that can rot or spoil. Min: 0.00 Max: 4.00 Default: 0.60
    FoodLootNew = 0.6,
    -- All items that can be read, includes fliers Min: 0.00 Max: 4.00 Default: 0.60
    LiteratureLootNew = 0.6,
    -- Medicine, bandages and first aid tools. Min: 0.00 Max: 4.00 Default: 0.60
    MedicalLootNew = 0.6,
    -- Fishing Rods, Tents, camping gear etc. Min: 0.00 Max: 4.00 Default: 0.60
    SurvivalGearsLootNew = 0.6,
    -- Canned and dried food, beverages. Min: 0.00 Max: 4.00 Default: 0.60
    CannedFoodLootNew = 0.6,
    -- Weapons that are not tools in other categories. Min: 0.00 Max: 4.00 Default: 0.60
    WeaponLootNew = 0.6,
    -- Also includes weapon attachments. Min: 0.00 Max: 4.00 Default: 0.60
    RangedWeaponLootNew = 0.6,
    -- Loose ammo, boxes and magazines. Min: 0.00 Max: 4.00 Default: 0.60
    AmmoLootNew = 0.6,
    -- Vehicle parts and the tools needed to install them. Min: 0.00 Max: 4.00 Default: 0.60
    MechanicsLootNew = 0.6,
    -- Everything else. Also affects foraging for all items in Town/Road zones. Min: 0.00 Max: 4.00 Default: 0.60
    OtherLootNew = 0.6,
    -- All wearable items that are not containers. Min: 0.00 Max: 4.00 Default: 0.60
    ClothingLootNew = 0.6,
    -- Backpacks and other wearable/equippable containers, eg. cases. Min: 0.00 Max: 4.00 Default: 0.60
    ContainerLootNew = 0.6,
    -- Keys for buildings/cars, key rings, and locks. Min: 0.00 Max: 4.00 Default: 0.60
    KeyLootNew = 0.6,
    -- VHS tapes and CDs. Min: 0.00 Max: 4.00 Default: 0.60
    MediaLootNew = 0.6,
    -- Spiffo items, plushies, and other collectible keepsake items eg. Photos. Min: 0.00 Max: 4.00 Default: 0.60
    MementoLootNew = 0.6,
    -- Items that are used in cooking, including those (eg. knives) which can be weapons. Does not include food. Includes both usable and unusable items. Min: 0.00 Max: 4.00 Default: 0.60
    CookwareLootNew = 0.6,
    -- Items and weapons that are used as ingredients for crafting or building. This is a general category that does not include items belonging to other categories such as Cookware or Medical. Does not include Tools. Min: 0.00 Max: 4.00 Default: 0.60
    MaterialLootNew = 0.6,
    -- Items and weapons which are used in both animal and plant agriculture, such as Seeds, Trowels, or Shovels. Min: 0.00 Max: 4.00 Default: 0.60
    FarmingLootNew = 0.6,
    -- Items and weapons which are Tools but don't fit in other categories such as Mechanics or Farming. Min: 0.00 Max: 4.00 Default: 0.60
    ToolLootNew = 0.6,
    -- <BHC> [!] It is recommended that you DO NOT change this. [!] <RGB:1,1,1>   Can be used to adjust the number of rolls made on loot tables when spawning loot. Will not reduce the number of rolls below 1. Can negatively affect performance if set to high values. It is highly recommended that this not be changed. Min: 0.10 Max: 100.00 Default: 1.00
    RollsMultiplier = 1.0,
    -- A comma-separated list of item types that won't spawn as ordinary loot.
    LootItemRemovalList = "",
    -- If enabled, items on the Loot Item Removal List, or that have their rarity set to 'None', will not spawn in randomised world stories.
    RemoveStoryLoot = false,
    -- If enabled, items on the Loot Item Removal List, or that have their rarity set to 'None', will not spawn worn by, or attached to, zombies.
    RemoveZombieLoot = false,
    -- If greater than 0, the spawn of loot is increased relative to the number of nearby zombies,  with the effect multiplied by this number. Min: 0 Max: 20 Default: 10
    ZombiePopLootEffect = 10,
    -- Min: 0.00 Max: 0.20 Default: 0.05
    InsaneLootFactor = 0.05,
    -- Min: 0.05 Max: 0.60 Default: 0.20
    ExtremeLootFactor = 0.2,
    -- Min: 0.20 Max: 1.00 Default: 0.60
    RareLootFactor = 0.6,
    -- Min: 0.60 Max: 2.00 Default: 1.00
    NormalLootFactor = 1.0,
    -- Min: 1.00 Max: 3.00 Default: 2.00
    CommonLootFactor = 2.0,
    -- Min: 2.00 Max: 4.00 Default: 3.00
    AbundantLootFactor = 3.0,
    -- The global temperature. Default = Normal
    -- 1 = Very Cold
    -- 2 = Cold
    -- 3 = Normal
    -- 4 = Hot
    -- 5 = Very Hot
    Temperature = 3,
    -- How often it rains. Default = Normal
    -- 1 = Very Dry
    -- 2 = Dry
    -- 3 = Normal
    -- 4 = Rainy
    -- 5 = Very Rainy
    Rain = 3,
    -- Number of days until the erosion system (which adds vines, long grass, new trees etc. to the world) will reach 100% growth. Default = Normal (100 Days)
    -- 1 = Very Fast (20 Days)
    -- 2 = Fast (50 Days)
    -- 3 = Normal (100 Days)
    -- 4 = Slow (200 Days)
    -- 5 = Very Slow (500 Days)
    ErosionSpeed = 3,
    -- For a custom Erosion Speed. Zero means use the Erosion Speed option. Maximum is 36,500 days (approximately 100 years). Min: -1 Max: 36500 Default: 0
    ErosionDays = 0,
    -- The speed of plant growth. Default = Normal
    -- 1 = Very Fast
    -- 2 = Fast
    -- 3 = Normal
    -- 4 = Slow
    -- 5 = Very Slow
    Farming = 3,
    -- How long it takes for food to break down in a composter. Default = 2 Weeks
    -- 1 = 1 Week
    -- 2 = 2 Weeks
    -- 3 = 3 Weeks
    -- 4 = 4 Weeks
    -- 5 = 6 Weeks
    -- 6 = 8 Weeks
    -- 7 = 10 Weeks
    -- 8 = 12 Weeks
    CompostTime = 2,
    -- How fast the player's hunger, thirst, and fatigue will decrease. Default = Normal
    -- 1 = Very Fast
    -- 2 = Fast
    -- 3 = Normal
    -- 4 = Slow
    -- 5 = Very Slow
    StatsDecrease = 3,
    -- The abundance of items found in Foraging mode. Default = Normal
    -- 1 = Very Poor
    -- 2 = Poor
    -- 3 = Normal
    -- 4 = Abundant
    -- 5 = Very Abundant
    NatureAbundance = 3,
    -- How likely the player is to activate a house alarm when breaking into a new house. Default = Sometimes
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    Alarm = 4,
    -- How frequently the doors of homes and buildings will be locked when discovered. Default = Very Often
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    LockedHouses = 6,
    -- Spawn with Chips, a Water Bottle, a Small Backpack, a Baseball Bat, and a Hammer.
    StarterKit = false,
    -- Nutritional value of food affects the player's condition. Turning this off will stop the player gaining or losing weight.
    Nutrition = true,
    -- How fast that food will spoil, inside or outside of a fridge. Default = Normal
    -- 1 = Very Fast
    -- 2 = Fast
    -- 3 = Normal
    -- 4 = Slow
    -- 5 = Very Slow
    FoodRotSpeed = 3,
    -- How effective a fridge will be at keeping food fresh for longer. Default = Normal
    -- 1 = Very Low
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Very High
    -- 6 = No decay
    FridgeFactor = 3,
    -- When greater than 0, loot will not respawn in zones that have been visited within this number of in-game hours. Min: 0 Max: 2147483647 Default: 0
    SeenHoursPreventLootRespawn = 0,
    -- When greater than 0, after X hours, all containers in towns and trailer parks in the world will respawn loot. To spawn loot a container must have been looted at least once. Loot respawn is not impacted by visibility or subsequent looting. Min: 0 Max: 2147483647 Default: 0
    HoursForLootRespawn = 0,
    -- Containers with a number of items greater, or equal to, this setting will not respawn. Min: 0 Max: 2147483647 Default: 5
    MaxItemsForLootRespawn = 5,
    -- Items will not respawn in buildings that players have barricaded or built in.
    ConstructionPreventsLootRespawn = true,
    -- A comma-separated list of item types that will be removed after HoursForWorldItemRemoval hours.
    WorldItemRemovalList = "Base.Hat,Base.Glasses,Base.Maggots,Base.Slug,Base.Slug2,Base.Snail,Base.Worm,Base.Dung_Mouse,Base.Dung_Rat",
    -- Number of hours since an item was dropped on the ground before it is removed.  Items are removed the next time that part of the map is loaded.   Zero means items are not removed. Min: 0.00 Max: 2147483647.00 Default: 24.00
    HoursForWorldItemRemoval = 24.0,
    -- If true, any items *not* in WorldItemRemovalList will be removed.
    ItemRemovalListBlacklistToggle = false,
    -- How long after the end of the world to begin. This will affect starting world erosion and food spoilage. Does not affect the starting date. Default = 0
    -- 1 = 0
    -- 2 = 1
    -- 3 = 2
    -- 4 = 3
    -- 5 = 4
    -- 6 = 5
    -- 7 = 6
    -- 8 = 7
    -- 9 = 8
    -- 10 = 9
    -- 11 = 10
    -- 12 = 11
    -- 13 = 12
    TimeSinceApo = 1,
    -- How much water plants will lose per day, and their ability to avoid disease. Default = Normal
    -- 1 = Very High
    -- 2 = High
    -- 3 = Normal
    -- 4 = Low
    -- 5 = Very Low
    PlantResilience = 3,
    -- The yield of plants when harvested. Default = Normal
    -- 1 = Very Poor
    -- 2 = Poor
    -- 3 = Normal
    -- 4 = Abundant
    -- 5 = Very Abundant
    PlantAbundance = 3,
    -- Recovery from being tired after performing actions. Default = Normal
    -- 1 = Very Fast
    -- 2 = Fast
    -- 3 = Normal
    -- 4 = Slow
    -- 5 = Very Slow
    EndRegen = 3,
    -- How regularly a helicopter passes over the Event Zone. Default = Once
    -- 1 = Never
    -- 2 = Once
    -- 3 = Sometimes
    -- 4 = Often
    Helicopter = 2,
    -- How often zombie-attracting metagame events like distant gunshots will occur. Default = Sometimes
    -- 1 = Never
    -- 2 = Sometimes
    -- 3 = Often
    MetaEvent = 2,
    -- How often events during the player's sleep, like nightmares, occur. Default = Never
    -- 1 = Never
    -- 2 = Sometimes
    -- 3 = Often
    SleepingEvent = 1,
    -- How much fuel is consumed by generators per in-game hour. Min: 0.00 Max: 100.00 Default: 0.10
    GeneratorFuelConsumption = 0.1,
    -- The chance of electrical generators spawning on the map. Default = Rare
    -- 1 = None (not recommended)
    -- 2 = Insanely Rare
    -- 3 = Extremely Rare
    -- 4 = Rare
    -- 5 = Normal
    -- 6 = Common
    -- 7 = Abundant
    GeneratorSpawning = 4,
    -- How often a looted map will have notes on it, written by a deceased survivor. Default = Sometimes
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    AnnotatedMapChance = 4,
    -- Adds free points during character creation. Min: -100 Max: 100 Default: 0
    CharacterFreePoints = 0,
    -- Gives player-built constructions extra hit points so they are  more resistant to zombie damage. Default = Normal
    -- 1 = Very Low
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Very High
    ConstructionBonusPoints = 3,
    -- The level of ambient lighting at night. Default = Normal
    -- 1 = Pitch Black
    -- 2 = Dark
    -- 3 = Normal
    -- 4 = Bright
    NightDarkness = 3,
    -- The time from dusk to dawn. Default = Normal
    -- 1 = Always Night
    -- 2 = Long
    -- 3 = Normal
    -- 4 = Short
    -- 5 = Always Day
    NightLength = 3,
    -- If survivors can get broken limbs from impacts, zombie damage, falls etc.
    BoneFracture = true,
    -- The impact that injuries have on your body, and their healing time. Default = Normal
    -- 1 = Low
    -- 2 = Normal
    -- 3 = High
    InjurySeverity = 2,
    -- How long, in hours, before dead zombie bodies disappear from the world.  If 0, maggots will not spawn on corpses. Min: -1.00 Max: 2147483647.00 Default: 216.00
    HoursForCorpseRemoval = 216.0,
    -- The impact that nearby decaying bodies has on the player's health and emotions. Default = Normal
    -- 1 = None
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Insane
    DecayingCorpseHealthImpact = 3,
    -- Whether nearby "living" zombies have the same impact on the player's health and emotions.
    ZombieHealthImpact = false,
    -- How much blood is sprayed on floors and walls by injuries. Default = Normal
    -- 1 = None
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Ultra Gore
    BloodLevel = 3,
    -- How quickly clothing degrades, becomes dirty, and bloodied. Default = Normal
    -- 1 = Disabled
    -- 2 = Slow
    -- 3 = Normal
    -- 4 = Fast
    ClothingDegradation = 3,
    -- If fires spread when started.
    FireSpread = true,
    -- Number of in-game days before rotten food is removed from the map.  -1 means rotten food is never removed. Min: -1 Max: 2147483647 Default: -1
    DaysForRottenFoodRemoval = -1,
    -- If enabled, generators will work on exterior tiles.  This will allow, for example, the powering of gas pumps.
    AllowExteriorGenerator = true,
    -- Maximum intensity of fog. Default = Normal
    -- 1 = Normal
    -- 2 = Moderate
    -- 3 = Low
    -- 4 = None
    MaxFogIntensity = 1,
    -- Maximum intensity of rain. Default = Normal
    -- 1 = Normal
    -- 2 = Moderate
    -- 3 = Low
    MaxRainFxIntensity = 1,
    -- If snow will accumulate on the ground.  If disabled, snow will still show on vegetation and rooftops.
    EnableSnowOnGround = true,
    -- If melee attacking slows you down.
    AttackBlockMovements = true,
    -- The chance of finding randomized buildings on the map (eg. burnt out houses,  ones containing loot stashes or dead bodies). Default = Rare
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    -- 7 = Always Tries
    SurvivorHouseChance = 3,
    -- The chance of road stories (eg. police roadblocks) spawning. Default = Rare
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    -- 7 = Always Tries
    VehicleStoryChance = 3,
    -- The chance of stories specific to map zones (eg. a campsite in a forest) spawning. Default = Rare
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    -- 7 = Always Tries
    ZoneStoryChance = 3,
    -- Allows you to select from every piece of clothing in the game when customizing your character
    AllClothesUnlocked = false,
    -- If tainted water will show a warning marking it as such.
    EnableTaintedWaterText = true,
    -- If vehicles will spawn.
    EnableVehicles = true,
    -- How frequently vehicles can be discovered on the map. Default = Low
    -- 1 = None
    -- 2 = Very Low
    -- 3 = Low
    -- 4 = Normal
    -- 5 = High
    CarSpawnRate = 3,
    -- General engine loudness to zombies. Min: 0.00 Max: 100.00 Default: 1.00
    ZombieAttractionMultiplier = 1.0,
    -- Whether found vehicles are locked, need keys to start etc.
    VehicleEasyUse = false,
    -- How full the gas tank of discovered vehicles will be. Default = Low
    -- 1 = Very Low
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Very High
    -- 6 = Full
    InitialGas = 2,
    -- If enabled, gas pumps will never run out of fuel
    FuelStationGasInfinite = false,
    -- The minimum amount of gasoline that can spawn in gas pumps. Check the "Advanced" box below to use a custom amount. Min: 0.00 Max: 1.00 Default: 0.00
    FuelStationGasMin = 0.0,
    -- The maximum amount of gasoline that can spawn in gas pumps. Check the "Advanced" box below to use a custom amount. Min: 0.00 Max: 1.00 Default: 0.70
    FuelStationGasMax = 0.7,
    -- The chance, as a percentage, that individual gas pumps will initially have no fuel. Min: 0 Max: 100 Default: 20
    FuelStationGasEmptyChance = 20,
    -- How likely cars will be locked Default = Rare
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    LockedCar = 3,
    -- How gas-hungry vehicles are. Min: 0.00 Max: 100.00 Default: 1.00
    CarGasConsumption = 1.0,
    -- General condition discovered vehicles will be in. Default = Low
    -- 1 = Very Low
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Very High
    CarGeneralCondition = 2,
    -- The amount of damage dealt to vehicles that crash. Default = Normal
    -- 1 = Very Low
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Very High
    CarDamageOnImpact = 3,
    -- Damage received by the player from being crashed into. Default = None
    -- 1 = None
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    -- 5 = Very High
    DamageToPlayerFromHitByACar = 1,
    -- If traffic jams consisting of wrecked cars  will appear on main roads.
    TrafficJam = true,
    -- How frequently discovered vehicles have active alarms. Default = Extremely Rare
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    CarAlarm = 2,
    -- If the player can get injured from being in a car accident.
    PlayerDamageFromCrash = true,
    -- How many in-game hours before a wailing siren shuts off. Min: 0.00 Max: 168.00 Default: 0.00
    SirenShutoffHours = 0.0,
    -- The chance of finding a vehicle with gas in its tank. Default = Low
    -- 1 = Low
    -- 2 = Normal
    -- 3 = High
    ChanceHasGas = 1,
    -- Whether a player can discover a car that has been cared for  after the Knox infection struck. Default = Low
    -- 1 = None
    -- 2 = Low
    -- 3 = Normal
    -- 4 = High
    RecentlySurvivorVehicles = 2,
    -- If certain melee weapons will be able to strike multiple zombies in one hit.
    MultiHitZombies = true,
    -- Chance of being bitten when a zombie attacks from behind. Default = High
    -- 1 = Low
    -- 2 = Medium
    -- 3 = High
    RearVulnerability = 3,
    -- If zombies will head towards the sound of vehicle sirens.
    SirenEffectsZombies = true,
    -- Speed at which animals stats (hunger, thirst etc.) reduce. Default = Normal
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalStatsModifier = 4,
    -- Speed at which animals stats (hunger, thirst etc.) reduce while in meta. Default = Normal
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalMetaStatsModifier = 4,
    -- How long animals will be pregnant for before giving birth. Default = Very Fast
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalPregnancyTime = 2,
    -- Speed at which animals age. Default = Fast
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalAgeModifier = 3,
    -- Default = Fast
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalMilkIncModifier = 3,
    -- Default = Fast
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalWoolIncModifier = 3,
    -- The chance of finding animals in farm. Default = Always
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    -- 7 = Always
    AnimalRanchChance = 7,
    -- The number of hours grass will regrow after being  eaten by an animal or cut by the player. Min: 1 Max: 9999 Default: 240
    AnimalGrassRegrowTime = 240,
    -- If a meta (ie. not actually visible in-game) fox may attack  your chickens if the hutch's door is left open at night.
    AnimalMetaPredator = false,
    -- If animals with a mating season will respect it.  Otherwise they can reproduce/lay eggs all year round. 
    AnimalMatingSeason = true,
    -- How long before baby animals will hatch from eggs. Default = Fast
    -- 1 = Ultra Fast
    -- 2 = Very Fast
    -- 3 = Fast
    -- 4 = Normal
    -- 5 = Slow
    -- 6 = Very Slow
    AnimalEggHatch = 3,
    -- If true, animal calls will attract nearby zombies.
    AnimalSoundAttractZombies = false,
    -- The chance of animals leaving tracks. Default = Sometimes
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    AnimalTrackChance = 4,
    -- The chance of creating a path for animals to be hunted. Default = Sometimes
    -- 1 = Never
    -- 2 = Extremely Rare
    -- 3 = Rare
    -- 4 = Sometimes
    -- 5 = Often
    -- 6 = Very Often
    AnimalPathChance = 4,
    -- The frequency and intensity of eg. rats in infested buildings. Min: 0 Max: 50 Default: 25
    MaximumRatIndex = 25,
    -- How long it takes for the Maximum Vermin Index to be reached. Min: 0 Max: 365 Default: 90
    DaysUntilMaximumRatIndex = 90,
    -- If a piece of media hasn't been fully seen or read, this setting determines whether it's displayed fully, displayed as "???", or hidden completely. Default = Completely hidden
    -- 1 = Fully revealed
    -- 2 = Shown as ???
    -- 3 = Completely hidden
    MetaKnowledge = 3,
    -- If true, you will be able to see any recipes that can be done with a station, even if you haven't learnt them yet.
    SeeNotLearntRecipe = true,
    -- If a building has more than this amount of rooms it will not be looted. Min: 0 Max: 200 Default: 50
    MaximumLootedBuildingRooms = 50,
    -- If poison can be added to food. Default = True
    -- 1 = True
    -- 2 = False
    -- 3 = Only bleach poisoning is disabled
    EnablePoisoning = 1,
    -- If/when maggots can spawn in corpses. Default = In and Around Bodies
    -- 1 = In and Around Bodies
    -- 2 = In Bodies Only
    -- 3 = Never
    MaggotSpawn = 1,
    -- The higher the value, the longer lightbulbs last before breaking.  If 0, lightbulbs will never break.  Does not affect vehicle headlights. Min: 0.00 Max: 1000.00 Default: 1.00
    LightBulbLifespan = 1.0,
    -- The abundance of fish in rivers and lakes. Default = Normal
    -- 1 = Very Poor
    -- 2 = Poor
    -- 3 = Normal
    -- 4 = Abundant
    -- 5 = Very Abundant
    FishAbundance = 3,
    -- When a skill is at this level or above, television/VHS/other media  will not provide XP for it. Min: 0 Max: 10 Default: 3
    LevelForMediaXPCutoff = 3,
    -- When a skill is at this level or above, scrapping furniture does not provide XP for the relevant skill. Does not apply to Electrical. Min: 0 Max: 10 Default: 0
    LevelForDismantleXPCutoff = 0,
    -- Number of days before old blood splats are removed. Removal happens when map chunks are loaded. 0 means they will never disappear. Min: 0 Max: 365 Default: 0
    BloodSplatLifespanDays = 0,
    -- Number of days before one can benefit from reading previously read literature items. Min: 1 Max: 365 Default: 90
    LiteratureCooldown = 90,
    -- If there are diminishing returns on bonus trait points provided from selecting multiple negative traits. Default = None
    -- 1 = None
    -- 2 = 1 point penalty for every 3 negative traits selected
    -- 3 = 1 point penalty for every 2 negative traits selected
    -- 4 = 1 point penalty for every negative trait selected after the first
    NegativeTraitsPenalty = 1,
    -- The number of in-game minutes it takes to read one page of a skill book. Min: 0.00 Max: 60.00 Default: 2.00
    MinutesPerPage = 2.0,
    -- When enabled, crops and herbs grown inside buildings will die. Does not affect houseplants.
    KillInsideCrops = true,
    -- When enabled, the growth of plants is affected by seasons.
    PlantGrowingSeasons = true,
    -- <BHC> [!] It is recommended that you DO NOT change this. Changing this can result in performance issues. [!] <RGB:1,1,1>   When enabled, dirt can be placed, and farming performed on other than the ground level.
    PlaceDirtAboveground = false,
    -- The speed of plant growth. Min: 0.10 Max: 100.00 Default: 1.00
    FarmingSpeedNew = 1.0,
    -- The abundance of harvested crops. Min: 0.10 Max: 10.00 Default: 1.00
    FarmingAmountNew = 1.0,
    -- The chance that any building will already be looted when found. Check the "Advanced" box below to use a custom number. Min: 0 Max: 200 Default: 50
    MaximumLooted = 50,
    -- How long it takes for Maximum Looted Building Chance to be reached. Min: 0 Max: 3650 Default: 90
    DaysUntilMaximumLooted = 90,
    -- The chance that any rural building will already be looted when found. Check the "Advanced" box below to use a custom number. Min: 0.00 Max: 2.00 Default: 0.50
    RuralLooted = 0.5,
    -- The maximum loot that won't spawn when Days Until Maximum Diminished Loot is reached. Check the "Advanced" box below to use an exact percentage. Min: 0 Max: 100 Default: 0
    MaximumDiminishedLoot = 0,
    -- How long it takes for Maximum Diminished Loot Percentage to be reached. Min: 0 Max: 3650 Default: 3650
    DaysUntilMaximumDiminishedLoot = 3650,
    -- Functions as a multiplier when applying muscle strain from swinging weapons or carrying heavy loads. Min: 0.00 Max: 10.00 Default: 1.00
    MuscleStrainFactor = 1.0,
    -- Functions as a multiplier when applying discomfort from worn items. Min: 0.00 Max: 10.00 Default: 1.00
    DiscomfortFactor = 1.0,
    -- If greater than zero damage can be taken from serious wound infections. Min: 0.00 Max: 10.00 Default: 0.00
    WoundInfectionFactor = 0.0,
    -- If true clothing with randomized tints will not be so dark to be virtually black.
    NoBlackClothes = true,
    -- Disables the failure chances when climbing sheet ropes or over walls.
    EasyClimbing = false,
    -- The maximum hours of fuel that can be placed in a campfire, wood stove etc. Min: 1 Max: 168 Default: 8
    MaximumFireFuelHours = 8,
    -- Replaces Chance-To-Hit mechanics with Chance-To-Damage calculations.  This mode prioritizes player aiming.
    FirearmUseDamageChance = true,
    -- A multiplier for the distance at which zombies can hear gunshots. Min: 0.20 Max: 2.00 Default: 1.00
    FirearmNoiseMultiplier = 1.0,
    -- Multiplier for firearm jamming chance. 0 disables jamming. Min: 0.00 Max: 10.00 Default: 0.00
    FirearmJamMultiplier = 0.0,
    -- Multiplier for Moodle effects on hit chance. 0 disables Moodle penalty. Min: 0.00 Max: 10.00 Default: 1.00
    FirearmMoodleMultiplier = 1.0,
    -- Multiplier for the effects of weather (wind, rain and fog) on hit chance. 0 disables weather effect. Min: 0.00 Max: 10.00 Default: 1.00
    FirearmWeatherMultiplier = 1.0,
    -- Enable to have headgear like welding masks affect hit chance
    FirearmHeadGearEffect = true,
    -- Chance to turn a dirt floor into a clay floor. Applies to lakes. Min: 0.00 Max: 1.00 Default: 0.05
    ClayLakeChance = 0.05,
    -- Chance to turn a dirt floor into a clay floor. Applies to rivers. Min: 0.00 Max: 1.00 Default: 0.05
    ClayRiverChance = 0.05,
    -- Min: 1 Max: 100 Default: 20
    GeneratorTileRange = 20,
    -- How many levels both above and below a generator it can provide with electricity. Min: 1 Max: 15 Default: 3
    GeneratorVerticalPowerRange = 3,
    VRO_EnableEngineRebuild = false,
    VRO_UseVanillaFixingRecipes = false,
    VRO_EnableFullVehicleSalvaging = true,
    -- Min: 10 Max: 1000 Default: 49
    ResidentEvilBackpackCapacity = 49,
    -- Min: 10 Max: 100 Default: 98
    ResidentEvilBackpackWeightReduction = 98,
    -- Min: 3 Max: 1000 Default: 10
    ResidentEvilSuspendersCapacity = 10,
    -- Min: 10 Max: 100 Default: 98
    ResidentEvilSuspendersWeightReduction = 98,
    RaccoonCityDivider0 = false,
    DisablePoliceMusic = false,
    DisableVaccines = false,
    DisableDaBaoJian = false,
    DisableBenelli = false,
    DisableQiBao = false,
    DisableSamuraiEdge = false,
    DisableResidentEvilRightClickMenu = false,
    DisableAdapterSuppressor = false,
    RaccoonCityDivider1 = false,
    ResidentEvilBuildAddBuildingCraft = false,
    SnackTime89_LootRarity = 2,
    SnackTime89_ZombieLootRarity = 2,
    Basement = {
        -- How frequently basements spawn at random locations. Default = Sometimes
        -- 1 = Never
        -- 2 = Extremely Rare
        -- 3 = Rare
        -- 4 = Sometimes
        -- 5 = Often
        -- 6 = Very Often
        -- 7 = Always
        SpawnFrequency = 4,
    },
    Map = {
        -- If enabled, a mini-map window will be available.
        AllowMiniMap = true,
        -- If enabled, the world map can be accessed.
        AllowWorldMap = true,
        -- If enabled, the world map will be completely filled in on starting the game.
        MapAllKnown = false,
        -- If enabled, maps can't be read unless there's a source of light available.
        MapNeedsLight = true,
    },
    ZombieLore = {
        -- How fast zombies move. Default = Random
        -- 1 = Sprinters
        -- 2 = Fast Shamblers
        -- 3 = Shamblers
        -- 4 = Random
        Speed = 2,
        -- If Random Speed is enabled, this controls what percentage of zombies are Sprinters. Check the "Advanced" box below to use a custom percentage. Min: 0 Max: 100 Default: 0
        SprinterPercentage = 0,
        -- The damage zombies inflict per attack. Default = Normal
        -- 1 = Superhuman
        -- 2 = Normal
        -- 3 = Weak
        -- 4 = Random
        Strength = 2,
        -- The difficulty of killing a zombie. Default = Random
        -- 1 = Tough
        -- 2 = Normal
        -- 3 = Fragile
        -- 4 = Random
        Toughness = 4,
        -- How the Knox Virus spreads. Default = Blood and Saliva
        -- 1 = Blood and Saliva
        -- 2 = Saliva Only
        -- 3 = Everyone's Infected
        -- 4 = None
        Transmission = 1,
        -- How quickly the infection takes effect. Default = 2-3 Days
        -- 1 = Instant
        -- 2 = 0-30 Seconds
        -- 3 = 0-1 Minutes
        -- 4 = 0-12 Hours
        -- 5 = 2-3 Days
        -- 6 = 1-2 Weeks
        -- 7 = Never
        Mortality = 5,
        -- How quickly infected corpses rise as zombies. Default = 0-1 Minutes
        -- 1 = Instant
        -- 2 = 0-30 Seconds
        -- 3 = 0-1 Minutes
        -- 4 = 0-12 Hours
        -- 5 = 2-3 Days
        -- 6 = 1-2 Weeks
        Reanimate = 3,
        -- Zombie intelligence. Default = Basic Navigation
        -- 1 = Navigate and Use Doors
        -- 2 = Navigate
        -- 3 = Basic Navigation
        -- 4 = Random
        Cognition = 3,
        -- How often zombies can crawl under parked vehicles. Default = Often
        -- 1 = Crawlers Only
        -- 2 = Extremely Rare
        -- 3 = Rare
        -- 4 = Sometimes
        -- 5 = Often
        -- 6 = Very Often
        -- 7 = Always
        CrawlUnderVehicle = 5,
        -- How long zombies remember a player after seeing or hearing them. Default = Normal
        -- 1 = Long
        -- 2 = Normal
        -- 3 = Short
        -- 4 = None
        -- 5 = Random
        -- 6 = Random between Normal and None
        Memory = 2,
        -- Zombie vision radius. Default = Random between Normal and Poor
        -- 1 = Eagle
        -- 2 = Normal
        -- 3 = Poor
        -- 4 = Random
        -- 5 = Random between Normal and Poor
        Sight = 5,
        -- Zombie hearing radius. Default = Random between Normal and Poor
        -- 1 = Pinpoint
        -- 2 = Normal
        -- 3 = Poor
        -- 4 = Random
        -- 5 = Random between Normal and Poor
        Hearing = 5,
        -- Activates the new advanced stealth mechanics, which allows you to hide from zombies behind cars, takes traits and weather into account, and much more.
        SpottedLogic = true,
        -- If zombies that have not seen/heard player can attack doors and constructions while roaming.
        ThumpNoChasing = false,
        -- If zombies can destroy player constructions and defenses.
        ThumpOnConstruction = true,
        -- Whether zombies are more "active" during the day or night.  "Active" zombies will use the speed set in the "Speed" setting.  "Inactive" zombies will be slower, and tend not to give chase. Default = Both
        -- 1 = Both
        -- 2 = Night
        -- 3 = Day
        ActiveOnly = 1,
        -- If zombies trigger house alarms when breaking through windows or doors.
        TriggerHouseAlarm = false,
        -- If multiple attacking zombies can drag you down and kill you.  Dependent on zombie strength.
        ZombiesDragDown = true,
        -- If crawler zombies beside a player contribute to the chance of being dragged down and killed by a group of zombies.
        ZombiesCrawlersDragDown = false,
        -- If zombies have a chance to lunge at you after climbing over a fence or through a window if you're too close.
        ZombiesFenceLunge = true,
        -- Serves as a multiplier when determining the effectiveness of armor worn by zombies. Min: 0.00 Max: 100.00 Default: 2.00
        ZombiesArmorFactor = 2.0,
        -- The maximum defense percentage that any worn protective garments can provide to a zombie. Min: 0 Max: 100 Default: 85
        ZombiesMaxDefense = 85,
        -- Percentage chance of having a random attached weapon. Min: 0 Max: 100 Default: 6
        ChanceOfAttachedWeapon = 6,
        -- How much damage zombies take when falling from height. Min: 0.00 Max: 100.00 Default: 1.00
        ZombiesFallDamage = 1.0,
        -- Whether some dead-looking zombies will reanimate and attack the player. Default = World Zombies
        -- 1 = World Zombies
        -- 2 = World and Combat Zombies
        -- 3 = Never
        DisableFakeDead = 1,
        -- Zombies will not spawn where players spawn. Default = Inside the building and around it
        -- 1 = Inside the building and around it
        -- 2 = Inside the building
        -- 3 = Inside the room
        -- 4 = Zombies can spawn anywhere
        PlayerSpawnZombieRemoval = 1,
        -- How many zombies it takes to damage a tall fence. Min: -1 Max: 100 Default: 50
        FenceThumpersRequired = 50,
        -- How quickly zombies damage tall fences. Min: 0.01 Max: 100.00 Default: 1.00
        FenceDamageMultiplier = 1.0,
    },
    ZombieConfig = {
        -- Set by the "Zombie Count" population option, or by a custom number here. Insane = 2.5, Very High = 1.6, High = 1.2, Normal = 0.65, Low = 0.15, None = 0.0. Min: 0.00 Max: 4.00 Default: 0.65
        PopulationMultiplier = 0.65,
        -- A multiplier for the desired zombie population at the start of the game. Insane = 3.0, Very High = 2.0, High = 1.5, Normal = 1.0, Low = 0.5, None = 0.0. Min: 0.00 Max: 4.00 Default: 1.00
        PopulationStartMultiplier = 1.0,
        -- A multiplier for the desired zombie population on the peak day. Insane = 3.0, Very High = 2.0, High = 1.5, Normal = 1.0, Low = 0.5, None = 0.0. Min: 0.00 Max: 4.00 Default: 1.50
        PopulationPeakMultiplier = 1.5,
        -- The day when the population reaches its peak. Min: 1 Max: 365 Default: 28
        PopulationPeakDay = 28,
        -- The number of hours that must pass before zombies may respawn in a cell. If 0, spawning is disabled. Min: 0.00 Max: 8760.00 Default: 72.00
        RespawnHours = 72.0,
        -- The number of hours that a chunk must be unseen before zombies may respawn in it. Min: 0.00 Max: 8760.00 Default: 16.00
        RespawnUnseenHours = 16.0,
        -- The fraction of a cell's desired population that may respawn every RespawnHours. Min: 0.00 Max: 1.00 Default: 0.10
        RespawnMultiplier = 0.1,
        -- The number of hours that must pass before zombies migrate  to empty parts of the same cell. If 0, migration is disabled. Min: 0.00 Max: 8760.00 Default: 12.00
        RedistributeHours = 12.0,
        -- The distance a zombie will try to walk towards the last sound it heard. Min: 10 Max: 1000 Default: 100
        FollowSoundDistance = 100,
        -- The size of groups real zombies form when idle. 0 means zombies don't form groups. Groups don't form inside buildings or forest zones. Min: 0 Max: 1000 Default: 20
        RallyGroupSize = 20,
        -- The amount, as a percentage, that zombie groups can vary in size from the default (both larger and smaller).   For example, at 50% variance with a default group size of 20, groups will vary in size from 10-30. Min: 0 Max: 100 Default: 50
        RallyGroupSizeVariance = 50,
        -- The distance real zombies travel to form groups when idle. Min: 5 Max: 50 Default: 20
        RallyTravelDistance = 20,
        -- The distance between zombie groups. Min: 5 Max: 25 Default: 15
        RallyGroupSeparation = 15,
        -- How close members of a zombie group stay to the group's "leader". Min: 1 Max: 10 Default: 3
        RallyGroupRadius = 3,
        -- Min: 10 Max: 500 Default: 300
        ZombiesCountBeforeDelete = 300,
    },
    MultiplierConfig = {
        -- The rate at which all skills level up. Min: 0.00 Max: 1000.00 Default: 1.00
        Global = 1.0,
        -- When enabled, all skills will use the Global Multiplier.
        GlobalToggle = true,
        -- Rate at which Fitness skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Fitness = 1.0,
        -- Rate at which Strength skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Strength = 1.0,
        -- Rate at which Sprinting skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Sprinting = 1.0,
        -- Rate at which Lightfooted skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Lightfoot = 1.0,
        -- Rate at which Nimble skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Nimble = 1.0,
        -- Rate at which Sneaking skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Sneak = 1.0,
        -- Rate at which Axe skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Axe = 1.0,
        -- Rate at which Long Blunt skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Blunt = 1.0,
        -- Rate at which Short Blunt skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        SmallBlunt = 1.0,
        -- Rate at which Long Blade skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        LongBlade = 1.0,
        -- Rate at which Short Blade skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        SmallBlade = 1.0,
        -- Rate at which Spear skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Spear = 1.0,
        -- Rate at which Maintenance skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Maintenance = 1.0,
        -- Rate at which Carpentry skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Woodwork = 1.0,
        -- Rate at which Cooking skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Cooking = 1.0,
        -- Rate at which Agriculture skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Farming = 1.0,
        -- Rate at which First Aid skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Doctor = 1.0,
        -- Rate at which Electrical skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Electricity = 1.0,
        -- Rate at which Welding skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        MetalWelding = 1.0,
        -- Rate at which Mechanics skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Mechanics = 1.0,
        -- Rate at which Tailoring skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Tailoring = 1.0,
        -- Rate at which Aiming skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Aiming = 1.0,
        -- Rate at which Reloading skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Reloading = 1.0,
        -- Rate at which Fishing skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Fishing = 1.0,
        -- Rate at which Trapping skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Trapping = 1.0,
        -- Rate at which Foraging skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        PlantScavenging = 1.0,
        -- Rate at which Knapping skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        FlintKnapping = 1.0,
        -- Rate at which Masonry skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Masonry = 1.0,
        -- Rate at which Pottery skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Pottery = 1.0,
        -- Rate at which Carving skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Carving = 1.0,
        -- Rate at which Animal Care skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Husbandry = 1.0,
        -- Rate at which Tracking skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Tracking = 1.0,
        -- Rate at which Blacksmithing skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Blacksmith = 1.0,
        -- Rate at which Butchering skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Butchering = 1.0,
        -- Rate at which Glassmaking skill levels up. Min: 0.00 Max: 1000.00 Default: 1.00
        Glassmaking = 1.0,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        Art = 1.0,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        Cleaning = 1.0,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        Dancing = 1.0,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        Meditation = 1.0,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        Music = 1.0,
    },
    DynamicTrading = {
        -- Min: 5 Max: 50 Default: 12
        MaxLogs = 12,
        -- Min: 0.10 Max: 10.00 Default: 3.00
        PriceBuyMult = 3.0,
        -- Min: 0.00 Max: 5.00 Default: 0.50
        PriceSellMult = 0.5,
        -- Min: 0.10 Max: 5.00 Default: 1.00
        StockMult = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 0.01
        InflationDecay = 0.01,
        -- Min: -50 Max: 100 Default: 0
        RarityBonus = 0,
        -- Min: 1 Max: 30 Default: 1
        RestockInterval = 1,
        -- Min: 1 Max: 100 Default: 30
        ScanBaseChance = 30,
        -- Min: 0 Max: 1440 Default: 30
        ScanCooldown = 30,
        -- Min: 1.00 Max: 5.00 Default: 1.50
        HamRadioBonus = 1.5,
        -- Min: 1 Max: 20 Default: 2
        DailyTraderMin = 2,
        -- Min: 1 Max: 50 Default: 10
        DailyTraderMax = 10,
        -- Min: 0.00 Max: 1.00 Default: 0.50
        ScanPenaltyPerTrader = 0.5,
        -- Min: 0.00 Max: 5.00 Default: 1.00
        SeasonImpact = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 0.05
        CategoryInflation = 0.05,
        -- Min: 1 Max: 32 Default: 6
        TraderStayHoursMin = 6,
        -- Min: 1 Max: 336 Default: 24
        TraderStayHoursMax = 24,
        -- Min: 0 Max: 100000 Default: 100
        TraderBudgetMin = 100,
        -- Min: 10 Max: 1000000 Default: 500
        TraderBudgetMax = 500,
        -- Min: 1 Max: 30 Default: 2
        EventFrequency = 2,
        -- Min: 1 Max: 100 Default: 80
        EventChance = 80,
        -- Min: 1 Max: 14 Default: 3
        EventDuration = 3,
        AllowSeasonalEvents = true,
        AllowHardcoreEvents = true,
        PublicNetwork = false,
        -- Min: 1 Max: 10 Default: 8
        MaxEvents = 8,
        -- Min: 0.00 Max: 100.00 Default: 20.00
        WalkieDropChance = 20.0,
        -- Min: 1 Max: 80 Default: 20
        WalletMinCashPercent = 20,
        -- Min: 2 Max: 100 Default: 80
        WalletMaxCashPercent = 80,
        -- Min: 0 Max: 100 Default: 35
        WalletEmptyChance = 35,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        WalletJackpotChance = 1.0,
        -- Min: 1 Max: 100 Default: 5
        SellDeflationChance = 5,
        -- Min: 0 Max: 100 Default: 20
        SellPriceReductionChance = 20,
        -- Min: 0 Max: 10000000 Default: 10000
        GlobalWealthStart = 10000,
        -- Min: 0 Max: 50000 Default: 500
        GlobalWealthStimulus = 500,
    },
    ProjectSummerCar = {
        TakeOverSpawning = false,
        RemoveWreckedCars = true,
        -- Min: 0.00 Max: 1.00 Default: 0.10
        BurntCarChance = 0.1,
        -- Min: 0.00 Max: 1.00 Default: 0.50
        LowOrHigh = 0.5,
        -- Min: 0.00 Max: 1.00 Default: 0.10
        LowCondition = 0.1,
        -- Min: 0.10 Max: 10.00 Default: 1.50
        LowToMid = 1.5,
        -- Min: 0.00 Max: 1.00 Default: 0.50
        MidCondition = 0.5,
        -- Min: 0.10 Max: 10.00 Default: 0.70
        MidToHigh = 0.7,
        -- Min: 0.00 Max: 1.00 Default: 0.90
        HighCondition = 0.9,
        -- Min: 0.00 Max: 1.00 Default: 0.40
        PartChanceLowCond = 0.4,
        -- Min: 0.00 Max: 1.00 Default: 1.00
        PartChanceLowCondChance = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 1.00
        PartChanceHighCond = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 1.00
        PartChanceHighCondChance = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 1.00
        PartChanceSurvivorMin = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 1.00
        PartChanceSurvivorMax = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 0.20
        PartChanceTrafficMin = 0.2,
        -- Min: 0.00 Max: 1.00 Default: 0.90
        PartChanceTrafficMax = 0.9,
        -- Min: 0.00 Max: 1.00 Default: 0.00
        RandomPartChance = 0.0,
        -- Min: 0.00 Max: 2.00 Default: 0.30
        ConditionRandom = 0.3,
        RepairParts = true,
        -- Min: 0.00 Max: 10.00 Default: 0.00
        MinHP = 0.0,
        -- Min: 0.00 Max: 1.00 Default: 0.00
        MinHPCondition = 0.0,
        -- Min: 0.00 Max: 10.00 Default: 1.00
        MaxHP = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 1.00
        MaxHPCondition = 1.0,
        -- Min: 0.00 Max: 3.00 Default: 0.50
        PerformancePartBoost = 0.5,
        -- Min: 0.00 Max: 10.00 Default: 1.00
        EngineImpactDamage = 1.0,
        -- Min: 1 Max: 20 Default: 4
        EngineImpactDamageCount = 4,
        SmartOilIndicator = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        OilLeakRate = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        OilDecayRate = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        OilFilterDecayRate = 1.0,
        -- Min: 0.10 Max: 10.00 Default: 2.00
        BatteryChargedBias = 2.0,
        -- Min: 0.00 Max: 1.00 Default: 0.80
        BatteryChargedChance = 0.8,
        -- Min: 0.00 Max: 1.00 Default: 0.50
        BatteryGoodChance = 0.5,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        ChargeRate = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        BatteryCapacity = 1.0,
        -- Min: 0.00 Max: 1.00 Default: 0.20
        BatteryCapacityLowConditionMultiplier = 0.2,
    },
    SPNCharCustom = {
        AllowCustomisationChange = 4,
        AdminLockedCustomisation = "",
        -- Min: 0 Max: 20 Default: 10
        BodyHairGrowth = 10,
        -- Min: 0 Max: 20 Default: 6
        StubbleHeadGrowth = 6,
        -- Min: 0 Max: 20 Default: 3
        StubbleBeardGrowth = 3,
        BodyHairGrowthEnabled = 1,
        MuscleVisuals = 1,
        -- Min: 0.10 Max: 1.00 Default: 0.50
        MissingEyeVisionModifier = 0.5,
        WashMakeup = true,
    },
    Tikitown = {
        CollectionPlush = true,
        CollectionBaseball = true,
        -- Min: 0.00 Max: 30.00 Default: 1.00
        CollectionBaseballCommon = 1.0,
        -- Min: 0.00 Max: 30.00 Default: 1.00
        CollectionBaseballRare = 1.0,
        -- Min: 0.00 Max: 0.40 Default: 0.08
        CollectionBaseballZombieCommon = 0.075,
        -- Min: 0.00 Max: 0.40 Default: 0.03
        CollectionBaseballZombieRare = 0.025,
        HistoricalOutfits = true,
        MedicalStims = true,
        LaserTagItems = true,
    },
    VMZ = {
        SpecCar = false,
        -- Min: 0 Max: 100 Default: 16
        SpawnRate = 16,
        -- Min: 0 Max: 100 Default: 50
        VehiCond = 50,
        -- Min: 0 Max: 100 Default: 0
        PartDamage = 0,
        -- Min: 0 Max: 100 Default: 70
        KeySpawn = 70,
        SpecCar = false,
        -- Min: 0 Max: 100 Default: 16
        SpawnRate = 16,
        -- Min: 0 Max: 100 Default: 50
        VehiCond = 50,
        -- Min: 0 Max: 100 Default: 0
        PartDamage = 0,
        -- Min: 0 Max: 100 Default: 70
        KeySpawn = 70,
    },
    DAMN = {
        AllowPowerChadSpawns = true,
        AllowPro440Spawns = true,
        AllowWreckyMcChevySpawns = true,
        AllowManlyMANSpawns = true,
        AllowGreatScottSpawns = false,
        AllowMrBusSpawns = true,
        AllowChonkerSpawns = true,
        AllowCashcowSpawns = true,
        AllowMcBoxySpawns = true,
        AllowBushmasterSpawns = true,
    },
    CF8KSweeper = {
        AllowTiles = true,
        SpriteWhitelist = "brokenglass_1_;trash_01_;d_trash_;street_decoration_01_26;street_decoration_01_27;damaged_objects_01_26;damaged_objects_01_27;damaged_objects_01_18;damaged_objects_01_19;damaged_objects_01_20;damaged_objects_01_21",
        AllowBlood = true,
        AllowGrime = true,
        AllowAshes = true,
        AllowItems = true,
        AllowCorpses = true,
        AllowUserAutoDelete = false,
    },
    AirdropMain = {
        DefaultAirdropCoordinates = true,
        -- Min: 0 Max: 100 Default: 50
        Preset_Container2Chance = 50,
        -- Min: 0 Max: 100 Default: 25
        Preset_Container3Chance = 25,
        Preset_Military_Enabled = true,
        Preset_Military_Item1 = "\"Base.Pistol3\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Military_Item1Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item1Qty = 1,
        Preset_Military_Item2 = "\"Base.44Clip\"",
        -- Min: 0 Max: 100 Default: 75
        Preset_Military_Item2Chance = 75,
        -- Min: 1 Max: 99 Default: 2
        Preset_Military_Item2Qty = 2,
        Preset_Military_Item3 = "\"Base.Bullets44Box\"",
        -- Min: 0 Max: 100 Default: 70
        Preset_Military_Item3Chance = 70,
        -- Min: 1 Max: 99 Default: 2
        Preset_Military_Item3Qty = 2,
        Preset_Military_Item4 = "\"Base.Shotgun\"",
        -- Min: 0 Max: 100 Default: 50
        Preset_Military_Item4Chance = 50,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item4Qty = 1,
        Preset_Military_Item5 = "\"Base.ShotgunShellsBox\"",
        -- Min: 0 Max: 100 Default: 65
        Preset_Military_Item5Chance = 65,
        -- Min: 1 Max: 99 Default: 2
        Preset_Military_Item5Qty = 2,
        Preset_Military_Item6 = "\"Base.AmmoStraps\"",
        -- Min: 0 Max: 100 Default: 55
        Preset_Military_Item6Chance = 55,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item6Qty = 1,
        Preset_Military_Item7 = "\"Base.HolsterDouble\"",
        -- Min: 0 Max: 100 Default: 45
        Preset_Military_Item7Chance = 45,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item7Qty = 1,
        Preset_Military_Item8 = "\"Base.Hat_Army\"",
        -- Min: 0 Max: 100 Default: 60
        Preset_Military_Item8Chance = 60,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item8Qty = 1,
        Preset_Military_Item9 = "\"Base.Ghillie_Top\"",
        -- Min: 0 Max: 100 Default: 35
        Preset_Military_Item9Chance = 35,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item9Qty = 1,
        Preset_Military_Item10 = "\"Base.Ghillie_Trousers\"",
        -- Min: 0 Max: 100 Default: 35
        Preset_Military_Item10Chance = 35,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item10Qty = 1,
        Preset_Military_Item11 = "\"Base.AssaultRifle2\"",
        -- Min: 0 Max: 100 Default: 28
        Preset_Military_Item11Chance = 28,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item11Qty = 1,
        Preset_Military_Item12 = "\"Base.556Clip\"",
        -- Min: 0 Max: 100 Default: 42
        Preset_Military_Item12Chance = 42,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item12Qty = 1,
        Preset_Military_Item13 = "\"Base.556Box\"",
        -- Min: 0 Max: 100 Default: 38
        Preset_Military_Item13Chance = 38,
        -- Min: 1 Max: 99 Default: 2
        Preset_Military_Item13Qty = 2,
        Preset_Military_Item14 = "\"Base.308Box\"",
        -- Min: 0 Max: 100 Default: 32
        Preset_Military_Item14Chance = 32,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item14Qty = 1,
        Preset_Military_Item15 = "\"Base.Bullets9mmBox\"",
        -- Min: 0 Max: 100 Default: 48
        Preset_Military_Item15Chance = 48,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item15Qty = 1,
        Preset_Military_Item16 = "\"Base.Hat_PeakedCapArmy\"",
        -- Min: 0 Max: 100 Default: 40
        Preset_Military_Item16Chance = 40,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item16Qty = 1,
        Preset_Military_Item17 = "\"Base.Glasses_Shooting\"",
        -- Min: 0 Max: 100 Default: 35
        Preset_Military_Item17Chance = 35,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item17Qty = 1,
        Preset_Military_Item18 = "\"Base.Bag_Military\"",
        -- Min: 0 Max: 100 Default: 25
        Preset_Military_Item18Chance = 25,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item18Qty = 1,
        Preset_Military_Item19 = "\"Base.Bag_ChestRig\"",
        -- Min: 0 Max: 100 Default: 30
        Preset_Military_Item19Chance = 30,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item19Qty = 1,
        Preset_Military_Item20 = "\"Base.WristWatch_Right_ClassicMilitary\"",
        -- Min: 0 Max: 100 Default: 22
        Preset_Military_Item20Chance = 22,
        -- Min: 1 Max: 99 Default: 1
        Preset_Military_Item20Qty = 1,
        Preset_Humanitarian_Enabled = true,
        Preset_Humanitarian_Item1 = "\"Base.WaterBottle\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Humanitarian_Item1Chance = 100,
        -- Min: 1 Max: 99 Default: 4
        Preset_Humanitarian_Item1Qty = 4,
        Preset_Humanitarian_Item2 = "\"Base.CannedCornedBeef\"",
        -- Min: 0 Max: 100 Default: 85
        Preset_Humanitarian_Item2Chance = 85,
        -- Min: 1 Max: 99 Default: 3
        Preset_Humanitarian_Item2Qty = 3,
        Preset_Humanitarian_Item3 = "\"Base.CannedFruitCocktail\"",
        -- Min: 0 Max: 100 Default: 80
        Preset_Humanitarian_Item3Chance = 80,
        -- Min: 1 Max: 99 Default: 2
        Preset_Humanitarian_Item3Qty = 2,
        Preset_Humanitarian_Item4 = "\"Base.CannedSoup\"",
        -- Min: 0 Max: 100 Default: 75
        Preset_Humanitarian_Item4Chance = 75,
        -- Min: 1 Max: 99 Default: 2
        Preset_Humanitarian_Item4Qty = 2,
        Preset_Humanitarian_Item5 = "\"Base.Nails\"",
        -- Min: 0 Max: 100 Default: 70
        Preset_Humanitarian_Item5Chance = 70,
        -- Min: 1 Max: 99 Default: 5
        Preset_Humanitarian_Item5Qty = 5,
        Preset_Humanitarian_Item6 = "\"Base.CampingStove\"",
        -- Min: 0 Max: 100 Default: 45
        Preset_Humanitarian_Item6Chance = 45,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item6Qty = 1,
        Preset_Humanitarian_Item7 = "\"Base.FryingPan\"",
        -- Min: 0 Max: 100 Default: 55
        Preset_Humanitarian_Item7Chance = 55,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item7Qty = 1,
        Preset_Humanitarian_Item8 = "\"Base.PetrolCan\"",
        -- Min: 0 Max: 100 Default: 50
        Preset_Humanitarian_Item8Chance = 50,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item8Qty = 1,
        Preset_Humanitarian_Item9 = "\"Base.Hammer\"",
        -- Min: 0 Max: 100 Default: 48
        Preset_Humanitarian_Item9Chance = 48,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item9Qty = 1,
        Preset_Humanitarian_Item10 = "\"Base.Screwdriver\"",
        -- Min: 0 Max: 100 Default: 52
        Preset_Humanitarian_Item10Chance = 52,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item10Qty = 1,
        Preset_Humanitarian_Item11 = "\"Base.Trowel\"",
        -- Min: 0 Max: 100 Default: 38
        Preset_Humanitarian_Item11Chance = 38,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item11Qty = 1,
        Preset_Humanitarian_Item12 = "\"Base.GardenFork\"",
        -- Min: 0 Max: 100 Default: 32
        Preset_Humanitarian_Item12Chance = 32,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item12Qty = 1,
        Preset_Humanitarian_Item13 = "\"Base.GardenSpade\"",
        -- Min: 0 Max: 100 Default: 32
        Preset_Humanitarian_Item13Chance = 32,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item13Qty = 1,
        Preset_Humanitarian_Item14 = "\"Base.WateringCan\"",
        -- Min: 0 Max: 100 Default: 35
        Preset_Humanitarian_Item14Chance = 35,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item14Qty = 1,
        Preset_Humanitarian_Item15 = "\"Base.HandAxe\"",
        -- Min: 0 Max: 100 Default: 40
        Preset_Humanitarian_Item15Chance = 40,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item15Qty = 1,
        Preset_Humanitarian_Item16 = "\"Base.Crowbar\"",
        -- Min: 0 Max: 100 Default: 42
        Preset_Humanitarian_Item16Chance = 42,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item16Qty = 1,
        Preset_Humanitarian_Item17 = "\"Base.DuctTape\"",
        -- Min: 0 Max: 100 Default: 58
        Preset_Humanitarian_Item17Chance = 58,
        -- Min: 1 Max: 99 Default: 2
        Preset_Humanitarian_Item17Qty = 2,
        Preset_Humanitarian_Item18 = "\"Base.Wrench\"",
        -- Min: 0 Max: 100 Default: 35
        Preset_Humanitarian_Item18Chance = 35,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item18Qty = 1,
        Preset_Humanitarian_Item19 = "\"Base.Saw\"",
        -- Min: 0 Max: 100 Default: 28
        Preset_Humanitarian_Item19Chance = 28,
        -- Min: 1 Max: 99 Default: 1
        Preset_Humanitarian_Item19Qty = 1,
        Preset_Humanitarian_Item20 = "\"Base.Rice\"",
        -- Min: 0 Max: 100 Default: 65
        Preset_Humanitarian_Item20Chance = 65,
        -- Min: 1 Max: 99 Default: 2
        Preset_Humanitarian_Item20Qty = 2,
        Preset_Medical_Enabled = true,
        Preset_Medical_Item1 = "\"Base.Bandage\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item1Chance = 100,
        -- Min: 1 Max: 99 Default: 4
        Preset_Medical_Item1Qty = 4,
        Preset_Medical_Item2 = "\"Base.AlcoholWipes\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item2Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item2Qty = 1,
        Preset_Medical_Item3 = "\"Base.Disinfectant\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item3Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item3Qty = 1,
        Preset_Medical_Item4 = "\"Base.Painkillers\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item4Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item4Qty = 1,
        Preset_Medical_Item5 = "\"Base.Antibiotics\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item5Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item5Qty = 1,
        Preset_Medical_Item6 = "\"Base.FirstAidKit\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item6Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item6Qty = 1,
        Preset_Medical_Item7 = "\"Base.Pills\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item7Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item7Qty = 1,
        Preset_Medical_Item8 = "\"Base.Splint\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item8Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item8Qty = 1,
        Preset_Medical_Item9 = "\"Base.Tweezers\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item9Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item9Qty = 1,
        Preset_Medical_Item10 = "\"Base.SutureNeedle\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item10Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item10Qty = 1,
        Preset_Medical_Item11 = "\"Base.SutureNeedleHolder\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item11Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item11Qty = 1,
        Preset_Medical_Item12 = "\"Base.BetaBlockers\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item12Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item12Qty = 1,
        Preset_Medical_Item13 = "\"Base.Scalpel\"",
        -- Min: 0 Max: 100 Default: 28
        Preset_Medical_Item13Chance = 28,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item13Qty = 1,
        Preset_Medical_Item14 = "\"Base.PillsVitamins\"",
        -- Min: 0 Max: 100 Default: 45
        Preset_Medical_Item14Chance = 45,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item14Qty = 1,
        Preset_Medical_Item15 = "\"Base.Thermometer\"",
        -- Min: 0 Max: 100 Default: 38
        Preset_Medical_Item15Chance = 38,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item15Qty = 1,
        Preset_Medical_Item16 = "\"Base.Bandage\"",
        -- Min: 0 Max: 100 Default: 62
        Preset_Medical_Item16Chance = 62,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item16Qty = 1,
        Preset_Medical_Item17 = "\"Base.Splint\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Medical_Item17Chance = 100,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item17Qty = 1,
        Preset_Medical_Item18 = "\"Base.SutureNeedle\"",
        -- Min: 0 Max: 100 Default: 30
        Preset_Medical_Item18Chance = 30,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item18Qty = 1,
        Preset_Medical_Item19 = "\"Base.SutureNeedleHolder\"",
        -- Min: 0 Max: 100 Default: 28
        Preset_Medical_Item19Chance = 28,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item19Qty = 1,
        Preset_Medical_Item20 = "\"Base.BetaBlockers\"",
        -- Min: 0 Max: 100 Default: 40
        Preset_Medical_Item20Chance = 40,
        -- Min: 1 Max: 99 Default: 1
        Preset_Medical_Item20Qty = 1,
        Preset_Survival_Enabled = true,
        Preset_Survival_Item1 = "\"Base.WaterBottle\"",
        -- Min: 0 Max: 100 Default: 100
        Preset_Survival_Item1Chance = 100,
        -- Min: 1 Max: 99 Default: 4
        Preset_Survival_Item1Qty = 4,
        Preset_Survival_Item2 = "\"Base.CannedCornedBeef\"",
        -- Min: 0 Max: 100 Default: 82
        Preset_Survival_Item2Chance = 82,
        -- Min: 1 Max: 99 Default: 2
        Preset_Survival_Item2Qty = 2,
        Preset_Survival_Item3 = "\"Base.CannedFruitCocktail\"",
        -- Min: 0 Max: 100 Default: 80
        Preset_Survival_Item3Chance = 80,
        -- Min: 1 Max: 99 Default: 2
        Preset_Survival_Item3Qty = 2,
        Preset_Survival_Item4 = "\"Base.FishingRod\"",
        -- Min: 0 Max: 100 Default: 65
        Preset_Survival_Item4Chance = 65,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item4Qty = 1,
        Preset_Survival_Item5 = "\"Base.FishingTackle\"",
        -- Min: 0 Max: 100 Default: 70
        Preset_Survival_Item5Chance = 70,
        -- Min: 1 Max: 99 Default: 2
        Preset_Survival_Item5Qty = 2,
        Preset_Survival_Item6 = "\"Base.FishingLine\"",
        -- Min: 0 Max: 100 Default: 60
        Preset_Survival_Item6Chance = 60,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item6Qty = 1,
        Preset_Survival_Item7 = "\"Base.TrapCage\"",
        -- Min: 0 Max: 100 Default: 48
        Preset_Survival_Item7Chance = 48,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item7Qty = 1,
        Preset_Survival_Item8 = "\"Base.TrapSnare\"",
        -- Min: 0 Max: 100 Default: 52
        Preset_Survival_Item8Chance = 52,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item8Qty = 1,
        Preset_Survival_Item9 = "\"Base.TrapBox\"",
        -- Min: 0 Max: 100 Default: 42
        Preset_Survival_Item9Chance = 42,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item9Qty = 1,
        Preset_Survival_Item10 = "\"Base.Tarp\"",
        -- Min: 0 Max: 100 Default: 55
        Preset_Survival_Item10Chance = 55,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item10Qty = 1,
        Preset_Survival_Item11 = "\"Base.CampingStove\"",
        -- Min: 0 Max: 100 Default: 42
        Preset_Survival_Item11Chance = 42,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item11Qty = 1,
        Preset_Survival_Item12 = "\"Base.HandAxe\"",
        -- Min: 0 Max: 100 Default: 58
        Preset_Survival_Item12Chance = 58,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item12Qty = 1,
        Preset_Survival_Item13 = "\"Base.Rope\"",
        -- Min: 0 Max: 100 Default: 48
        Preset_Survival_Item13Chance = 48,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item13Qty = 1,
        Preset_Survival_Item14 = "\"Base.DuctTape\"",
        -- Min: 0 Max: 100 Default: 55
        Preset_Survival_Item14Chance = 55,
        -- Min: 1 Max: 99 Default: 2
        Preset_Survival_Item14Qty = 2,
        Preset_Survival_Item15 = "\"Base.Flashlight\"",
        -- Min: 0 Max: 100 Default: 45
        Preset_Survival_Item15Chance = 45,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item15Qty = 1,
        Preset_Survival_Item16 = "\"Base.Matches\"",
        -- Min: 0 Max: 100 Default: 72
        Preset_Survival_Item16Chance = 72,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item16Qty = 1,
        Preset_Survival_Item17 = "\"Base.Bag_BigHikingBag\"",
        -- Min: 0 Max: 100 Default: 28
        Preset_Survival_Item17Chance = 28,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item17Qty = 1,
        Preset_Survival_Item18 = "\"Base.Compass\"",
        -- Min: 0 Max: 100 Default: 35
        Preset_Survival_Item18Chance = 35,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item18Qty = 1,
        Preset_Survival_Item19 = "\"Base.PetrolCan\"",
        -- Min: 0 Max: 100 Default: 50
        Preset_Survival_Item19Chance = 50,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item19Qty = 1,
        Preset_Survival_Item20 = "\"Base.Axe\"",
        -- Min: 0 Max: 100 Default: 32
        Preset_Survival_Item20Chance = 32,
        -- Min: 1 Max: 99 Default: 1
        Preset_Survival_Item20Qty = 1,
        -- Min: 0 Max: 9999999 Default: 24
        AirdropRemovalTimer = 24,
        AirdropDisableDespawn = false,
        AirdropDisableOldDespawn = false,
        -- Min: 0 Max: 100 Default: 5
        AirdropFrequency = 5,
        -- Min: 0 Max: 9999999 Default: 30
        AirdropTickCheck = 30,
        AirdropConsoleDebug = false,
        AirdropConsoleDebugCoordinates = false,
    },
    Firearms = {
        ImprovisedSuppressors = true,
        SuppressorBreak = true,
        BottleSuppressorBreakChance = 1,
        FlashlightSuppressorBreakChance = 2,
        SuppressorEffectiveness22 = 3,
        SuppressorEffectiveness9mm = 4,
        SuppressorEffectiveness10mm = 4,
        SuppressorEffectiveness45 = 4,
        SuppressorEffectiveness44 = 4,
        SuppressorEffectiveness38 = 3,
        SuppressorEffectiveness223 = 5,
        SuppressorEffectiveness308 = 6,
        SuppressorEffectivenessShotgunShells = 8,
        SuppressorEffectivenessRevolver = 5,
        SuppressorEffectivenessImprovised = 9,
        -- Default = Insanely Rare
        -- 1 = None (not recommended)
        -- 2 = Insanely Rare
        -- 3 = Extremely Rare
        -- 4 = Rare
        -- 5 = Normal
        -- 6 = Common
        -- 7 = Abundant
        LootSuppressor = 2,
        SpawnAK47 = true,
        SpawnAKM = true,
        SpawnAR15 = true,
        SpawnColtPeacemaker = true,
        SpawnColtAce = true,
        SpawnAnaconda = true,
        SpawnM733 = true,
        SpawnColtDelta = true,
        SpawnPython = true,
        ColtScout = true,
        SpawnFNFal = true,
        SpawnG3 = true,
        SpawnGlock17 = true,
        SpawnICA19 = true,
        SpawnM16A2 = true,
        SpawnM1Garand = true,
        SpawnM24 = true,
        SpawnM37 = true,
        SpawnM4 = true,
        SpawnM60 = true,
        SpawnMAC10 = true,
        SpawnMossberg500 = true,
        SpawnMossberg500Tactical = true,
        SpawnMP5 = true,
        SpawnRemington870 = true,
        SpawnRossi92 = true,
        SpawnRuger22 = true,
        SpawnSKS = true,
        SpawnSPAS12 = true,
        SpawnUZI = true,
        SpawnMarlin1894 = true,
        SpawnWinchester94 = true,
        SpawnSuppressors = true,
        SpawnHandgunSuppressors = true,
        SpawnRifleSuppressors = true,
        SpawnShotgunSuppressors = true,
        SpawnRevolverSuppressors = true,
    },
    Bandits = {
        General_KillCounter = true,
        -- Min: 1.00 Max: 5.00 Default: 2.40
        General_StunlockHitSpeed = 2.4,
        -- Min: 0.25 Max: 4.00 Default: 1.00
        General_SpawnMultiplier = 1.0,
        -- Min: 0.25 Max: 4.00 Default: 1.00
        General_SizeMultiplier = 1.0,
        General_DensityScore = true,
        General_OriginalBandits = true,
        General_Surrender = true,
        General_BleedOut = true,
        General_Infection = true,
        General_LimitedEndurance = true,
        General_RunAway = true,
        General_DestroyDoor = true,
        General_SmashWindow = true,
        General_RemoveBarricade = true,
        General_DestroyThumpable = true,
        General_SabotageVehicles = true,
        General_Theft = true,
        General_SabotageCrops = true,
        General_EnterVehicles = false,
        General_GeneratorCutoff = true,
        General_BuildBridge = false,
        General_BuildRoadblock = true,
        General_Speak = true,
        General_Captions = true,
        General_SneakAtNight = true,
        General_CarryTorches = true,
        General_ArrivalIcon = true,
        General_OverallAccuracy = 3,
        -- Default = Normal
        -- 1 = None (not recommended)
        -- 2 = Insanely Rare
        -- 3 = Extremely Rare
        -- 4 = Rare
        -- 5 = Normal
        -- 6 = Common
        -- 7 = Abundant
        General_DefenderLootAmount = 5,
        General_CorpseSwapper = true,
    },
    BCR = {
        -- Min: 2 Max: 10000 Default: 1000
        BodyCount = 1000,
        enablePositiveTraits = true,
        enableNegativeTraits = true,
        grandMissedOpportunities = false,
        rewardPriority = 1,
        MilestoneScaling = 1,
        -- Min: 0.10 Max: 2.00 Default: 0.50
        ProgressiveScalingFactor = 0.5,
        allow_SPEED_DEMON = true,
        allow_NIGHT_VISION = true,
        allow_DEXTROUS = true,
        allow_FAST_READER = true,
        allow_INVENTIVE = true,
        allow_LIGHT_EATER = true,
        allow_LOW_THIRST = true,
        allow_OUTDOORSMAN = true,
        allow_NEEDS_LESS_SLEEP = true,
        allow_IRON_GUT = true,
        allow_ADRENALINE_JUNKIE = true,
        allow_EAGLE_EYED = true,
        allow_GRACEFUL = true,
        allow_INCONSPICUOUS = true,
        allow_NUTRITIONIST = true,
        allow_ORGANIZED = true,
        allow_RESILIENT = true,
        allow_FAST_HEALER = true,
        allow_FAST_LEARNER = true,
        allow_KEEN_HEARING = true,
        allow_THICK_SKINNED = true,
        allow_HIGH_THIRST = true,
        allow_SUNDAY_DRIVER = true,
        allow_ALL_THUMBS = true,
        allow_CLUMSY = true,
        allow_COWARDLY = true,
        allow_SLOW_READER = true,
        allow_SLOW_HEALER = true,
        allow_WEAK_STOMACH = true,
        allow_SMOKER = true,
        allow_AGORAPHOBIC = true,
        allow_CLAUSTROPHOBIC = true,
        allow_CONSPICUOUS = true,
        allow_HEARTY_APPETITE = true,
        allow_PACIFIST = true,
        allow_PRONE_TO_ILLNESS = true,
        allow_NEEDS_MORE_SLEEP = true,
        allow_ASTHMATIC = true,
        allow_HEMOPHOBIC = true,
        allow_DISORGANIZED = true,
        allow_SLOW_LEARNER = true,
        allow_ILLITERATE = true,
        allow_THIN_SKINNED = true,
    },
    CustomizableWeightMultiplier = {
        -- Min: 0.05 Max: 2.00 Default: 0.30
        WeightMult = 0.3,
    },
    CustomSync = {
        -- Min: 15 Max: 600 Default: 120
        UpdateInterval = 120,
        -- Min: 10 Max: 500 Default: 50
        SyncDistance = 50,
        -- Min: 1 Max: 500 Default: 200
        MaxZombies = 200,
        -- Min: 0.01 Max: 2.00 Default: 1.00
        InterpolationSpeed = 1.0,
        -- Min: 0 Max: 60 Default: 5
        ImmediateZombieCooldown = 5,
        -- Min: 0.05 Max: 2.00 Default: 0.75
        TrailerInterpolationSpeed = 0.75,
        -- Min: 0 Max: 1 Default: 0
        DebugLogs = 0,
    },
    ExtendedBatteryLife = {
        -- Min: 0.00 Max: 1.00 Default: 0.50
        BatteryMultiplier = 0.5,
    },
    HereGoesTheSun = {
        EnableGodRays = true,
        EnableStormMood = true,
        StormMoodPreset = 2,
    },
    InjuredZombiesStumble = {
        -- Min: 0 Max: 100 Default: 40
        BaseChance = 40,
        -- Min: 10 Max: 90 Default: 70
        MinHealthPercent = 70,
        -- Min: 0 Max: 500 Default: 25
        MinCooldown = 25,
        -- Min: 0 Max: 500 Default: 60
        MaxCooldown = 60,
    },
    RadioFrequencyManager = {
        EnablePredefinedChannels = true,
        PredefinedChannels = "89.4;Hitz FM|92.0;Music Radio|92.2;Music Radio|92.4;Music Radio|92.8;Music Radio|93.2;LBMW - Kentucky Radio|98;NNR Radio|99.8;Survivor News|101.2;KnoxTalk Radio|103.6;Sinister Stories|112.2;Weather Forecast",
        -- Min: 1 Max: 4 Default: 1
        DefaultColor = 1,
    },
    MinidoracatFix = {
        FoodNoRot = false,
        FoodContainerDebug = false,
    },
    NepWrecks = {
        -- Min: 0 Max: 100 Default: 10
        FuelUsed = 10,
        NeedMask = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        LootMult = 1.0,
        DebugMode = false,
    },
    ProxInv = {
        ZombieOnly = false,
    },
    RadioBrasil = {
        EnableMarkers = true,
        -- Min: 0 Max: 10 Default: 4
        MarkerSize = 4,
        -- Min: 0 Max: 100 Default: 5
        BroadcastChance = 5,
        -- Min: 0 Max: 10 Default: 0
        MinDaysBetweenBroadcasts = 0,
        DisableCorpses = false,
        UseNightWindow = false,
        -- Min: 1 Max: 5 Default: 1
        LootIntensity = 1,
    },
    ReactiveSE = {
        -- Min: 1 Max: 720 Default: 48
        MinEventCooldown = 48,
        -- Min: 2 Max: 720 Default: 240
        MaxEventCooldown = 240,
        -- Min: 1 Max: 20 Default: 4
        EventChance = 4,
        FlatProbability = true,
        -- Min: 120 Max: 1000 Default: 200
        MinSoundRange = 200,
        -- Min: 120 Max: 1000 Default: 600
        MaxSoundRange = 600,
        -- Min: 120 Max: 1000 Default: 300
        ReactionThresholdRange = 300,
        -- Min: 0 Max: 100 Default: 20
        CloseDistanceChance = 20,
        -- Min: 0 Max: 100 Default: 40
        MediumDistanceChance = 40,
        -- Min: 0 Max: 100 Default: 40
        FarDistanceChance = 40,
        EnableZombieHearing = true,
        EnableDebugMode = false,
    },
    ReactiveSEEvents = {
        EnableAnimalEvents = true,
        EnableGunfightEvents = true,
        EnableGunshotEvents = true,
        EnableScreamEvents = true,
        EnableVehicleCrashEvents = true,
        EnableWeatherEvents = true,
        EnableZombieEvents = true,
    },
    ReactiveSEBehavior = {
        EnablePlayerStyle = true,
        -- Min: 10 Max: 200 Default: 40
        AggressiveStyleKills = 40,
        -- Min: 1 Max: 7 Default: 2
        PassiveStyleDays = 2,
        EnablePlayerReactionPanic = true,
        EnablePlayerReactionWakeUp = true,
    },
    ReactiveSEScenes = {
        EnableEventScenes = true,
        -- Min: 0 Max: 100 Default: 100
        EventSceneChance = 100,
        -- Min: 0 Max: 168 Default: 72
        SceneCleanupHours = 72,
        EnableGunfightScene = true,
        EnableGunshotScene = true,
        EnableScreamScene = true,
        -- Min: 0 Max: 10 Default: 3
        ScreamZombieCount = 3,
        EnableVehicleCrashScene = true,
        VehicleMaxCondition = 2,
        -- Min: 0 Max: 100 Default: 25
        VehicleKeyChance = 25,
        EnableZombieScene = true,
        -- Min: 1 Max: 20 Default: 8
        ZombieSceneMin = 8,
        -- Min: 1 Max: 20 Default: 16
        ZombieSceneMax = 16,
        EnableSceneSpawnNotify = true,
        SceneSpawnNotifyText = true,
        SceneSpawnNotifyMarker = true,
    },
    ReactiveSELoot = {
        LootQuality = 1,
        -- Min: 10 Max: 100 Default: 100
        WeaponMaxCondition = 100,
        -- Min: 0 Max: 100 Default: 10
        RangedWeaponChance = 10,
        -- Min: 0 Max: 100 Default: 0
        MinBackpackStealChance = 0,
        -- Min: 0 Max: 100 Default: 70
        MaxBackpackStealChance = 70,
        AmmoScarcity = 2,
        -- Min: 1 Max: 10 Default: 1
        SubKitCountMin = 1,
        -- Min: 1 Max: 10 Default: 3
        SubKitCountMax = 3,
    },
    ReactiveSEWorld = {
        -- Min: 2 Max: 8 Default: 3
        CorpseCount = 3,
        -- Min: 1 Max: 365 Default: 7
        WorldTierEarlyEnd = 7,
        -- Min: 2 Max: 365 Default: 30
        WorldTierMidEnd = 30,
        -- Min: 3 Max: 365 Default: 90
        WorldTierLateEnd = 90,
    },
    ReactiveSERadio = {
        EnableRadioFeature = true,
        EnableMapMarker = true,
        EnableMorningShowXP = true,
    },
    ThumpingAttractsZombies = {
        -- Min: 1 Max: 50 Default: 8
        BaseRange = 8,
        -- Min: 0.10 Max: 10.00 Default: 2.00
        ScalePerZombie = 2.0,
        -- Min: 0.10 Max: 2.00 Default: 0.80
        Exponent = 0.8,
        -- Min: 5 Max: 100 Default: 30
        MaxRange = 30,
    },
    VacModUtils = {
        EnableDebug = false,
        CommandMonitor = false,
    },
    JordanalSpawns = {
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Black_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Black_Camo_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        DPM95_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Caution_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Caution_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        Caution_UnitChance_Army = 0.01,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        FireFighter_UnitChance_FireDept = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        Neon_Vandals_UnitChance = 0.01,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Neon_Vandals_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        SWAT_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        SWAT_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Trauma_ResponderChance = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        Trauma_ResponderChance_General = 0.01,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Trauma_ResponderChance_Medical = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Alpine_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Alpine_Camo_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Desert_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Desert_Camo_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Flecktarn_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Flecktarn_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Forest_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Forest_Camo_UnitChance_General = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        MARPAT_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        XKU_Camo_UnitChance = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        XKU_Camo_UnitChance_General = 0.02,
    },
    H_E_C_U = {
        EmptyBox0 = false,
        ClothingCategoryDivider = false,
        ClothingSelection = true,
        -- Min: 0.01 Max: 100.00 Default: 1.00
        ClothingSpawnMult = 1.0,
        ClothingMoreSpawns = 1,
        ClothingMoreSpawnsCustom = "",
        EmptyBox0 = false,
        ZedsCategoryDivider = false,
        ZedsCustomSpawn = true,
        -- Min: 0.01 Max: 100.00 Default: 1.00
        ZedSpawnMult = 1.0,
        ZedsMoreSpawns = 1,
        ZedsMoreSpawnsCustom = "",
        ZedAttachedItems = true,
        ZedAttachedItemsRifleCustom = "",
        ZedAttachedItemsRifleVanilla = true,
        ZedAddedItems = true,
        ZedAddedSounds = true,
        EmptyBox0 = false,
        AttachmentsCategoryDivider = false,
        BackpackBackSlot = true,
        BeltSlots = true,
    },
    Collections = {
        -- Min: 0.00 Max: 100.00 Default: 1.00
        RequiredBooks = 1.0,
        ComicsSection = false,
        AnthroComics = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        AnthroComicSpawnRate = 1.0,
        Manga = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        MangaSpawnRate = 1.0,
        ContemporaryComics = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        ContemporaryComicsSpawnRate = 1.0,
        VintageComics = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        VintageComicsSpawnRate = 1.0,
        ComicBox = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        ComicBoxSpawnRate = 1.0,
        MedalsSection = false,
        Medals = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        MedalsSpawnRate = 1.0,
        MedalsRare = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        MedalsRareSpawnRate = 1.0,
        MedalsSilly = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        MedalsSillySpawnRate = 1.0,
        CansSection = false,
        Cans = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        CansSpawnRate = 1.0,
        HeadwearSection = false,
        Helm = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        HelmSpawnRate = 1.0,
        Hat = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        HatSpawnRate = 1.0,
        Starship = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        StarshipSpawn = 1.0,
        UniformSection = false,
        UniformEnable = true,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        UniformSpawnRate = 1.0,
    },
    PZTrueMusicSandbox = {
        -- Min: 0 Max: 100000 Default: 100
        CassetteSpawnRate = 100,
        -- Min: 0 Max: 100000 Default: 100
        CassetteCaseSpawnRate = 100,
        -- Min: 0 Max: 100000 Default: 100
        VinylSpawn = 100,
        -- Min: 0 Max: 100000 Default: 100
        VinylPlayerSpawn = 100,
        -- Min: 0 Max: 100000 Default: 100
        WalkmanSpawn = 100,
        -- Min: 0 Max: 100000 Default: 100
        BoomboxSpawn = 100,
        -- Min: 0 Max: 100000 Default: 100
        ZombieWalkmanSpawnRate = 100,
        StartWithDevice = 1,
        -- Min: 600 Max: 172800 Default: 2100
        MusicPlaybackTimeoutSeconds = 2100,
        -- Min: 1 Max: 50 Default: 5
        MusicTimer = 5,
        EnableDisassembly = true,
    },
    B42Horticulture = {
        LearnedRecipe = true,
    },
    KATTAJ1 = {
        Category1 = false,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        BlackGearedZombiesPatriotArmy = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 0.80
        BlackGearedZombiesDefenderArmy = 0.8,
        -- Min: 0.00 Max: 100.00 Default: 0.40
        BlackGearedZombiesVanguardArmy = 0.4,
        EmptyLine11 = false,
        -- Min: 0.00 Max: 100.00 Default: 2.00
        DesertGearedZombiesPatriotArmy = 2.0,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        DesertGearedZombiesDefenderArmy = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 0.50
        DesertGearedZombiesVanguardArmy = 0.5,
        EmptyLine12 = false,
        -- Min: 0.00 Max: 100.00 Default: 4.00
        GreenGearedZombiesPatriotArmy = 4.0,
        -- Min: 0.00 Max: 100.00 Default: 2.00
        GreenGearedZombiesDefenderArmy = 2.0,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        GreenGearedZombiesVanguardArmy = 1.0,
        EmptyLine13 = false,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        WhiteGearedZombiesPatriotArmy = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 0.80
        WhiteGearedZombiesDefenderArmy = 0.8,
        -- Min: 0.00 Max: 100.00 Default: 0.40
        WhiteGearedZombiesVanguardArmy = 0.4,
        EmptyLine9 = false,
        Category9 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.08
        BlackGearedZombiesPatriotDefault = 0.08,
        -- Min: 0.00 Max: 100.00 Default: 0.06
        BlackGearedZombiesDefenderDefault = 0.06,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        BlackGearedZombiesVanguardDefault = 0.04,
        EmptyLine14 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.20
        DesertGearedZombiesPatriotDefault = 0.2,
        -- Min: 0.00 Max: 100.00 Default: 0.10
        DesertGearedZombiesDefenderDefault = 0.1,
        -- Min: 0.00 Max: 100.00 Default: 0.05
        DesertGearedZombiesVanguardDefault = 0.05,
        EmptyLine15 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.10
        GreenGearedZombiesPatriotDefault = 0.1,
        -- Min: 0.00 Max: 100.00 Default: 0.08
        GreenGearedZombiesDefenderDefault = 0.08,
        -- Min: 0.00 Max: 100.00 Default: 0.06
        GreenGearedZombiesVanguardDefault = 0.06,
        EmptyLine16 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.06
        WhiteGearedZombiesPatriotDefault = 0.06,
        -- Min: 0.00 Max: 100.00 Default: 0.05
        WhiteGearedZombiesDefenderDefault = 0.05,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        WhiteGearedZombiesVanguardDefault = 0.04,
        EmptyLine10 = false,
        Category10 = false,
        -- Min: 0.00 Max: 100.00 Default: 3.00
        BlackGearedZombiesPatriotSecretBase = 3.0,
        -- Min: 0.00 Max: 100.00 Default: 4.00
        BlackGearedZombiesDefenderSecretBase = 4.0,
        -- Min: 0.00 Max: 100.00 Default: 2.00
        BlackGearedZombiesVanguardSecretBase = 2.0,
        EmptyLine17 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.20
        DesertGearedZombiesPatriotSecretBase = 0.2,
        -- Min: 0.00 Max: 100.00 Default: 0.40
        DesertGearedZombiesDefenderSecretBase = 0.4,
        -- Min: 0.00 Max: 100.00 Default: 0.60
        DesertGearedZombiesVanguardSecretBase = 0.6,
        EmptyLine18 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.60
        GreenGearedZombiesPatriotSecretBase = 0.6,
        -- Min: 0.00 Max: 100.00 Default: 0.80
        GreenGearedZombiesDefenderSecretBase = 0.8,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        GreenGearedZombiesVanguardSecretBase = 1.0,
        EmptyLine19 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.80
        WhiteGearedZombiesPatriotSecretBase = 0.8,
        -- Min: 0.00 Max: 100.00 Default: 1.00
        WhiteGearedZombiesDefenderSecretBase = 1.0,
        -- Min: 0.00 Max: 100.00 Default: 2.00
        WhiteGearedZombiesVanguardSecretBase = 2.0,
        EmptyLine2 = false,
        Category2 = false,
        EnableBlackGearLoot = true,
        EnableDesertGearLoot = true,
        EnableGreenGearLoot = true,
        EnableWhiteGearLoot = true,
        EnablePressGearLoot = true,
        EmptyLine3 = false,
        Category3 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.03
        PatriotGear = 0.03,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        DefenderGear = 0.015,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        VanguardGear = 0.005,
        EmptyLine4 = false,
        Category4 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.05
        PocketBackpack = 0.05,
        -- Min: 0.00 Max: 100.00 Default: 0.03
        StrategistBackpack = 0.025,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        RangerBackpack = 0.0125,
        -- Min: 0.00 Max: 100.00 Default: 0.00
        ColossusBackpack = 2.5E-4,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        EchoBackpack = 0.0125,
        EmptyLine5 = false,
        Category5 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.03
        StormPackSmall = 0.03,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        StormPackMedium = 0.015,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        StormPackLarge = 0.005,
        EmptyLine6 = false,
        Category6 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.03
        PouchesSmall = 0.03,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        PouchesMedium = 0.015,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        PouchesLarge = 0.005,
        EmptyLine7 = false,
        Category7 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.03
        HipBagSmall = 0.03,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        HipBagMedium = 0.015,
        EmptyLine8 = false,
        Category8 = false,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        HolsterSheath = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        HeadApparel = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        Balaclava = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Jacket = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        Gloves = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        MilitaryTShirts = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.02
        PantsShorts = 0.02,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        BootsShoes = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.04
        ThermalUnderwear = 0.04,
        -- Min: 0.00 Max: 100.00 Default: 0.01
        NonMilitary = 0.01,
    },
    Text = {
        DividerMusicNew = true,
        DividerDancingNew = true,
        DividerMeditationNew = true,
        DividerHygiene = true,
        DividerArt = true,
        LSDividerOther = false,
        DividerDebug = false,
    },
    LSAmbt = {
        Toggle = true,
        -- Min: 1 Max: 1000 Default: 36
        Cooldown = 36,
        -- Min: 1 Max: 100 Default: 1
        MaxInProgress = 1,
        -- Min: 1 Max: 100 Default: 3
        MaxTotal = 3,
        ResetException = false,
        HideTips = false,
    },
    Music = {
        StrengthMultiplier = 2,
        ListeningStrengthMultiplier = 2,
        LearningChance = 3,
        Metabolics = 1,
    },
    Dancing = {
        StrengthMultiplier = 2,
    },
    Meditation = {
        StrengthMultiplier = 2,
        MindfulnessDuration = 2,
        -- Min: 0.00 Max: 10.00 Default: 2.00
        HealFactor = 2.0,
        EffectMultiplier = 2,
        KeepBags = true,
    },
    LSMeditation = {
        RemoveLevitation = false,
    },
    Yoga = {
        StrengthMultiplier = 2,
        Exhaustion = 3,
        Embarrassment = 2,
        AidObjects = true,
        RequiresMat = false,
        KeepBags = true,
        FailChance = 4,
        -- Min: 0.10 Max: 5.00 Default: 1.00
        YogaXPMultiplier = 1.0,
        -- Min: 0.10 Max: 5.00 Default: 1.00
        FitnessXPMultiplier = 1.0,
        -- Min: 0.10 Max: 5.00 Default: 1.00
        NimbleXPMultiplier = 1.0,
    },
    LSHygiene = {
        -- Min: 0.00 Max: 3.00 Default: 1.00
        HygieneNeedMultiplier = 1.0,
        -- Min: 0.00 Max: 3.00 Default: 1.00
        BladderNeedMultiplier = 1.0,
        HygieneNeedExpectationTime = 4,
        CleansMakeup = true,
        NotEmbarrassed = true,
        ColdSeverity = 1,
        -- Min: 0.00 Max: 3.00 Default: 0.00
        ColdChanceMultiplier = 0.0,
        CleaningExpectationTime = 4,
        CleaningLitterChance = 1,
    },
    LSArt = {
        BeautyOutdoors = false,
        BeautyShowNegative = false,
        BeautyNeedDecayRate = 1,
        BeautyNeedStrength = 1,
        -- Min: 0.10 Max: 4.00 Default: 1.00
        ArtworkBeautyMultiplier = 1.0,
    },
    LS = {
        DynamicTraits = false,
        DynamicTraitsReverse = 1,
        DividerServer = false,
        ModdataUpdate = 1,
        MoodUpdate = 1,
    },
    LSComfort = {
        -- Min: 0.00 Max: 3.00 Default: 1.00
        ComfortNeedMultiplier = 1.0,
        ComfortPositive = false,
    },
    Debug = {
        MoodlePriority = false,
        Expressions = false,
        DanceAnim = false,
        LSVerbose = false,
    },
    ProjectArcade = {
        DisableDefaultPrizePool = false,
        ReplaceVanillaArcadesOnLoad = false,
        ReplaceVanillaPinballsOnLoad = false,
        -- Min: 0 Max: 100 Default: 100
        SfxVolumePct = 100,
        AnnouncementLanguage = 1,
    },
    SOTO = {
        AddFitXPWhileRun = true,
        AgilityTraitsObtainable = true,
        CombatTraitsObtainable = true,
        SurvTraitsObtainable = false,
        CraftTraitsObtainable = false,
        FirearmTraitsObtainable = true,
        CowardlyRemovable = true,
        -- Min: 1 Max: 100000 Default: 168
        CowardlyHoursToRemoveMin = 168,
        -- Min: 1 Max: 100000 Default: 336
        CowardlyHoursToRemoveMax = 336,
        -- Min: 1 Max: 100000 Default: 1250
        CowardlyZombiesKilledToRemoveMin = 1250,
        -- Min: 1 Max: 100000 Default: 2500
        CowardlyZombiesKilledToRemoveMax = 2500,
        BraveEarnable = true,
        -- Min: 1 Max: 100000 Default: 504
        BraveHoursToEarnMin = 504,
        -- Min: 1 Max: 100000 Default: 840
        BraveHoursToEarnMax = 840,
        -- Min: 1 Max: 100000 Default: 3000
        BraveZombiesKilledToEarnMin = 3000,
        -- Min: 1 Max: 100000 Default: 4500
        BraveZombiesKilledToEarnMax = 4500,
        DesensitizedEarnable = true,
        -- Min: 1 Max: 100000 Default: 1176
        DesensitizedHoursToEarnMin = 1176,
        -- Min: 1 Max: 100000 Default: 1512
        DesensitizedHoursToEarnMax = 1512,
        -- Min: 1 Max: 100000 Default: 6000
        DesensitizedZombiesKilledToEarnMin = 6000,
        -- Min: 1 Max: 100000 Default: 9000
        DesensitizedZombiesKilledToEarnMax = 9000,
        PacifistRemovable = true,
        -- Min: 1 Max: 100000 Default: 672
        PacifistHoursToRemoveMin = 672,
        -- Min: 1 Max: 100000 Default: 1008
        PacifistHoursToRemoveMax = 1008,
        -- Min: 1 Max: 100000 Default: 1500
        PacifistZombiesKilledToRemoveMin = 1500,
        -- Min: 1 Max: 100000 Default: 2500
        PacifistZombiesKilledToRemoveMax = 2500,
        -- Min: 0 Max: 10 Default: 7
        PacifistSkillLvlToRemove = 7,
        SmokerRemovable = true,
        -- Min: 1 Max: 100000 Default: 672
        SmokerHoursToRemoveMin = 672,
        -- Min: 1 Max: 100000 Default: 768
        SmokerHoursToRemoveMax = 768,
        AlcoholicRemovable = true,
        -- Min: 1 Max: 100000 Default: 1032
        AlcoholicHoursToRemoveMin = 1032,
        -- Min: 1 Max: 100000 Default: 1128
        AlcoholicHoursToRemoveMax = 1128,
        SundayDriverRemovable = true,
        -- Min: 1 Max: 100000 Default: 60
        SundayDriverHoursToRemoveMin = 60,
        -- Min: 1 Max: 100000 Default: 80
        SundayDriverHoursToRemoveMax = 80,
        AllThumbsRemovable = true,
        -- Min: 1 Max: 100000 Default: 37500
        AllThumbsValueToRemove = 37500,
        DisorganizedRemovable = true,
        -- Min: 1 Max: 100000 Default: 37500
        DisorganizedValueToRemove = 37500,
        GracefulEarnable = true,
        ClumsyRemovable = true,
        InconspicuousEarnable = true,
        ConspicuousRemovable = true,
    },
    SkillRecoveryJournal = {
        -- Min: 1 Max: 100 Default: 100
        RecoveryPercentage = 100,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        TranscribeSpeed = 1.0,
        -- Min: 0.00 Max: 1000.00 Default: 1.00
        ReadTimeSpeed = 1.0,
        RecoverProfessionAndTraitsBonuses = false,
        TranscribeTVXP = false,
        -- Min: -1 Max: 100 Default: 0
        RecoverPassiveSkills = 0,
        -- Min: -1 Max: 100 Default: -1
        RecoverPhysicalCategorySkills = -1,
        -- Min: -1 Max: 100 Default: -1
        RecoverCombatSkills = -1,
        -- Min: -1 Max: 100 Default: -1
        RecoverFirearmSkills = -1,
        -- Min: -1 Max: 100 Default: -1
        RecoverCraftingSkills = -1,
        -- Min: -1 Max: 100 Default: -1
        RecoverSurvivalistSkills = -1,
        -- Min: -1 Max: 100 Default: -1
        RecoverFarmingCategorySkills = -1,
        -- Min: -1 Max: 100 Default: 0
        KillsTrack = 0,
        RecoverRecipes = true,
        RecoveryJournalUsed = false,
        SecurityFeatures = 1,
        CraftRecipeNeedLearn = false,
        CraftRecipe = "",
        ModDataTrack = "",
    },
    TikitownPower = {
        -- Min: -1.00 Max: 10.00 Default: 2.00
        DailyDegradeChance = 2.0,
        -- Min: 0.00 Max: 5.00 Default: 1.10
        RunningWearMultiplier = 1.1,
        PartsCanBeDestroyed = true,
    },
    TrueMusicRadio = {
        TMRRadiosAttractZombies = false,
        TMRTerminalEjectsMusic = true,
        TMRMusicTerminalFilledAmount = 5,
        TMRExcludeThemeSongs = true,
        TMRExcludeTCCacheMPSongs = true,
        TMRExcludeHolidaySongs = true,
        TMRRadioWeatherBroadcast = true,
        TMRRadioSongAnnouncements = true,
        TMRRadioHordeNightBroadcast = true,
        TMRRadioMoods = true,
        -- Min: 88000 Max: 108000 Default: 92000
        TMRChannel1 = 92000,
        -- Min: 88000 Max: 108000 Default: 92200
        TMRChannel2 = 92200,
        -- Min: 88000 Max: 108000 Default: 92400
        TMRChannel3 = 92400,
        -- Min: 88000 Max: 108000 Default: 92600
        TMRChannel4 = 92600,
        -- Min: 88000 Max: 108000 Default: 92800
        TMRChannel5 = 92800,
        ActivateTMRMTV = true,
        -- Min: 200 Max: 220 Default: 211
        TMRMTV = 211,
        TMRAllowSkipOnServer = false,
    },
    UnseasonalWeather = {
        Enabled = true,
        -- Min: 0 Max: 100 Default: 25
        DailyEventChance = 25,
        -- Min: 1 Max: 48 Default: 3
        MinDuration = 3,
        -- Min: 1 Max: 72 Default: 8
        MaxDuration = 8,
        -- Min: 0.20 Max: 3.00 Default: 1.00
        IntensityMultiplier = 1.0,
        HardcoreWinterTemps = false,
        HardcoreSummerTemps = false,
        EnhancedRainExposure = true,
        LightningAttractsZombiesGlobal = false,
    },
    UW_RadioForecasting = {
        Enabled = true,
        UseNightWindow = false,
        WalkieHints = true,
        DebugLogging = false,
    },
}
