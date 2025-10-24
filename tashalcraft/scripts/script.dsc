
RepeatingScript:
    type: world
    debug: false
    events:


        on system time minutely:
        - flag server long_loop:++
        - foreach <server.npcs> :
            - if <[value].is_spawned> :
                - if <[value].has_flag[hold]> :
                    - if <[value].flag[hold].contains[player]> :
                        - run Load_area_task def:<[value].location>|<[value]>



                - if <server.flag[long_loop].mod[10].is[==].to[0]> :

                    - flag <[value]> equip:<[value].equipment>
                    - flag <[value]> equip:->:<[value].item_in_offhand>
                    - if <[value].has_flag[task]> || <server.flag[long_loop].mod[60].is[==].to[0]>:

                        - if <[value].inventory.contains_item[bread]> :

                            - take item:bread from:<[value].inventory>

                        - else :
                            - flag <[value]> food:-:1

                        - if <[value].flag[food].is[LESS].than[0]> :
                            - foreach <[value].inventory.list_contents> as:its :
                                - drop <[its]> <[value].location>
                            - flag <[value].flag[uplayerid]> killed:<[value].location>
                            - flag <[value]> killed:starved
                            - wait 3t
                            - inventory clear d:<[value].inventory>
                            - equip <[value]> head:air chest:air legs:air boots:air
                            - despawn <[value]>
                            - if <[value].has_flag[disc]> :
                                - ~discordmessage id:mybot channel:<discord[mybot].group[HarnCraft].channel[<[value].flag[disc]>]> "<[value].name> killed by starvation"
                            - else :
                                - ~discordmessage id:mybot channel:<discord[mybot].group[HarnCraft].channel[denizen]> "<[value].name> killed by starvation"


                - if <[value].has_flag[hired_til]> :
                    - if <[value].flag[hired_til].is[LESS].than[<server.current_time_millis>]> :
                        - flag <[value]> hired_by:!
                        - flag <[value]> hired_til:!
                        - flag <[value]> task:!
                        - flag <[value]> path_index:!
                        - flag <[value]> path_list:!
                        - flag <[value]> dig:!
                        - flag <[value]> length:!
                        - flag <[value]> width:!
                        - flag <[value]> height:!
                        - flag <[value]> origen:!
                        - flag <[value]> current_index:!
                        - flag <[value]> schematic:!
                        - flag <[value]> task_list:!
                        - flag <[value]> task_index:!
                        - flag <[value]> bloc:!
                        - flag <[value]> height:!
                        - flag <[value]> origen:!
                        - if <[value].has_flag[targ_list]> :
                            - run remove_targets_task def:<[value]>
                        - announce "<[value].name> unemployed"

            - else if <[value].has_flag[canhire]> && <[value].has_flag[killed]> && <[value].flag[food].is[MORE].than[0]>:
                - flag <[value]> killed:!
                - chunkload <[value].location.chunk>
                - spawn <[value]> <[value].location>
                - wait 3t
                - inventory clear d:<[value].inventory>


