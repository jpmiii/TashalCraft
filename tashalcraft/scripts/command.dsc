Command_move:
    type: command
    name: move
    usage: /move
    description: move spawned npcs within 50 blocks to look at point
    script:
        - if !<player.is_op> :
            - narrate "<red>You do not have permission for that command."
            - stop

        - foreach <world[world].spawned_npcs> :
            - define l <player.cursor_on>

            - if <[l].distance_squared[<[value].location>].is[LESS].than[2500]> :
                - define rndx <util.random.int[1].to[3].add_int[-2]>
                - define rndz <util.random.int[1].to[3].add_int[-2]>
                - walk <[value]> <[l].add[<[rndx]>,0,<[rndz]>]> speed:2.5

Command_setboss:
    type: command
    name: setboss
    description: adds a boss to the list
    usage: /setboss player name
    script:
        - define n1 <player.flag[unpcid]>
        - flag <[n1]> commander:->:<context.args.get[1]>
        - narrate "boss is <[n1].flag[commander]>"
Command_schem:
    type: command
    name: sch
    description: schematic required materials
    usage: /sch schematic name
    debug: false
    script:
        - define outto <list[<material[air]>]>
        - define count2 <list[0]>
        - if !<schematic[<context.args.get[1]>].exists> :
            - schematic load name:<context.args.get[1]>
        - else :
            - narrate "Schematic not found"


        - repeat <schematic[<context.args.get[1]>].length> as:len :
            - repeat <schematic[<context.args.get[1]>].width> as:wid :
                - repeat <schematic[<context.args.get[1]>].height> as:h :
                    - define loc1 <location[<[wid].add[-1]>,<[h].add[-1]>,<[len].add[-1]>,world]>
                    - define bloc <schematic[<context.args.get[1]>].block[<[loc1]>]>

                    - if <[outto].find[<[bloc]>].is[MORE].than[-1]> :
                        - define tt <[count2].get[<[outto].find[<[bloc]>]>].add[1]>

                        - define count2 <[count2].set[<[tt]>].at[<[outto].find[<[bloc]>]>]>

                    - if <[outto].find[<[bloc]>].is[==].to[-1]> :
                        - define outto <[outto].include[<[bloc]>]>
                        - define count2 <[count2].include[1]>



        - foreach <[outto]> :
            - narrate "<[value]> <[count2].get[<[loop_index]>]>"


        - narrate " done"

Command_pathadd:
    type: command
    name: pathadd
    description: adds player location to npc path list
    usage: /pathadd
    debug: true
    script:
        - define NPC <player.flag[unpcid]>
        - flag <[NPC]> path_list:->:<player.location>
        - flag <[NPC]> path_index:!
        - narrate "<player.location> added"
Command_pathclear:
    type: command
    name: pathclear
    usage: /pathclear
    description: clears path list
    debug: true
    script:
        - define NPC <player.flag[unpcid]>
        - flag <[NPC]> task:!
        - flag <[NPC]> path_index:!
        - flag <[NPC]> path_list:!
        - narrate "path cleared"
Command_path:
    type: command
    name: pathgo
    usage: /pathgo
    description: starts npc walking path
    debug: true
    script:
        - define NPC <player.flag[unpcid]>
        - flag <[NPC]> task:->:path
        - flag <[NPC]> path_index:0
        - narrate pathing

Command_clear:
    type: command
    name: clearnpc
    usage: /clearnpc
    description: clears all flags for players npc
    debug: false
    script:
        - run ClearNPC_task def:<player.flag[unpcid]>



Command_dig:
    type: command
    name: dig
    usage: /dig length width height (length width height/player location)
    description: sets plates npc to dig
    debug: true
    script:
        - define NPC <player.flag[unpcid]>
        - flag <[NPC]> dig:true
        - flag <[NPC]> length:<context.args.get[1]>
        - flag <[NPC]> width:<context.args.get[2]>
        - flag <[NPC]> height:<context.args.get[3]>
        - flag <[NPC]> origen:<player.location>
        - if <context.args.size.is[MORE].than[5]> :
            - flag <[NPC]> origen:<location[<context.args.get[4]>,<context.args.get[5]>,<context.args.get[6]>,world]>

        - flag <[NPC]> current_index:0
        - flag <[NPC]> task:dig
        - flag <[NPC]> schematic:!
        - lookclose <[NPC]> state:false
        - run BreakTimeout_task instantly def:<[NPC]>
        - narrate "digging <context.args>"

Command_fill:
    type: command
    name: npcfill
    usage: /npcfill
    description: wip
    debug: false
    script:
        - define NPC <player.flag[unpcid]>
        - define why <context.args.space_separated>
        - run Command_fill_task def:<[NPC]>|<player>|<[why]>
        - narrate "Filling <[why]>"
