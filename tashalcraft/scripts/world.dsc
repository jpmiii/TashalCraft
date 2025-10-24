
Script_Events:
    type: world
    debug: true
    events:
        on player quit:

        - define npcc <player.flag[unpcid]>
        - if <[npcc].is_npc> :
            - spawn <[npcc]> <player.location>
            - inventory copy d:<[npcc].inventory> o:<player.inventory>
            #- equip <[npcc]> head:<player.equipment_map.get[helmet]> chest:<player.equipment_map.get[chestplate]> legs:<player.equipment_map.get[leggings]> boots:<player.equipment_map.get[boots]>
            - flag <[npcc]> food:<player.food_level>
            - wait 5t
            - despawn <[npcc]>
            - wait 10t
            - spawn <[npcc]> <player.location>
            - wait 10t
            - flag <[npcc]> equip:<[npcc].equipment>


        # - else :

        #     - execute as_server "npc sel 0"
        #     - execute as_server "npc copy --name <player.name>"
        #     - wait 1t
        #     - execute as_server "npc sel <player.name>"
        #     - execute as_server "npc id"
        #     - flag <player> unpcid:<server.selected_npc>
        #     - log "created npc <player.name> logout" file:npc.log
        #     - define npcc <server.selected_npc>
        #     - teleport <[npcc]> <player.location>
        #     - inventory copy d:<[npcc].inventory> o:<player.inventory>
            #- equip <[npcc]> head:<player.equipment_map.get[helmet]> chest:<player.equipment_map.get[chestplate]> legs:<player.equipment_map.get[leggings]> boots:<player.equipment_map.get[boots]>

        on player first login:

                - execute as_server "npc sel 0"
                - execute as_server "npc copy --name <player.name>"
                - wait 1t
                - execute as_server "npc sel <player.name>"
                - execute as_server "npc id"
                - flag <player> unpcid:<server.selected_npc>
                - flag <server.selected_npc> uplayerid:<player>
                - execute as_server "npc despawn"
                - log "created npc <player.name> first join" file:npc.log
                - inventory clear d:<player.inventory>
                #- teleport <player> l@38,77,-103,spawn

        on player join:
        - define jnpc <player.flag[unpcid]>
        - if !<player.has_flag[unpcid]> :
            - define jnpc npc[<player.name>]
        - if <[jnpc].is_spawned> :
            - teleport <player> <[jnpc].location>
            - inventory copy d:<player.inventory> o:<[jnpc].inventory>
            - inventory clear d:<[jnpc].inventory>
            - despawn <[jnpc]>
        - if <player.has_flag[killed]> :
            - inventory clear d:<player.inventory>
            - teleport <player> <player.flag[killed]>
            - flag <player> killed:!
            - narrate "you were killed by <[jnpc].flag[killed]>"
        - flag <[jnpc]> killed:NULL
        - adjust server save_citizens
        - adjust server save
        - run ClearCheckNPC_task def:<[jnpc]>
        - ~discordmessage id:mybot channel:<discord[mybot].group[Capitum].channel[denizen]>  "Player <player.name> joined"

        - wait 60t
        - despawn <[jnpc]>


        on player chats:
        - ~discordmessage id:mybot channel:<discord[mybot].group[Capitum].channel[denizen]> "<player.name> <context.message>"
        #"<player.name> <context.message>"
        on npc targets:
        - ~discordmessage id:mybot channel:<discord[mybot].group[Capitum].channel[denizen]>  "<context.entity.name> <context.reason> <context.target.name>"
        #597809297124098048

        on npc damaged:
        - flag npc equip:<npc.equipment>
        - flag npc equip:->:<npc.item_in_offhand>

        #- announce ouch
        on player dies:
        - adjust <player> bed_spawn_location:<player.location>
        - flag player killed:<player.location>
        - flag <npc[<player.flag[unpcid]>]> killed:<context.damager.name>

        after player respawns:
        - if <player.has_flag[killed]> :
            - teleport <player> <player.flag[killed]>
            - flag player killed:NULL
            - flag player killed:!

        on npc dies:


        - foreach <npc.inventory.list_contents>:
            - drop <[value]> <context.entity.location>
        - foreach <npc.flag[equip]>:
            - drop <[value]> <context.entity.location>

        - flag <npc.flag[uplayerid]> killed:<context.entity.location>
        - flag <context.entity> killed:<context.damager.name>
        - wait 3t
        - inventory clear d:<npc.inventory>
        #- equip <npc> head:i@air chest:i@air legs:i@air boots:i@air
        # - equip <player> head:i@air chest:i@air legs:i@air boots:i@air 
        - despawn <context.entity>
        - if <npc.has_flag[disc]>:
            - ~discordmessage id:mybot channel:<npc.flag[disc]> "<npc.name> killed by <context.damager.name>"