Book_task:
    type: task
    debug: false
    definitions: NPC
    script:
        - if !<[NPC].has_flag[task]> && !<[NPC].has_flag[hold]> :
            - if <[NPC].has_flag[task_index]> :
                - flag <[NPC]> task_index:++
                - define ttask <[NPC].flag[task_list].get[<[NPC].flag[task_index]>].split[,]>

                - choose <[ttask].get[1]> :
                    - case origen_npc :
                        - flag <[NPC]> origen:<[NPC].location>
                    - case origen_set :
                        - flag <[NPC]> origen:<location[<[ttask].get[2]>,<[ttask].get[3]>,<[ttask].get[4]>,world]>
                    - case origen_add :
                        - define og <[NPC].flag[origen].add[<[ttask].get[2]>,<[ttask].get[3]>,<[ttask].get[4]>]>
                        #- announce "origen:<[og]>"
                        - flag <[NPC]> origen:<[og]>
                    - case origen_clear :
                        - flag <[NPC]> origen:!
                    - case harvest :
                        - run Harvest_task instantly def:<[NPC]>
                    - case loop :

                        - if <[ttask].size.is[==].to[3]> :
                            - if <[NPC].has_flag[book_loop]> :
                                - announce <[NPC].flag[book_loop]>
                                - if <[NPC].flag[book_loop].is[OR_MORE].than[<[ttask].get[3]>]> :
                                    - flag <[NPC]> book_loop:!
                                - else :
                                    - flag <[NPC]> book_loop:++
                                    - flag <[NPC]> task_index:<[ttask].get[2]>
                            - else :
                                - flag <[NPC]> book_loop:0
                                - flag <[NPC]> task_index:<[ttask].get[2]>
                        - else if <[ttask].size.is[==].to[2]> :
                            - flag <[NPC]> task_index:<[ttask].get[2]>
                        - else :
                            - flag <[NPC]> task_index:0
                    - case walk :
                        #- run Load_area_task def:<[NPC].location>|<[NPC]>
                        - walk <[NPC]> <[NPC].flag[origen]> speed:1.5
                        - flag <[NPC]> hold:moveing expire:3s
                        - walk <[NPC]> <[NPC].flag[origen]> speed:1.5

                    - case chest :
                        - run Task_chest def:<[NPC]>

                    - case path :
                        - flag <[NPC]> path_list:!
                        - flag <[NPC]> path_list:->:<location[<[ttask].get[2]>,<[ttask].get[3]>,<[ttask].get[4]>,world]>
                        - flag <[NPC]> path_index:0
                        - flag <[NPC]> task:->:path

                    - case dig :

                        - flag <[NPC]> dig:true
                        - flag <[NPC]> length:<[ttask].get[2]>
                        - flag <[NPC]> width:<[ttask].get[3]>
                        - flag <[NPC]> height:<[ttask].get[4]>
                        - if <[NPC].has_flag[origen]>:
                            - if <[ttask].size.is[MORE].than[6]> :
                                - define og <[NPC].flag[origen]>
                                - flag <[NPC]> origen:<[og].add[<[ttask].get[5]>,<[ttask].get[6]>,<[ttask].get[7]>]>
                        - else :
                            - flag <[NPC]> origen:<[NPC].location>
                            - if <[ttask].size.is[MORE].than[6]> :
                                - flag <[NPC]> origen:<location[<[ttask].get[5]>,<[ttask].get[6]>,<[ttask].get[7]>,world]>

                        - flag <[NPC]> current_index:0
                        - flag <[NPC]> task:->:dig
                        - flag <[NPC]> schematic:!
                        - lookclose <[NPC]> state:false
                        - run BreakTimeout_task instantly def:<[NPC]>

                    - case dig_block :

                        - flag <[NPC]> dig:true
                        - flag <[NPC]> length:1
                        - flag <[NPC]> width:1
                        - flag <[NPC]> height:1
                        - if <[NPC].has_flag[origen]>:
                            - define og <[NPC].flag[origen]>
                            - flag <[NPC]> origen:<[og].add[0,-1,0]>
                            - if <[ttask].size.is[MORE].than[3]> :
                                - flag <[NPC]> origen:<location[<[og].add[<[ttask].get[2]>,<[ttask].get[3]>,<[ttask].get[4]>]>]>
                        - else:
                            - flag <[NPC]> origen:<[NPC].location.add[0,-1,0]>
                            - if <[ttask].size.is[MORE].than[3]> :
                                - flag <[NPC]> origen:<location[<[NPC].location.add[<[ttask].get[2]>,<[ttask].get[3]>,<[ttask].get[4]>]>]>
                        - flag <[NPC]> current_index:0
                        - flag <[NPC]> task:->:dig
                        - flag <[NPC]> schematic:!
                        - lookclose <[NPC]> state:false
                        - run BreakTimeout_task instantly def:<[NPC]>

                    - case disc :
                        - if <[NPC].has_flag[disc]> :

                            - ~discordmessage id:mybot channel:<npc.flag[disc]> "<[NPC].name> says <[ttask].get[2]>"

                - if <[NPC].flag[task_index].is[OR_MORE].than[<[NPC].flag[task_list].size>]> :
                    - flag <[NPC]> task_index:!
                    - if <[NPC].has_flag[disc]> :

                        - ~discordmessage id:mybot channel:<npc.flag[disc]> "<[NPC].name> fininshed book"





Harvest_task:
    type: task
    debug: false
    definitions: NPC
    script:

        - if <[NPC].location.add[0,1,0,world].material> == <material[wheat[age=7]]> :
            - modifyblock <[NPC].location.add[0,1,0,world]> wheat
            - give item:wheat to:<[NPC].inventory> quantity:2
BreakTimeout_task:
    type: task
    debug: false
    definitions: NPC
    script:
        - define length <[NPC].flag[length].abs>
        - define height <[NPC].flag[height].abs>
        - define width <[NPC].flag[width].abs>
        - define max <[width].mul[<[length]>].mul[<[height]>]>
        - define loc2 <[NPC].flag[origen]>
        - define loc3 <[NPC].flag[origen]>
        - define bloc <material[air]>
        - define ci <[NPC].flag[current_index]>
        - if <[NPC].flag[length].is[LESS].than[0]> :
            - while <[bloc].is[==].to[<material[air]>]> :
                - define current_y <[ci].mod[<[height]>]>
                - define temp_z <[ci].div_int[<[height]>]>
                - define current_z <[temp_z].mod[<[width]>]>
                - define temp_x <[width].mul[<[height]>]>
                - define current_x <[ci].div_int[<[temp_x]>]>
                - define loc1 <location[<[current_x].mul[-1]>,<[current_y]>,<[current_z]>,world]>
                - if <[NPC].flag[width].is[LESS].than[0]> :
                    - define loc1 <location[<[current_z]>,<[current_y]>,<[current_x].mul[-1]>,world]>

                - define loc2 <[loc3].add[<[loc1]>]>
                - define bloc <[loc2].material>
                - define ci <[ci].add[1]>
                - if <[ci].is[OR_MORE].than[<[max]>]> :
                    - while stop

        - else :
            - while <[bloc].is[==].to[<material[air]>]> :
                - define current_y <[ci].mod[<[height]>]>
                - define temp_z <[ci].div_int[<[height]>]>
                - define current_z <[temp_z].mod[<[width]>]>
                - define temp_x <[width].mul[<[height]>]>
                - define current_x <[ci].div_int[<[temp_x]>]>
                - define loc1 <location[<[current_x]>,<[current_y]>,<[current_z]>,world]>
                - if <[NPC].flag[width].is[LESS].than[0]> :
                    - define loc1 <location[<[current_z]>,<[current_y]>,<[current_x]>,world]>

                - define loc2 <[loc3].add[<[loc1]>]>
                - define bloc <[loc2].material>
                - define ci <[ci].add[1]>
                - if <[ci].is[OR_MORE].than[<[max]>]> :
                    - while stop

        - flag <[NPC]> current_block:<[loc2]>
        - flag <[NPC]> current_index:<[ci].add[-1]>
        - if <[loc2].has_flag[reinforced]> :
            - flag <[NPC]> placetimeout:-1
        - else if <[loc2].material.is[==].to[<material[stone]>]> || <[loc2].material.is[==].to[<material[dirt]>]>:
            - flag <[NPC]> placetimeout:<server.current_time_millis.add[1000]>


        - else if <[loc2].material.is[==].to[<material[grass_block]>]> || <[loc2].material.is[==].to[<material[granite]>]> || <[loc2].material.is[==].to[<material[diorite]>]> || <[loc2].material.is[==].to[<material[andesite]>]> || <[loc2].material.is[==].to[<material[sandstone]>]>:
            - flag <[NPC]> placetimeout:<server.current_time_millis.add[3000]>

        - else if <[loc2].material.is[==].to[<material[wheat[age=7]]>]> :
            - flag <[NPC]> placetimeout:<server.current_time_millis.add[1000]>

        - else if <[loc2].material.is[==].to[<material[bedrock]>]> || <[loc2].has_inventory>:
            - flag <[NPC]> placetimeout:-1
        - else:
            - flag <[NPC]> placetimeout:-1

        - if <[ci].is[MORE].than[<[max]>]> :
            - flag <[NPC]> current_index:!
            - flag <[NPC]> bloc:!
            - flag <[NPC]> task:!
            - define msg "<[NPC].name> <green>Dig Done"
            - run Report_task def:<[NPC]>|<[msg]>





