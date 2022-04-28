local capabilities = require "st.capabilities"
local Driver = require "st.driver"
local log = require "log"
local socket = require "cosock.socket"

local initialized = false

local createdev_cap = [[
{
    "id": "partyvoice23922.createanother",
    "version": 1,
    "status": "proposed",
    "name": "createanother",
    "attributes": {},
    "commands": {
        "push": {
            "name": "push",
            "arguments": []
        }
    }
}
]]
local cap_createdev = capabilities.build_cap_from_json_string(createdev_cap)
capabilities["partyvoice23922.createanother"] = cap_createdev

local function handle_discovery(driver, _should_continue)
    if not initialized then
        local metadata = {
            type = "LAN",
            device_network_id = "virtual-sync",
            label = "Virtual Sync Switch Creator",
            profile = "sync-creator",
            manufacturer = "rym002",
            model = "v1",
            vendor_provided_label = nil
        }

        driver:try_create_device(metadata)
    end
end

local function device_added(driver, device)
    device:online()
    initialized = true
end

local function device_init(driver, device)
    local remote = device.profile.components['remote']
    if remote~=nil then
    device:emit_component_event(device.profile.components.main, capabilities.switch.switch.off())
    device:emit_component_event(device.profile.components.remote, capabilities.switch.switch.off())
    end
end

local function switch_event(device, command, event)
    local componentName = 'main'
    if command.component == 'main' then
        componentName = 'remote'
    end
    local destComponent = device.profile.components[componentName]
    log.debug("Sending command to: " .. componentName)
    device:emit_component_event(destComponent, event)
end

local function switch_on(driver, device, command)
    switch_event(device, command, capabilities.switch.switch.on())
end

local function switch_off(driver, device, command)
    switch_event(device, command, capabilities.switch.switch.off())
end

local function create_device(driver)
    log.debug('Creating sub dev')
    local create_device_msg = {
        type = "LAN",
        device_network_id = 'sync_switch_' .. socket.gettime(),
        label = "Virtual Sync Switch",
        profile = 'sync-switch',
        manufacturer = 'rym002',
        model = 'Sync Switch',
        vendor_provided_label = nil
    }

    assert(driver:try_create_device(create_device_msg), "failed to create device")

end

local function handle_createdev(driver, device, command)
    create_device(driver)
end

local function device_removed(driver, device)
    if device.network_id == "virtual-sync" then
        initialized = false
    end
end
local driver = Driver("Virtual Sync Switch", {
    discovery = handle_discovery,
    lifecycle_handlers = {
        added = device_added,
        init = device_init,
        removed = device_removed
    },
    capability_handlers = {
        [capabilities.switch.ID] = {
            [capabilities.switch.commands.on.NAME] = switch_on,
            [capabilities.switch.commands.off.NAME] = switch_off
        },
        [cap_createdev.ID] = {
            [cap_createdev.commands.push.NAME] = handle_createdev
        }
    }
})

driver:run()
