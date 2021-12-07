Config = {}

Config.Player = {}
Config.Player.Character = {}

Config.Player.Character.Table = {
    ['index'] = { ['type'] = "number", ['default'] = 0 },
    ['cid'] = { ['type'] = "number", ['default'] = CreateNumber },
    ['phone'] = { ['type'] = "number", ['default'] = CreateNumber },
    ['firstname'] = { ['type'] = "string", ['default'] = "" },
    ['lastname'] = { ['type'] = "string", ['default'] = "" },
    ['job'] = { ['type'] = "string", ['default'] = "unemployed" },
    ['roles'] = { ['type'] = "table", ['default'] = {} },
    ['values'] = { ['type'] = "table", ['default'] = {} },
}

Config.Player.Character.Values = {
    ['wallet'] = { ['type'] = "number", ['default'] = 2000 },
    ['bank'] = { ['type'] = "number", ['default'] = 3000 },
}

Config.Player.Character.Menu = {
  ['ped'] = {
    ['start'] = vector4(-1044.188, -2749.034, 10.753623, 331.28002),
    ['end'] = vector4(-1038.816, -2739.806, 13.797128, 330.1156),
  },
  ['camera'] = {
    ['rotation'] = vector3(-10.0, 0.0, 150.0),
    ['start'] = vector3(-657.177, -1920.808, 163.85),
    ['end'] = vector3(-1037.405, -2737.367, 14.70)
  },
  ['plane'] = {
    ['pilot'] = `s_m_m_pilot_01`,
    ['model'] = `jet`,
    ['from'] = vector3(-1731.37, -2727.678, 117.66153),
    ['to'] = vector3(-1198.9, -3028.051, 14.587728),
    ['heading'] = 239.26959
  }
}

Config.Player.Character.Jobs = {
    ['unemployed'] = {
        ['label'] = "Unemployed",
        ['main'] = "none",
        ['roles'] = {
            ['none'] = { ['label'] = "Unemployed", ['paycheck'] = 100 },
        }
    },
    ['police'] = {
        ['label'] = "Police Department",
        ['main'] = "academic",
        ['roles'] = {
            ['academic'] = { ['label'] = "Academic", ['paycheck'] = 600 },
            ['officer'] = { ['label'] = "Officer", ['paycheck'] = 800 },
            ['senior'] = { ['label'] = "Senior Officer", ['paycheck'] = 800 },
            ['sergeant'] = { ['label'] = "Sergeant", ['paycheck'] = 1000 },
            ['commander'] = { ['label'] = "Commander", ['paycheck'] = 1500 },
        }
    }
}