Report_task:
    type: task
    debug: false
    definitions: NPC|msg
    script:
    - if <[NPC].has_flag[report]> :
        - define pr <[NPC].flag[report]>
        - if <[pr].is_online> :
            - narrate target:<[NPC].flag[report]> <[msg]>








playerclose:
    type: procedure
    debug: false
    definitions: loc
    script:
    - define out false
    - foreach <server.online_players> :
        - if <[loc].distance[<[value].location>].horizontal.is[LESS].than[100]> :
            - define out true
            - foreach stop

    - determine <[out]>

cancommand:
    type: procedure
    debug: false
    definitions: NPC|Player
    script:
    - define out false
    - if <[NPC].has_flag[commander]> :
        - if <[NPC].flag[commander].contains[<[Player].name>]> :
            - define out true

        - if <[NPC].flag[commander].contains[all]> :
            - define out true

    - if <[NPC].has_flag[hired_by]> :
        - if <[NPC].flag[hired_by].is[==].to[<[Player].name>]> :
            - define out true

    - if <player.is_op> :
        - define out true
    - determine <[out]>

Task_chest:
    type: task
    debug: true
    definitions: NPC
    script:
    - if <[NPC].inventory.contains_item[chest]> :
        - take item:chest from:<[NPC].inventory>
        - modifyblock <[NPC].location> chest
        - wait 3t
        - foreach <[NPC].inventory.list_contents>:
            - if <[loop_index].is[OR_MORE].than[10]> && <[loop_index].is[OR_LESS].than[36]>:
                - give item:<[value]> to:<[NPC].location.inventory>
                - inventory adjust slot:<[loop_index]> quantity:0 d:<[NPC].inventory>


Chunk_load_task:
    type: task
    debug: true
    definitions: loc|NPC
    script:
    - chunkload <[loc].chunk> duration:10m
    - chunkload <[loc].chunk.add[0,1]> duration:10m
    - chunkload <[loc].chunk.add[0,-1]> duration:10m
    - chunkload <[loc].chunk.add[1,0]> duration:10m
    - chunkload <[loc].chunk.add[-1,0]> duration:10m
    - chunkload <[NPC].location.chunk> duration:10m
Load_area_task:
    type: task
    debug: false
    definitions: loc|NPC
    script:
    - if !<proc[playerclose].context[<[NPC].location>]> :
        - if !<[NPC].has_flag[hold]> :
            - flag <[NPC]> hold:player
        - walk <[NPC]> stop
        - foreach <server.online_players> :
            - if <[value].gamemode.is[==].to[spectator]> :
                - if <[value].has_flag[lat]>:
                    - if <[value].flag[lat].is[OR_LESS].than[<server.current_time_millis>]> :
                        - teleport <[value]> <[loc]>
                        - log "teleported me <[loc]>" file:npc.log
                        - flag <[value]> lat:<server.current_time_millis.add[17000]>
                        - if <[NPC].has_flag[hold]> :
                            - if <[NPC].flag[hold].contains[player]> :
                                - flag <[NPC]> hold:!
                - else :
                    - teleport <[value]> <[loc]>
                    - log "teleported me <[loc]>" file:npc.log
                    - flag <[value]> lat:<server.current_time_millis.add[17000]>
                    - if <[NPC].has_flag[hold]> :
                        - if <[NPC].flag[hold].contains[player]> :
                            - flag <[NPC]> hold:!
    - else :
        - if <[NPC].has_flag[hold]> :
            - if <[NPC].flag[hold].contains[player]> :
                - flag <[NPC]> hold:!


