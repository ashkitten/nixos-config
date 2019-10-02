-- luacheck: globals libroccat

-- globals

local devices = {}
local prev_win_class
local prev_lock

-- helpers

local function get_active_window_class()
    local command = string.format("xdotool getactivewindow 2>/dev/null")
    handle = io.popen(command)
    local win_id = handle:read("*l")
    handle:close()

    if win_id then
        command = string.format("xprop -id %s WM_CLASS 2>/dev/null", win_id)
        handle = io.popen(command)
        local result = handle:read("*l")
        handle:close()

        if result == nil then return false end
        return result:match('"([^"]-)"$')
    end
end

local function set_all_profiles(name, profile)
    if devices[name] == nil then
        print(string.format("Device does not exist: %s", name))
        return
    end
    for _, device in pairs(devices[name]) do
        if device.device:get_profile() ~= profile then
            device.device:set_profile(profile)
        end
    end
end

local function set_all_brightness(name, brightness)
    if devices[name] == nil then
        print(string.format("Device does not exist: %s", name))
        return
    end
    for _, device in pairs(devices[name]) do
        local profile = device.device:get_profile()
        if device.device:get_lights(profile).brightness ~= brightness then
            device.device:set_lights(profile, { brightness = brightness })
        end
    end
end

-- init

for _, device in ipairs(libroccat.find_devices()) do
    local name = device:name()

    if devices[name] == nil then
        devices[name] = {}
    end

    devices[name][#devices[name] + 1] = {
        device = device,
    }
end

-- event loop

while true do
    local win_class = get_active_window_class()

    if win_class ~= prev_win_class then
        prev_win_class = win_class

        if win_class == "kitty" then
            set_all_profiles("tyon", 2)
        elseif win_class == "ShellShockLive.x86_64" then
            set_all_profiles("tyon", 3)
        elseif win_class == "steam_app_39210" then
            set_all_profiles("tyon", 4)
        else
            set_all_profiles("tyon", 1)
        end
    end

    local lock_file = io.open(string.format("/tmp/lock_%s", os.getenv("USER")))
    local lock = false
    if lock_file ~= nil then
        lock_file:close()
        lock = true
    end

    if lock ~= prev_lock then
        prev_lock = lock

        if lock then
            set_all_profiles("tyon", 5)
        else
            set_all_profiles("tyon", 1)
        end
    end

    libroccat.sleep(500)
end