Start_Events:
    type: world
    debug: false
    events:

        on server start:
        - flag server long_loop:0
        - flag server turn_loop:0
        - flag server turn_time:10t

        - ~discordconnect id:mybot tokenfile:data/discord_token.txt
        - wait 5s
        - foreach <server.npcs> :
            - run ClearCheckNPC_task instantly def:<[value]>
            - if <[value].has_flag[killed]> :
                - despawn <[value]>
            - else :
                - if !<[value].is_spawned> :
                    - chunkload <[value].location.chunk>
                    - spawn <[value]> <[value].location>
        - repeat 100000000 :
            - if !<server.has_flag[turn_time]> :
                - repeat stop
            - wait <server.flag[turn_time]>
            #- announce <world[world].spawned_npcs.get[<server.flag[turn_loop]>]>
            - flag server turn_loop:++
            - if <server.flag[turn_loop].is[MORE].than[<world[world].spawned_npcs.size>]> :
                - flag server turn_loop:1
            - run Inner_loop instantly def:<world[world].spawned_npcs.get[<server.flag[turn_loop]>]>
Burn_events:
    type: world
    debug: false
    events:
        after block smelts item:
        - if !<server.has_flag[burnevent]> :
            - if <context.location.add[<location[-1,0,0,world]>].material.name.is[==].to[hopper]> :
                - if <context.location.add[<location[0,-1,0,world]>].material.name.is[==].to[hopper]> && <context.location.add[<location[0,1,0,world]>].material.name.is[==].to[hopper]> :
                    - if <context.location.add[<location[0,1,0,world]>].inventory.contains_item[cobblestone].quantity[64]> :
                        - if <context.location.add[<location[-1,0,0,world]>].inventory.contains_item[lava_bucket]> :
                            - take item:cobblestone quantity:64 from:<context.location.add[<location[0,1,0,world]>].inventory>
                            - take item:lava_bucket from:<context.location.add[<location[-1,0,0,world]>].inventory>
                            - give item:stone quantity:64 to:<context.location.add[<location[0,-1,0,world]>].inventory>
                            - give item:experience_bottle to:<context.location.add[<location[0,-1,0,world]>].inventory>
                            - give item:bucket to:<context.location.add[<location[0,-1,0,world]>].inventory>
                            - flag server burnevent:true expire:60s
Block_break_events:
    type: world
    debug: false
    events:
        on player breaks block:
        - if <context.location.has_flag[reinforced]> :
            - if <context.location.flag[reinforced].is[LESS].than[1]> :
                - flag <context.location> reinforced:!
            - else :
                - flag <context.location> reinforced:-:1
                - determine passively cancelled

        - if <context.material.is[==].to[<material[stone]>]> :

            - if <util.random_decimal.is[OR_LESS].than[0.004]> && <player.location.y.is[LESS].than[17]>  && <player.item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]> || <player.item_in_hand.material.is[==].to[<material[iron_pickaxe]>]> :

                - give <item[diamond_ore]> to:<player.inventory>

                - narrate target:<player> "You found a diamond!"
            - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <player.location.biome.is[==].to[<biome[world,otg:a1.river]>]>  && <player.item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <player.item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <player.item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                - give <item[redstone_ore]> to:<player.inventory>

                - narrate target:<player> "Redstone"
            - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <player.location.biome.is[==].to[<biome[world,otg:a1.warm_ocean]>]>  && <player.item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <player.item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <player.item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                - give <item[lapis_ore]> to:<player.inventory>
                
                - narrate target:<player> "Lapis"
            - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <player.location.biome.is[==].to[<biome[world,otg:a1.wooded_mountains]>]>  && <player.item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <player.item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <player.item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                - give <item[gold_ore]> to:<player.inventory>
                
                - narrate target:<player> "Gold"
            - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <player.location.y.is[LESS].than[40]>  && <player.item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <player.item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <player.item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                - give <item[iron_ore]> to:<player.inventory>
                
                - narrate target:<player> "Iron"
#            - else :
#                - give <item[cobblestone]> to:<player.inventory>