Command_fill_task:
    type: task
    debug: false
    definitions: NPC|plyer|why
    script:
        - define msg <[why].split>
        - announce <[msg]>
        - flag <[NPC]> bloc:<[msg].get[1]>
        - flag <[NPC]> length:<[msg].get[2]>
        - flag <[NPC]> width:<[msg].get[3]>
        - flag <[NPC]> height:<[msg].get[4]>
        - flag <[NPC]> origen:<[plyer].location>
        - if <[msg].size.is[MORE].than[6]> :
            - flag <[NPC]> origen:<location[<[msg].get[5]>,<[msg].get[6]>,<[msg].get[7]>,world]>

        - flag <[NPC]> current_index:0
        - flag <[NPC]> task:fill
        - flag <[NPC]> schematic:!
Command_path_task:
    type: task
    debug: false
    definitions: NPC|player
    script:
        - flag <[NPC]> path_list:<[player].flag[path_list]>
        - flag <[NPC]> path_index:0
        - flag <[NPC]> task:->:path
        - flag <[NPC]> schematic:!

MoveNPC_task:
    type: task
    debug: false
    definitions: NPC|l
    script:
        - repeat 100:
            - define rndx <util.random.int[1].to[5].add_int[-3]>
            - define rndz <util.random.int[1].to[5].add_int[-3]>
            - define rndy <util.random.int[1].to[5].add_int[-4]>
            - if <[l].add[<[rndx]>,<[rndy]>,<[rndz]>].is_spawnable>:
                - repeat stop
        - walk <[NPC]> <[l].add[<[rndx]>,<[rndy]>,<[rndz]>]> speed:1.5
        - flag <[NPC]> hold:moveing expire:3s

read_book_task:
    type: task
    debug: false
    definitions: NPC
    script:
    - if <[NPC].inventory.contains_item[written_book]> :

        - define b <[NPC].inventory.slot[<[NPC].inventory.find_item[written_book]>]>
        - if <[b].book_title.ends_with[.targ]> :
            - foreach <[b].book_pages> as:pg :
                - flag <[NPC]> targ_list:->:<[pg]>

            - run add_targets_task def:<[NPC]>
            - chat "targets <[b].book_title> added"

        - else if <[b].book_title.ends_with[.exe]> :
            - flag <npc> task_list:!
            - foreach <[b].book_pages> as:pg :
                - flag <npc> task_list:->:<[pg]>

            - flag <[NPC]> task_index:0
            - flag <[NPC]> book_loop:!
            - chat "Task <[b].book_title> started"
        - else :
            - chat "no book I can read"

    - else :
        - chat "no book in <[NPC].name>s inventory"


add_targets_task:
    type: task
    debug: true
    definitions: NPC
    script:
    - execute as_server "npc sel <[NPC].id>"
    - foreach <[NPC].flag[targ_list]> as:li :
        - define typel <[li].split[,]>
        - if <[typel].get[1].is[==].to[t]> :
            - if <[typel].size.is[==].to[2]> :
                - execute as_server "sentinel addtarget <[typel].get[2]>"

            - if <[typel].size.is[==].to[3]> :
                - execute as_server "sentinel addtarget PLAYER:<[typel].get[3]>"
                - execute as_server "sentinel addtarget NPC:<[typel].get[3]>"

remove_targets_task:
    type: task
    debug: true
    definitions: NPC
    script:
    - execute as_server "npc sel <[NPC].id>"
    - foreach <[NPC].flag[targ_list]> as:li :
        - define typel <[li].split[,]>
        - if <[typel].get[1].is[==].to[t]> :
            - if <[typel].size.is[==].to[2]> :
                - execute as_server "sentinel removetarget <[typel].get[2]>"

            - if <[typel].size.is[==].to[3]> :
                - execute as_server "sentinel removetarget PLAYER:<[typel].get[3]>"
                - execute as_server "sentinel removetarget NPC:<[typel].get[3]>"

    - flag <[NPC]> targ_list:!



