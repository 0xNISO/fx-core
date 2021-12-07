local ready = false

function CreatePlayer(id, characters)
    local this = {}
    this.id = id
    this.characters = characters
    this.ids = GetPlayerIDs(id)
    this.character = false

    this.update = function(self, key, value)
        TriggerClientEvent("fx:player:character:update", self.id, key, value)
    end

    this.switch = function(self, index)
        if self.characters[index] and self.character ~= index then
            if self.character then
                TriggerClientEvent("fx:player:character:unload", self.id)
            end

            self.character = self.characters[index]

            for k,v in pairs(self.character) do
                self:update(k,v)
            end

            TriggerClientEvent("fx:player:character:load", self.id, self.character)
        end
    end

    this.getChracter = function(self)
        return self.chracter
    end

    this.removeFromWallet = function(self, amount)
        if self.character and type(amount) == "number" and amount > 0 then
            local wallet = self.character.values['wallet']-amount
            if wallet >= 0 then
                self.character.values['wallet'] = wallet
                self:update("values", self.character.values)
                return true
            end
        end

        return false
    end

    this.addToWallet = function(self, amount)
        if self.character and type(amount) == "number" and amount > 0 then
            self.character.values['wallet'] = self.character.values['wallet']+amount
            self:update("values", self.character.values)
            return true
        end

        return false
    end

    this.setWallet = function(self, amount)
        if self.character and type(amount) == "number" then
            local wallet = self.character.values['wallet']
            if wallet > amount then
                return self:removeFromWallet(wallet-amount)
            else
                return self:addToWallet(amount-wallet)
            end
        end

        return false
    end

    this.setJob = function(self, jobName)
        local jobData = Config.Player.Character.Jobs[jobName]

        if self.character and jobData then
            self.character['job'] = jobName
            self.character['roles'] = {jobData['main']}
            self:update("job", jobName)
            self:update("roles", self.character['roles'])
            return true
        end

        return nil
    end

    this.removeRole = function(self, roleName)
        if self.character and self.hasRole(roleName) then
            self.character['roles'][roleName] = nil
            self:update("roles", self.character['roles'])
            return true
        end

        return false
    end

    this.addRole = function(self, roleName)
        local roleData = Config.Player.Character.Jobs[self.character.job]['roles'][roleName]
        if self.character and roleData and not self.hasRole(roleName) then
            self.character['roles'][roleName] = roleData
            self:update("roles", self.character['roles'])
            return true
        end

        return false
    end

    this.hasRole = function(self, roleName)
        if self.character then
            return self.character['roles'][roleName] == true
        end

        return false
    end

    this.getRoles = function(self)
        if self.character then
            return self.character['roles']
        end

        return {}
    end

    this.getValue = function(self, key)
        if self.character then
            return self.character.values[key]
        end

        return nil
    end

    this.setValue = function(self, key, value)
        local valueData = Config.Player.Character.Values[key]

        if key == "wallet" then
            return self:setWallet(value)
        end

        if self.character and valueData and type(value) == valueData['type'] then
            self.character.values[key] = value
            self:update("values", self.character.values)
            return true
        end

        return nil
    end

    -- TODO: spawn
end

RegisterNetEvent("fx:player:init")
AddEventHandler("fx:player:init", function()
    local src = source
    local discord = 589 --GetPlayerID(src, "discord")
    local query = ("SELECT * FROM `characters` WHERE `discord` = @discord"):sql({ ['discord'] = discord })
    local characters = {}

    for i=1, #query do
        local character = table.rebuild(query[i], Config.Player.Character.Table)
        character.values = table.rebuild(character.values, Config.Player.Character.Values)
        characters[i] = character
    end

    TriggerClientEvent("fx:player:character:menu", src, characters)
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
    while not ready do
        Wait(500)
        if exports and exports['th-player'] then
            ready = true
            TriggerEvent("fx:player:exports:ready")
        end
    end
end)
