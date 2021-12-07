local ready = false
local player = nil
local camera = nil
local menuPed = nil
local menuPlane = nil
local menuPilot = nil
local ui = exports['th-ui']:CreateApp("Characters")

function LoadModel(model)
  RequestModel(model)
  while not HasModelLoaded(model) do
    Citizen.Wait(0)
  end
end

local function RemoveMenuPed()
  if menuPed then
    DeleteEntity(menuPed)
    menuPed = nil
  end
end

local function CreateMenuPed(x,y,z,h,model)
  RequestModel(model)
  while not HasModelLoaded(model) do
    Wait(100)
  end

  RemoveMenuPed()
  menuPed = CreatePed(4, model, x, y, z, h, false, false)

  return menuPed
end

local function CreatePlaneInSky()
  local skyData = Config.Player.Character.Menu['plane']

  if menuPlane then
    DeleteEntity(menuPlane)
  end

  LoadModel(skyData['model'])
  menuPlane = CreateVehicle(skyData['model'], skyData['from'], skyData['heading'], false, false)
  FreezeEntityPosition(menuPlane, true)
  LoadModel(skyData['pilot'])
  menuPilot = CreatePedInsideVehicle(menuPlane, 4, skyData['pilot'], -1, false, false)
end

local function TaskPlane()
  local skyData = Config.Player.Character.Menu['plane']

  if menuPlane then
    print(1)
    FreezeEntityPosition(menuPlane, false)
    Wait(200)
    TaskPlaneLand(menuPilot, menuPlane, skyData['from'].x, skyData['from'].y, skyData['from'].z, skyData['to'].x, skyData['to'].y, skyData['to'].z)
    SetPedKeepTask(menuPilot, true)
    Citizen.SetTimeout(15000, function()
      DeleteEntity(menuPlane)
      DeleteEntity(menuPilot)
      menuPlane = nil
      menuPilot = nil
    end)
  end
end

RegisterNetEvent("fx:player:character:menu")
AddEventHandler("fx:player:character:menu", function(characters)
  print("FF: " .. json.encode(characters))
    -- Hide Player
    local ped = PlayerPedId()
    SetEntityVisible(ped, false, 0)
    SetEntityCoords(ped, -1792.00122, -2882.29980, 13.9440)
    ClearFocus()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    SetWeatherTypeOverTime("EXTRASUNNY", 15.0)

    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist("EXTRASUNNY")
    SetWeatherTypeNow("EXTRASUNNY")
    SetWeatherTypeNowPersist("EXTRASUNNY")
    SetRainLevel(0)
    NetworkOverrideClockTime(0, 0, 0)
    SetForceVehicleTrails(false)
    SetForcePedFootstepsTracks(false)
    SetCloudHatOpacity(0.0)

    CreatePlaneInSky()
    TaskPlane()

    Wait(1500)
    local camTo = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Player.Character.Menu['camera']['end'], Config.Player.Character.Menu['camera']['rotation'], 60.00, false, 0)

    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.Player.Character.Menu['camera']['start'], Config.Player.Character.Menu['camera']['rotation'], 60.00, false, 0)
    SetCamActiveWithInterp(camTo, camera, 9500, true, true)
    RenderScriptCams(true, false, 1, true, true)

    local pedCoords = Config.Player.Character.Menu['ped']['start']
    CreateMenuPed(pedCoords.x,pedCoords.y,pedCoords.z,pedCoords[4],`mp_m_freemode_01`)

    DoScreenFadeIn(500)
    while IsScreenFadingIn() do
      Wait(10)
    end

    pedCoords = Config.Player.Character.Menu['ped']['end']

    local pedUp = false
    while true do
      local camCoords = GetCamCoord(camTo)
      local dist = Vdist(camCoords, GetEntityCoords(menuPed))
      SetFocusPosAndVel(camCoords, 0.0, 0.0, 0.0)
      if dist < 800 then
        if not pedUp then
          print("[Characters] Ped come up!")
          TaskPedSlideToCoord(menuPed, pedCoords.x,pedCoords.y,pedCoords.z,pedCoords[4], 10.0)
          pedUp = true
        end

        if dist < 50 then
          break
        end
      end

      Wait(500)
    end

    print("[Characters] Focus reseted")
    SetFocusPosAndVel(pedCoords, 0.0, 0.0, 0.0)
    ui:setState(true)
    ui:setFocus(true, false)
end)

local pending = false
RegisterNetEvent("fx:ui:emit:characters:action")
AddEventHandler("fx:ui:emit:characters:action", function(action, callback)
  if pending then
    print("[Characters] You already have a pending action.")
  end

  pending = true
end)

RegisterNetEvent("fx:player:resetStats")
AddEventHandler("fx:player:resetStats", function()
  ClearFocus()
  DisplayRadar(false)
end)

RegisterNetEvent("fx:player:character:update")
AddEventHandler("fx:player:character:update", function(key, value)
    if player then
        player[key] = value
    end
end)

RegisterNetEvent("fx:player:character:load")
AddEventHandler("fx:player:character:load", function(data)
    player = data
end)

RegisterNetEvent("fx:player:character:unload")
AddEventHandler("fx:player:character:unload", function()
    player = nil
end)

RegisterNetEvent("fx:player:exports:request")
AddEventHandler("fx:player:exports:request", function(callback)
    CreateThread(function()
        local cb = callback

        while not ready do
            Wait(200)
        end

        callback()
    end)
end)

CreateThread(function()
    TriggerEvent("fx:player:resetStats")
    DoScreenFadeOut(0)

    while true do
        Wait(500)
        if exports and exports['th-player'] and NetworkIsPlayerActive(PlayerId()) then
            ready = true
            TriggerEvent("fx:player:exports:ready")
            break
        end
    end

    TriggerServerEvent("fx:player:init")
end)