Fill_task:
    type: task
    debug: false
    definitions: NPC
    script:
        - define loc3 <[NPC].flag[origen]>
        - define ci <[NPC].flag[current_index]>
        - define bloc <[NPC].flag[bloc]>
        - define max <[NPC].flag[width].mul[<[NPC].flag[height].mul[<[NPC].flag[length]>]>].abs>
        - define current_z <[ci].mod[<[NPC].flag[width]>]>
        - define temp_y <[ci].div_int[<[NPC].flag[width]>]>
        - define current_y <[temp_y].mod[<[NPC].flag[height]>]>
        - define temp_x <[NPC].flag[height].mul[<[NPC].flag[width]>]>
        - define current_x <[ci].div_int[<[temp_x]>]>
        - define loc1 <location[<[current_z]>,<[current_y]>,<[current_x]>,world]>
        - define ci <[ci].add[1]>

        - flag <[NPC]> current_index:<[ci]>
        - define loc2 <[loc3].add[<[loc1]>]>
        - look <[NPC]> <[loc2]>
        - if <[NPC].eye_location.distance_squared[<[loc2]>].is[LESS].than[42]> :
            - define eyeloc <[NPC].eye_location>
            - if <proc[LOS_proc].context[<[NPC].eye_location>|<[loc2]>]> :
                - flag <[NPC]> fails:0
                - if <[loc2].material.is[==].to[<material[air]>]>:
                    - if <[NPC].inventory.contains_item[<[bloc]>]> :
                        - modifyblock <[loc2]> <[bloc]>
                        - take item:<[bloc]> from:<[NPC].inventory>
                        - define current_z <[ci].mod[<[NPC].flag[width]>]>
                        - define temp_y <[ci].div_int[<[NPC].flag[width]>]>
                        - define current_y <[temp_y].mod[<[NPC].flag[height]>]>
                        - define temp_x <[NPC].flag[height].mul[<[NPC].flag[width]>]>
                        - define current_x <[ci].div_int[<[temp_x]>]>
                        - define loc1 <location[<[current_z]>,<[current_y]>,<[current_x]>,world]>
                        - define loc2 <[loc3].add[<[loc1]>].simple.split[,]>

                - animate <[NPC]> animation:ARM_SWING

            - else :
                - if <[NPC].flag[fails].is[MORE].than[5]> :
                    - run Load_area_task def:<[loc2]>|<[NPC]>
                    - define msg "<[NPC].name> <[loc2].simple> <red>can't see fails:<[NPC].flag[fails]>"
                    - run Report_task def:<[NPC]>|<[msg]>
                - run MoveNPC_task def:<[NPC]>|<[loc2]>
                - flag <[NPC]> current_index:-:1
                - if <[NPC].has_flag[fails]> :
                    - if <[NPC].flag[fails].is[MORE].than[20]> :
                        - flag <[NPC]> task:!

                    - else :
                        - flag <[NPC]> fails:++


                - else :
                    - flag <[NPC]> fails:1



        - else :
            - if <[NPC].flag[fails].is[MORE].than[2]> :
                - run Load_area_task def:<[loc2]>|<[NPC]>
                - define msg "<[NPC].name> <[loc2].simple> <red>too far - fails:<[NPC].flag[fails]>"
                - run Report_task def:<[NPC]>|<[msg]>
            - run MoveNPC_task def:<[NPC]>|<[loc2]>
            - flag <[NPC]> current_index:-:1
            - if <[NPC].has_flag[fails]> :
                - if <[NPC].flag[fails].is[MORE].than[30]> :
                    - flag <[NPC]> task:!
                    - flag <[NPC]> fails:0

                - else :
                    - flag <[NPC]> fails:++

            - else :
                - flag <[NPC]> fails:1



        - if <[ci].is[OR_MORE].than[<[max]>]> || <[ci].is[OR_MORE].than[128]> :
            - flag <[NPC]> current_index:!
            - flag <[NPC]> bloc:!
            - flag <[NPC]> task:!
            - define msg "<green>Fill Done"
            - run Report_task def:<[NPC]>|<[msg]>



Build_task:
    type: task
    debug: false
    definitions: NPC
    script:
        - if !<schematic[<[NPC].flag[schematic]>].exists> :
            - schematic load name:<[NPC].flag[schematic]>

        - define loc3 <[NPC].flag[origen]>
        - define bloc <material[air]>
        - define ci <[NPC].flag[current_index]>
        - while <[bloc].is[==].to[<material[air]>]> :
            - define current_z <[ci].mod[<schematic[<[NPC].flag[schematic]>].width>]>
            - define temp_y <[ci].div_int[<schematic[<[NPC].flag[schematic]>].width>]>
            - define current_y <[temp_y].mod[<schematic[<[NPC].flag[schematic]>].height>]>
            - define temp_x <schematic[<[NPC].flag[schematic]>].height.mul[<schematic[<[NPC].flag[schematic]>].width>]>
            - define current_x <[ci].div_int[<[temp_x]>]>
            - define loc1 <location[<[current_z]>,<[current_y]>,<[current_x]>,world]>
            - define bloc <schematic[<[NPC].flag[schematic]>].block[<[loc1]>]>
            - define ci <[ci].add[1]>
            - if <[ci].is[==].to[<schematic[<[NPC].flag[schematic]>].blocks>]> :
                - while stop

        - flag <[NPC]> current_index:<[ci]>
        - define loc2 <[loc3].add[<[loc1]>]>
        - look <[NPC]> <[loc2]>
        - if <[NPC].eye_location.distance_squared[<[loc2]>].is[LESS].than[42]> :
            - define eyeloc <[NPC].eye_location>
            - if <proc[LOS_proc].context[<[NPC].eye_location>|<[loc2]>]> :
                - flag <[NPC]> fails:0
                - if <[loc2].material.is[==].to[<material[air]>]> :
                    - if <[NPC].inventory.contains_item[<[bloc]>]> :
                        - modifyblock <[loc2]> <[bloc]>
                        - take from:<[NPC].inventory> item:<[bloc]>
                        - run PlaceTimeout_task instantly def:<[NPC]>
                        - flag <[NPC]> placetimeout:0

                - animate <[NPC]> animation:ARM_SWING

            - else :
                - if <[NPC].flag[fails].is[MORE].than[2]> :
                    - run Load_area_task def:<[loc2]>|<[NPC]>
                    - define msg "<[NPC].name> <[loc2].simple> <red>can't see fails:<[NPC].flag[fails]>"
                    - run Report_task def:<[NPC]>|<[msg]>
                - run MoveNPC_task def:<[NPC]>|<[loc2]>
                - flag <[NPC]> current_index:-:1
                - if <[NPC].has_flag[fails]> :
                    - if <[NPC].flag[fails].is[MORE].than[10]> :
                        - flag <[NPC]> task:!
                        - flag <[NPC]> fails:0

                    - else :
                        - flag <[NPC]> fails:++

                - else :
                    - flag <[NPC]> fails:1



        - else :
            - if <[NPC].flag[fails].is[MORE].than[2]> :
                - run Load_area_task def:<[loc2]>|<[NPC]>
                - define msg "<[NPC].name> <[loc2].simple> <red>too far - fails:<[NPC].flag[fails]>"
                - run Report_task def:<[NPC]>|<[msg]>
            - run MoveNPC_task def:<[NPC]>|<[loc2]>
            - flag <[NPC]> current_index:-:1
            - if <[NPC].has_flag[fails]> :
                - if <[NPC].flag[fails].is[MORE].than[10]> :
                    - flag <[NPC]> task:!
                    - flag <[NPC]> fails:0

                - else :
                    - flag <[NPC]> fails:++

            - else :
                - flag <[NPC]> fails:1


        - if <[ci].is[==].to[<schematic[<[NPC].flag[schematic]>].blocks.add[1]>]> :
            - flag <[NPC]> current_index:!
            - flag <[NPC]> task:!
            - define msg "<green><[NPC].flag[schematic]> Done"
            - run Report_task def:<[NPC]>|<[msg]>
            - flag <[NPC]> schematic:!