Command_build:
    type: command
    name: build
    usage: /build schematic
    description: wip
    debug: false
    script:
        - define NPC <player.flag[uplayerid]>
        - flag <[NPC]> schematic:<context.args.get[1]>
        - flag <[NPC]> origen:<player.location>
        - if <context.args.size.is[MORE].than[3]> :
            - flag <[NPC]> origen:<location[<context.args.get[2]>,<context.args.get[3]>,<context.args.get[4]>,world]>
        - flag <[NPC]> current_index:0
        - flag <[NPC]> task:build
        - flag <npc> bloc:!
        - run PlaceTimeout_task instantly def:<[NPC]>
        - narrate "Building <context.args.get[1]>"


Command_preshut:
    type: command
    name: preshut
    usage: /preshut
    description: pre shutdown command
    script:
        - if !<player.is_op||<context.server>> :
            - narrate "<red>You do not have permission for that command."
            - stop

        - foreach <server.online_players> :
            - kick <[value]> reason:Restart

        - adjust server save_citizens
        - adjust server save
Command_crop:
    type: command
    name: crop
    usage: /crop
    description: look a wheat to reset?
    script:
        - if !<player.is_op> :
            - narrate "<red>You do not have permission for that command."
            - stop

        - if <player.cursor_on.material> == <material[crops,7]> :
            - modifyblock <player.cursor_on> crops

Command_addtarget:
    type: command
    name: npcaddtarget
    usage: /npcaddtarget
    description: wip
    script:
        - execute as_server "npc sel <player.name>"
        - execute as_server "sentinel addtarget <context.args.get[1]>"

Command_removetarget:
    type: command
    name: npcremovetarget
    usage: /npcremovetarget
    description: wip
    script:
        - execute as_server "npc sel <player.name>"
        - execute as_server "sentinel removetarget <context.args.get[1]>"

Command_addignore:
    type: command
    name: npcaddignore
    usage: /npcaddignore
    description: wip
    script:
        - execute as_server "npc sel <player.name>"
        - execute as_server "sentinel addignore <context.args.get[1]>"

Command_removeignore:
    type: command
    usage: /npcremoveignore
    description: wip
    name: npcremoveignore
    script:
        - execute as_server "npc sel <player.name>"
        - execute as_server "sentinel removeignore <context.args.get[1]>"

Command_disc:
    type: command
    name: disc
    usage: /disc
    description: set discord output channel for player
    script:
        - flag <player.flag[unpcid]> disc:<context.args.get[1]>

Command_reset:
    type: command
    name: resetnpc
    usage: /resetnpc npc-name
    description: wip
    script:
        - flag <npc[<context.args.get[1]>]> killed:NULL
        #- flag <context.args.get[1]> task:!
        - flag <npc[<context.args.get[1]>]> food:20
        - adjust server save_citizens
        - wait 2t
        - run ClearCheckNPC_task def:<npc[<context.args.get[1]>]>
        - chunkload <npc[context.args.get[1]].location.chunk>
        - spawn <npc[<context.args.get[1]>]> <npc[<context.args.get[1]>].location>

Command_books:
    type: command
    name: books
    usage: /books
    description: gives player books
    script:
        - give Book_01
        - give Farm_book
        - give Dig_book


Command_chest:
    type: command
    name: chest
    usage: /chest
    description: drops chest with inventory
    script:
        - run Task_chest def:<player>
Command_read:
    type: command
    name: read
    usage: /read
    description: reads first book
    script:
    - if <player.inventory.contains_item[written_book]> :

        - define b <player.inventory.slot[<player.inventory.find_item[written_book]>]>
        - if <[b].book_title.ends_with[.targ]> :
            - foreach <[b].book_pages> as:pg :
                - flag <player.flag[unpcid]> targ_list:->:<[pg]>

            - run add_targets_task def:<player.flag[unpcid]>
            - narrate "targets <[b].book_title> added"

        - else if <[b].book_title.ends_with[.exe]> :
            - flag <player.flag[unpcid]> task_list:!
            - foreach <[b].book_pages> as:pg :
                - flag <player.flag[unpcid]> task_list:->:<[pg]>

            - flag <player.flag[unpcid]> task_index:0
            - narrate "Task <[b].book_title> started"
        - else :
            - narrate "no book I can read"

    - else :
        - narrate "no book in <player.name>s inventory"

Command_ckeck:
    type: command
    name: check
    usage: /check
    description: checks loaded npcs
    debug: false
    script:
        - foreach <server.npcs> :
            - run ClearCheckNPC_task instantly def:<[value]>

            - narrate "<[value].name> <[value].is_spawned>"
            - if <[value].has_flag[killed]> :
                - despawn <[value]>
                - narrate "<[value].name> <[value].flag[killed]> "

            - else :
                - if <[value].has_flag[uplayerid]>:
                    - if <[value].flag[uplayerid].is_online>:
                        - despawn <[value]>
                        - narrate "<[value].name> online"
                - else if !<[value].is_spawned> :
                    - chunkload <[value].location.chunk>
                    - spawn <[value]> <[value].location>
                    - narrate "<[value].name> spawned"