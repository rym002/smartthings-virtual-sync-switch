# Virtual Sync Switch

## A virtual Smartthings switch used to enable bidirectional sync with a target device

## Why do I need this?
If a target device has multiple components, the assistants only update the main component. Creating a virtual device and rules will allow the assistant to press the switch keep the virtual device in sync with the target. If the target device is updated the virtual will update to match using [Rules](https://developer-preview.smartthings.com/docs/automations/rules)

### How it works:
* When main component is clicked it will emit an event to remote.
* When remote component is clicked it will emit an event to main.

## Setup:
## Create a rule with the following actions. It's important to use "changes" to only trigger on change
1. If remote changes on then set the target device on
1. If remote changes off then set the target device off
1. If target device changes on then set remote on (this will actually update main to on)
1. If target device changes off then set remote on (this will actually update main to off)

## What happens?
### When the target device is switched on/off it will:
1. Emit a switch event on the target
1. Trigger rule 3 or 4 to switch remote on/off
1. Remote will emit a switch event to the main component
1. Main will now match the target device

### When main is switched on/off it will:
1. Main emits a switch event to the remote component
2. Rule 1 or 2 will trigger causing the target device to switch on/off to match remote
3. Rule 2 or 3 will trigger when the target device emits its switch event to update remote
4. Remote will emit a switch event to the main component 

# Installation
Accept the [Invite](https://bestow-regional.api.smartthings.com/invite/oDM83DZX01jL) to install the device. See [Developer Docs](https://developer-preview.smartthings.com/docs/devices/hub-connected/enroll-in-a-shared-channel/) for more information about invitations.

# Sample Rule
```json
{
  "name":"Sync Rule",
  "actions":[
    {
      "if":{
        "changes":{
          "equals":{
            "left":{
              "device":{
                "devices":[
                  "<target device id>"
                  ],
                "component":"<target device component>",
                "capability":"switch",
                "attribute":"switch"
              }
            },
            "right":{
              "string":"on"
            }
          }
        },
        "then":[
          {
            "command":{
              "devices":[
                "<virtual switch device id>"
                ],
              "commands":[
                {
                  "component":"remote",
                  "capability":"switch",
                  "command":"on",
                  "arguments":[
                  ]
                }]
            }
          }]
      }
    },
    {
      "if":{
        "changes":{
          "equals":{
            "left":{
              "device":{
                "devices":[
                  "<target device id>"
                  ],
                "component":"<target device component>",
                "capability":"switch",
                "attribute":"switch"
              }
            },
            "right":{
              "string":"off"
            }
          }
        },
        "then":[
          {
            "command":{
              "devices":[
                "<virtual switch device id>"
                ],
              "commands":[
                {
                  "component":"remote",
                  "capability":"switch",
                  "command":"off",
                  "arguments":[
                  ]
                }]
            }
          }]
      }
    },
    {
      "if":{
        "changes":{
          "equals":{
            "left":{
              "device":{
                "devices":[
                  "<virtual switch device id>"
                  ],
                "component":"remote",
                "capability":"switch",
                "attribute":"switch"
              }
            },
            "right":{
              "string":"on"
            }
          }
        },
        "then":[
          {
            "command":{
              "devices":[
                "<target device id>"
                ],
              "commands":[
                {
                  "component":"<target device component>",
                  "capability":"switch",
                  "command":"on",
                  "arguments":[
                  ]
                }]
            }
          }]
      }
    },
    {
      "if":{
        "changes":{
          "equals":{
            "left":{
              "device":{
                "devices":[
                  "<virtual switch device id>"
                  ],
                "component":"remote",
                "capability":"switch",
                "attribute":"switch"
              }
            },
            "right":{
              "string":"off"
            }
          }
        },
        "then":[
          {
            "command":{
              "devices":[
                "<target device id>"
                ],
              "commands":[
                {
                  "component":"<target device component>",
                  "capability":"switch",
                  "command":"off",
                  "arguments":[
                  ]
                }]
            }
          }]
      }
    }]
}
```