GetIndexLoc_proc:
    type: procedure
    debug: true
    definitions: length|width|height|ci
    script:
        - define current_z <[ci].mod[<[width]>]>
        - define temp_y <[ci].div_int[<[width]>]>
        - define current_y <[temp_y].mod[<[height]>]>
        - define temp_x <[height].mul[<[width]>]>
        - define current_x <[ci].div_int[<[temp_x]>]>
        - define loc <location[<[current_z]>,<[current_y]>,<[current_x]>,world]>
        - determine <[loc]>

LOS_proc:
    type: procedure
    debug: false
    definitions: loc1|loc2
    script:
    - define out true
    - if <[loc1].distance[<[loc2]>].is[OR_MORE].than[2.5]> :
        - define plist <[loc1].points_between[<[loc2]>]>
        - repeat <[plist].size.sub[1]>  :
            - if <[plist].get[<[value]>].material.is_solid> :
                - define out false

    - determine <[out]>
goodmove:
    type: procedure
    debug: true
    definitions: loc1
    script:
    - define out false
    - if !<[loc1].material.is_solid> :
        - if !<[loc1].add[0,1,0].material.is_solid> :
            - if <[loc1].add[0,-1,0].material.is_solid> :
                - define out true

    - determine <[out]>
randomstep:
    type: procedure
    debug: false
    definitions: loc1
    script:
    - define locout <[loc1]>
    - define rndx <util.random.int[1].to[4]>
    - if <[rndx].is[==].to[1]> :
        - define locout <[loc1].add[1,0,0]>

    - if <[rndx].is[==].to[1]> :
        - define locout <[loc1].add[-1,0,0]>

    - if <[rndx].is[==].to[1]> :
        - define locout <[loc1].add[0,0,1]>

    - if <[rndx].is[==].to[1]> :
        - define locout <[loc1].add[0,0,-1]>

    - determine <[locout]>
yawnext:
    type: procedure
    debug: true
    definitions: loc1
    script:
    - define locout <[loc1]>

    - if <[loc1].yaw.simple.contains[North]> :
        - define locout <[loc1].add[0,0,-1]>

    - if <[loc1].yaw.simple.contains[South]> :
        - define locout <[loc1].add[0,0,1]>

    - if <[loc1].yaw.simple.contains[East]> :
        - define locout <[loc1].add[1,0,0]>

    - if <[loc1].yaw.simple.contains[West]> :
        - define locout <[loc1].add[-1,0,0]>

    - determine <[locout]>

is_safe_proc:
    type: procedure
    debug: false
    definitions: loc1
    script:
    - define out true
    - if <[loc1].add[0,1,0].material.name.is[==].to[lava]> :
        - define out false

    - if <[loc1].add[0,-1,0].material.name.is[==].to[lava]> :
        - define out false

    - if <[loc1].add[1,0,0].material.name.is[==].to[lava]> :
        - define out false

    - if <[loc1].add[-1,0,0].material.name.is[==].to[lava]> :
        - define out false

    - if <[loc1].add[0,0,1].material.name.is[==].to[lava]> :
        - define out false

    - if <[loc1].add[0,0,-1].material.name.is[==].to[lava]> :
        - define out false




    - determine <[out]>


PlaceTimeout_task:
    type: task
    debug: false
    definitions: NPC
    script:
        - if !<schematic[<[NPC].flag[schematic]>].exists> :
            - schematic load name:<[NPC].flag[schematic]>

        - define loc3 <[NPC].flag[origen]>
        - define bloc <material[air]>
        - define ci <[NPC].flag[current_index]>
        - while <[bloc].is[==].to[<material[air]>]> :
            - define current_z <[ci].mod[<schematic[<[NPC].flag[schematic]>].width>]>
            - define temp_y <[ci].div_int[<schematic[<[NPC].flag[schematic]>].width>]>
            - define current_y <[temp_y].mod[<schematic[<[NPC].flag[schematic]>].height>]>
            - define temp_x <schematic[<[NPC].flag[schematic]>].height.mul[<schematic[<[NPC].flag[schematic]>].width>]>
            - define current_x <[ci].div_int[<[temp_x]>]>
            - define loc1 <location[<[current_z]>,<[current_y]>,<[current_x]>,world]>
            - define bloc <schematic[<[NPC].flag[schematic]>].block[<[loc1]>]>
            - define ci <[ci].add[1]>

        - define loc2 <[loc3].add[<[loc1]>]>
        - modifyblock <[loc2]> <[bloc]>
        - if <[ci].is[==].to[<schematic[<[NPC].flag[schematic]>].blocks.add[1]>]> :
            - flag <[NPC]> current_index:!
            - run Report_task def:<[NPC]>|"<green><[NPC].flag[schematic]> Done"
            - flag <[NPC]> schematic:!