Click_Events:
    type: world
    debug: false
    events:
        on player places stone_bricks flagged:!reinforce_off:
        - determine passively cancelled

        on player right clicks block:
        - if <player.item_in_hand.material.is[==].to[<material[stone_bricks]>]> && !<player.has_flag[reinforce_off]>:

            - flag <context.location> reinforced:+:<player.item_in_hand.quantity>

            - narrate "total reinforcement <context.location.flag[reinforced]>"
            - take iteminhand quantity:64
        - if <player.item_in_hand.material.is[==].to[<material[diamond_shovel]>]> :
            - if <context.location.has_flag[reinforced]> :
                - narrate "breaks left: <context.location.flag[reinforced]>"
        - if <player.item_in_hand.is[==].to[<item[arrow]>]> :

            - foreach <world[world].spawned_npcs> :
                - if <proc[cancommand].context[<[value]>|<player>]> :
                    - define l <player.cursor_on>
                    - if <[l].distance_squared[<[value].location>].is[LESS].than[400]> :
                        - walk <[value]> <[l]> speed:1.5
                        #- announce "walk arrow"
        after player left clicks block :
        - if <player.item_in_hand.material.is[==].to[<material[diamond_shovel]>]> :
            - if <context.location.material.is[==].to[<material[enchanting_table]>]>:
                - ratelimit <player> 5t
                - if <player.item_in_hand.has_display> :

                    - if <player.item_in_hand.display.is[==].to[Experience]> :
                        - if <player.item_in_hand.has_lore> :
                            - if <player.item_in_hand.lore.get[1].is_integer> || <player.item_in_hand.lore.get[1].is_decimal>:
                                - narrate <player.item_in_hand.lore.get[1]>
                                - experience set <player.item_in_hand.lore.get[1].add[<player.calculate_xp>]>
                                - take iteminhand
                - else :
                    - inventory adjust slot:hand "display:Experience"
                    - inventory adjust slot:hand "lore:<player.calculate_xp>"
                    - experience set 0



        on sentinel npc attacks:
        - flag <npc> hold:attack duration:10s
        - if <npc.has_flag[disc]> :
            - if <npc.has_flag[dis_timeout]> :
                - if <npc.flag[dis_timeout].is[LESS].than[<server.current_time_millis>]> :
                    # - discord id:597795975272202251 message "<npc.name> targeting <context.entity.name>" channel:<npc.flag[disc]>
                    - ~discordmessage id:mybot channel:<npc.flag[disc]> "<npc.name> targeting <context.entity.name>"
                    #- announce "<npc.name> <context.entity.name>"
                    - flag <npc> dis_timeout:<server.current_time_millis.add[60000]>

            - else :

                - ~discordmessage id:mybot channel:<npc.flag[disc]> "<npc.name> targeting <context.entity.name>"
                #597809297124098048 597809297124098048
                - flag <npc> dis_timeout:<server.current_time_millis.add[60000]>
Book_01:
    type: book
    title: How to Play
    author: The Game
    signed: true
    text:
    - Text Chat Commands
    - Commands NPCs can respond to when you look at them and are within range
    - report: shows current task and sentinel settings in chat
    - stop, stop build, stop follow, stop dig, stop path

    - follow: will cause a NPC to follow you

    - build <schematic>: builds schematic if the NPC has the right blocks

    - take: the NPC will take what is in your hand

    - swap: swaps inventory with NPC allowing you to equip armor and weapons

    - fill <block> <length> <width> <height>: fills an area with a block the NPC has in inventory

    - drop: the NPC will drop everything

    - dig <length> <width> <height>: digs an area, if you have the right pick and are at the right level and are breaking stone you the NPC will have a chance of finding ore

    - pathadd [<x> <y> <z>]: will add the NPC’s current location [or the x,y,z location] to the path list

    - pathclear: clear path list

    - pathgo: start walking the path list

    - hiring you: hires an NPC for an amount of time depending on the bread in hand

    - chest: drops a chest at the feet of the NPC with the top inventory in it

    - read: uses books to automate tasks

    - harvest: if the NPC is standing on a full grow wheat it will get 2 wheat and leave new plant
    - Server Commands:

    - usage: /move
    - description: move spawned npcs within 50 blocks to look at point

    - description: adds a boss to the list of players that can give your NPC commands.
    - usage: /setboss <player name>

    - description: schematic required materials
    - usage: /sch <schematic name>

    - description: adds player location to npc path list
    - usage: /pathadd

    - usage: /pathclear
    - description: clears path list

    - usage: /pathgo
    - description: starts npc walking path

    - usage: /clearnpc
    - description: clears all flags for players npc

    - usage: /dig length width height (length width height/player location)
    - description: sets plates npc to dig

    - usage: /npcfill
    - description: wip

    - usage: /build schematic
    - description: wip

    - usage: /npcaddtarget
    - description: wip

    - usage: /npcremovetarget
    - description: wip

    - usage: /npcaddignore
    - description: wip

    - usage: /npcremoveignore
    - description: wip

    - usage: /disc
    - description: set discord output channel for player

    - usage: /books
    - description: gives player books

    - usage: /read
    - description: reads first book

Dig_book:
    type: book
    title: Dig.exe
    author: The Game
    signed: true
    text:
    - origen_npc
    - dig,25,3,3
    - chest
    - origen_add,24,0,0
    - loop,1
Farm_book:
    type: book
    title: Farm.exe
    author: The Game
    signed: true
    text:
    - origen_npc
    - walk
    - harvest
    - origen_add,1,0,0
    - walk
    - loop,2,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,-1,0,0
    - walk
    - loop,8,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,1,0,0
    - walk
    - loop,14,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,-1,0,0
    - walk
    - loop,20,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,1,0,0
    - walk
    - loop,26,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,-1,0,0
    - walk
    - loop,32,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,1,0,0
    - walk
    - loop,38,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,-1,0,0
    - walk
    - loop,44,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,1,0,0
    - walk
    - loop,50,14
    - origen_add,0,0,1
    - walk
    - harvest
    - origen_add,-1,0,0
    - walk
    - loop,56,14



Recipe_arrows:
    type: item
    material: arrow
    recipes:
        1:
            type: shaped
            output_quantity: 16
            input:
            - air|iron_ingot|air
            - air|stick|air
            - air|feather|air