Dig_task:
    type: task
    debug: false
    definitions: NPC
    script:





        - define loc2 <[NPC].flag[current_block]>
        - define bloc <[loc2].material>
        - look <[NPC]> <[loc2]>
        - if <[NPC].eye_location.distance_squared[<[loc2]>].is[LESS].than[42]> :
            - if !<proc[is_safe_proc].context[<[loc2]>]> :

                - define msg "<[NPC].name> <[loc2].simple> <red>LAVA!"

                - flag <[NPC]> current_index:!
                - flag <[NPC]> dig:!
                - flag <[NPC]> task:!
                - run Report_task def:<[NPC]>|<[msg]>
            - else :
                - define eyeloc <[NPC].eye_location>
                - if <proc[LOS_proc].context[<[NPC].eye_location>|<[loc2]>]> :

                    - flag <[NPC]> fails:0












                    - if <[bloc].is[==].to[<material[stone]>]> :
                        - modifyblock <[loc2]> <material[air]>
                        - run Duribility_task instantly def:<[NPC]>


                        - if <util.random_decimal.is[OR_LESS].than[0.005]> && <[NPC].location.y.is[LESS].than[17]>  && <[NPC].item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]> || <[NPC].item_in_hand.material.is[==].to[<material[iron_pickaxe]>]> :

                            - give <item[diamond_ore]> to:<[NPC].inventory>
                            - define msg "<[NPC].name> <[loc2].simple> <[bloc]> diamond"
                            - run Report_task def:<[NPC]>|<[msg]>
                        - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <[loc2].biome.is[==].to[<biome[world,otg:a1.river]>]>  && <[NPC].item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <[NPC].item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <[NPC].item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                            - give <item[redstone_ore]> to:<[NPC].inventory>
                            - define msg "<[NPC].name> <[loc2].biome> <[bloc]> redstone"
                            - run Report_task def:<[NPC]>|<[msg]>
                        - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <[loc2].biome.is[==].to[<biome[world,otg:a1.warm_ocean]>]>  && <[NPC].item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <[NPC].item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <[NPC].item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                            - give <item[lapis_ore]> to:<[NPC].inventory>
                            - define msg "<[NPC].name> <[loc2].simple> <[bloc]> lapis"
                            - run Report_task def:<[NPC]>|<[msg]>
                        - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <[loc2].biome.is[==].to[<biome[world,otg:a1.wooded_mountains]>]>  && <[NPC].item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <[NPC].item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <[NPC].item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                            - give <item[gold_ore]> to:<[NPC].inventory>
                            - define msg "<[NPC].name> <[loc2].simple> <[bloc]> gold"
                            - run Report_task def:<[NPC]>|<[msg]>
                        - else if <util.random_decimal.is[OR_LESS].than[0.02]> && <[NPC].location.y.is[LESS].than[40]>  && <[NPC].item_in_hand.material.is[==].to[<material[stone_pickaxe]>]> || <[NPC].item_in_hand.material.is[==].to[<material[iron_pickaxe]>]>  || <[NPC].item_in_hand.material.is[==].to[<material[diamond_pickaxe]>]>:

                            - give <item[iron_ore]> to:<[NPC].inventory>
                            - define msg "<[NPC].name> <[loc2].simple> <[bloc]> iron"
                            - run Report_task def:<[NPC]>|<[msg]>
                        - else :
                            - give <item[cobblestone]> to:<[NPC].inventory>
                    - else if <[bloc].is[==].to[<material[grass_block]>]> :
                            - modifyblock <[loc2]> <material[air]>
                            - give <item[dirt]> to:<[NPC].inventory>
                            - run Duribility_task instantly def:<[NPC]>
                    - else if <[bloc].is[==].to[<material[wheat[age=7]]>]> :
                        - modifyblock <[loc2]> wheat
                        - give item:wheat to:<[NPC].inventory> quantity:2
                        - run Duribility_task instantly def:<[NPC]>
                    - else if <[bloc].is[==].to[<material[air]>]> :
                            - define msg "<[NPC].name> <[loc2].simple> <red>AIR"
                            - run Report_task def:<[NPC]>|<[msg]>
                    - else :
                        - modifyblock <[loc2]> <material[air]>
                        - give <item[<[bloc]>]> to:<[NPC].inventory>
                        - run Duribility_task instantly def:<[NPC]>

                    - animate <[NPC]> animation:ARM_SWING


                - else :
                    - if <[NPC].flag[fails].is[MORE].than[2]> :
                        - run Load_area_task def:<[loc2]>|<[NPC]>
                        - define msg "<[NPC].name> <[loc2].simple> <red>can't see fails:<[NPC].flag[fails]>"
                        - run Report_task def:<[NPC]>|<[msg]>

                    - run MoveNPC_task def:<[NPC]>|<[loc2]>
                    - flag <[NPC]> current_index:-:1
                    - if <[NPC].has_flag[fails]> :
                        - if <[NPC].flag[fails].is[MORE].than[90]> :
                            - flag <[NPC]> task:!
                            - flag <[NPC]> fails:0

                        - else :
                            - flag <[NPC]> fails:++

                    - else :
                        - flag <[NPC]> fails:1



        - else :
            - if <[NPC].flag[fails].is[MORE].than[2]> :
                - run Load_area_task def:<[loc2]>|<[NPC]>
                - define msg "<[NPC].name> <[loc2].simple> <red>Too far fails:<[NPC].flag[fails]>"
                - run Report_task def:<[NPC]>|<[msg]>

            - run MoveNPC_task def:<[NPC]>|<[loc2]>
            - flag <[NPC]> current_index:-:1
            - if <[NPC].has_flag[fails]> :
                - if <[NPC].flag[fails].is[MORE].than[90]> :
                    - flag <[NPC]> task:!
                    - flag <[NPC]> fails:0

                - else :
                    - flag <[NPC]> fails:++

            - else :
                - flag <[NPC]> fails:1

        - if <[NPC].has_flag[fails]> :
            - if <[NPC].flag[fails].is[LESS].than[3]> :
                - run BreakTimeout_task instantly def:<[NPC]>

        - else :
            - run BreakTimeout_task instantly def:<[NPC]>


Duribility_task:
    type: task
    debug: false
    definitions: NPC
    script:
    - if <[NPC].item_in_hand.max_durability.is[MORE].than[0]>  :
        - inventory adjust slot:1 durability:<[NPC].inventory.slot[0].durability.add[1]> d:<[NPC].inventory>
        - if <[NPC].inventory.slot[0].durability.is[OR_MORE].than[<[NPC].inventory.slot[0].max_durability>]> :
            - if <[NPC].item_in_hand.material.is[==].to[<material[iron_pickaxe]>]> && <[NPC].inventory.contains_item[iron_ingot]>:
                - take item:iron_ingot quantity:1 from:<[NPC].inventory>
                - inventory adjust slot:1 durability:<[NPC].inventory.slot[0].durability.sub[84]> d:<[NPC].inventory>
            - else :
                - inventory adjust slot:1 quantity:0 d:<[NPC].inventory>
ClearNPC_task:
    type: task
    debug: false
    definitions: NPC
    script:
        - flag <[NPC]> task:NULL
        - flag <[NPC]> path_index:NULL
        - flag <[NPC]> path_list:NULL
        - flag <[NPC]> dig:NULL
        - flag <[NPC]> length:NULL
        - flag <[NPC]> width:NULL
        - flag <[NPC]> height:NULL
        - flag <[NPC]> origen:NULL
        - flag <[NPC]> current_index:NULL
        - flag <[NPC]> schematic:NULL
        - flag <[NPC]> task_list:NULL
        - flag <[NPC]> task_index:NULL
        - flag <[NPC]> bloc:NULL
        - flag <[NPC]> height:NULL
        - flag <[NPC]> origen:NULL

        - adjust server save_citizens
        - adjust server save

        - run ClearCheckNPC_task def:<[NPC]>
ClearCheckNPC_task:
    type: task
    debug: false
    definitions: NPC
    script:

        - if <[NPC].has_flag[task]>:
            - if <[NPC].flag[task].is[==].to[NULL]>:
                - flag <[NPC]> task:!
        - if <[NPC].has_flag[path_index]>:
            - if <[NPC].flag[path_index].is[==].to[NULL]>:
                - flag <[NPC]> path_index:!
        - if <[NPC].has_flag[path_list]>:
            - if <[NPC].flag[path_list].is[==].to[NULL]>:
                - flag <[NPC]> path_list:!
        - if <[NPC].has_flag[dig]>:
            - if <[NPC].flag[dig].is[==].to[NULL]>:
                - flag <[NPC]> dig:!
        - if <[NPC].has_flag[length]>:
            - if <[NPC].flag[length].is[==].to[NULL]>:
                - flag <[NPC]> length:!
        - if <[NPC].has_flag[width]>:
            - if <[NPC].flag[width].is[==].to[NULL]>:
                - flag <[NPC]> width:!
        - if <[NPC].has_flag[height]>:
            - if <[NPC].flag[height].is[==].to[NULL]>:
                - flag <[NPC]> height:!
        - if <[NPC].has_flag[origen]>:
            - if <[NPC].flag[origen].is[==].to[NULL]>:
                - flag <[NPC]> origen:!
        - if <[NPC].has_flag[current_index]>:
            - if <[NPC].flag[current_index].is[==].to[NULL]>:
                - flag <[NPC]> current_index:!
        - if <[NPC].has_flag[schematic]>:
            - if <[NPC].flag[schematic].is[==].to[NULL]>:
                - flag <[NPC]> schematic:!
        - if <[NPC].has_flag[task_list]>:
            - if <[NPC].flag[task_list].is[==].to[NULL]>:
                - flag <[NPC]> task_list:!
        - if <[NPC].has_flag[task_index]>:
            - if <[NPC].flag[task_index].is[==].to[NULL]>:
                - flag <[NPC]> task_index:!
        - if <[NPC].has_flag[bloc]>:
            - if <[NPC].flag[bloc].is[==].to[NULL]>:
                - flag <[NPC]> bloc:!
        - if <[NPC].has_flag[height]>:
            - if <[NPC].flag[height].is[==].to[NULL]>:
                - flag <[NPC]> height:!
        - if <[NPC].has_flag[killed]>:
            - if <[NPC].flag[killed].is[==].to[NULL]>:
                - flag <[NPC]> killed:!
