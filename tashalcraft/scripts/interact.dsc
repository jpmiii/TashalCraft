DefaultAssignment:
    type: assignment
    actions:
        on assignment:
        - chat "I has been assigned!"
        - trigger name:proximity state:true radius:3
        - trigger name:chat state:true

    Interact Scripts:
    - DefaultInteract


DefaultInteract:
    type: Interact
    debug: false
    Steps:
        '1':
            Proximity trigger:
                Entry:
                    Script:
                    - if <npc.has_flag[canhire]> && !<npc.has_flag[hired_by]> :
                        - chat "Hi there, <player.name>!"
                        - CHAT "I'm looking for work"
                        - CHAT "you can hire me by chatting"
                        - CHAT "'hiring you'"
                        - CHAT "with bread in your hand 2 minutes per bread"
                        - CHAT "the commands are at "
                        #- CHAT "https://www.reddit.com/r/CivcraftIslands/wiki/npcs#wiki_npc_chat_commands"

            chat Trigger:
                '1':
                    Trigger: "/Hello/ there npc!"
                    Script:
                    - if <npc.has_flag[canhire]> && !<npc.has_flag[hired_by]> :
                        - CHAT "I'm looking for work"
                        - CHAT "you can hire me by chatting"
                        - CHAT "'hiring you'"
                        - CHAT "with bread in your hand 2 minutes per bread"

                    - else :
                        - CHAT "Hi"


                '2':
                    Trigger: "/report/ npc"
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - CHAT "Hello, Commander <player.name>"
                        - if <npc.has_flag[task]> :
                            - CHAT "Task: <npc.flag[task]>"

                        - else :
                            - chat "Resting"

                        - if <npc.has_flag[hired_til]> :
                            - define millis <npc.flag[hired_til].sub[<server.current_time_millis>]>
                            - chat "minutes left: <[millis].div[60000]>"

                        - wait 2s
                        - execute as_player "npc sel <npc.id>"
                        - execute as_player "sentinel info"
                        - execute as_player "sentinel targets"

                '3':
                    Trigger: /stop/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].size.is[==].to[1]> :
                            - if <[msg].get[1].contains[stop]> :
                                - run ClearNPC_task  def:<npc>
                                - CHAT "I will stop"

                        - if <[msg].size.is[==].to[2]> :
                            - if <[msg].get[1].contains[stop]> :
                                - if <[msg].get[2].contains[build]> || <[msg].get[2].contains[fill]> :
                                    - flag <npc> current_index:!
                                    - flag <npc> schematic:!
                                    - flag <npc> bloc:!
                                    - CHAT "I will stop <[msg].get[2]>ing"

                            - if <[msg].get[1].contains[stop]> :
                                - if <[msg].get[2].contains[follow]> :
                                    - flag <npc> follow:!
                                    - CHAT "I will stop following"

                            - if <[msg].get[1].contains[stop]> :
                                - if <[msg].get[2].contains[dig]> :
                                    - flag <npc> current_index:!
                                    - CHAT "I will stop digging"

                            - if <[msg].get[1].contains[stop]> :
                                - if <[msg].get[2].contains[path]> :
                                    - flag <npc> path_index:!
                                    - CHAT "I will stop pathing"

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '4':
                    Trigger: /follow/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].get[1].contains[follow]> :
                            - flag <npc> follow:<player>
                            - flag <npc> task:->:follow
                            - CHAT "Following"


                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '5':
                    Trigger: /build/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].get[1].contains[build]> :
                            - flag <npc> schematic:<[msg].get[2]>
                            - flag <npc> origen:<player.location>
                            - if <[msg].size.is[MORE].than[4]> :
                                - flag <npc> origen:<location[<[msg].get[3]>,<[msg].get[4]>,<[msg].get[5]>,spawn]>

                            - flag <npc> current_index:0
                            - flag <npc> task:->:build
                            - flag <npc> bloc:!
                            - run PlaceTimeout_task instantly def:<npc>
                            - CHAT "Building <[msg].get[2]>"


                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"


                '6':
                    Trigger: /take/
                    Script:
                    - define msg <context.message.split>
                    - if <[msg].get[1].contains[take]> :
                        - if <[msg].size.is[==].to[1]> :
                            #- inventory add d:<npc.inventory> o:<player.item_in_hand>
                            - give <player.item_in_hand> to:<npc.inventory>
                            - take iteminhand quantity:64
                            - CHAT "I will take"

                '7':
                    Trigger: /swap/
                    Script:

                    - if <proc[cancommand].context[<npc>|<player>]> :


                        - inventory swap d:<npc.inventory> o:<player.inventory>
                        - CHAT "I will swap"

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '8':
                    Trigger: /fill/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split.remove[1]>
                        - announce <[msg]>
                        - if <context.message.split.get[1].contains[fill]> :
                            - run Command_fill_task def:<npc>|<player>|<[msg].space_separated>

                            - CHAT "Filling <context.message>"


                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '9':
                    Trigger: /drop/
                    Script:

                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - foreach <npc.inventory.list_contents> :
                            - drop <[value]> <npc.location>

                        - inventory clear d:<npc.inventory>
                        - CHAT "I will drop"

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '10':
                    Trigger: /dig/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].get[1].contains[dig]> :
                            - flag <npc> dig:true
                            - flag <npc> length:<[msg].get[2]>
                            - flag <npc> width:<[msg].get[3]>
                            - flag <npc> height:<[msg].get[4]>
                            - flag <npc> origen:<player.location>
                            - flag <npc> report:<player>
                            - if <[msg].size.is[MORE].than[6]> :
                                - flag <npc> origen:<location[<[msg].get[5]>,<[msg].get[6]>,<[msg].get[7]>,spawn]>

                            - flag <npc> current_index:0
                            - flag <npc> task:->:dig
                            - flag <npc> schematic:!
                            - flag <npc> bloc:!
                            - define loc2 <player.location.simple.split[,]>
                            - run BreakTimeout_task instantly def:<npc>
                            - CHAT "Digging <context.message>"


                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '11':
                    Trigger: /pathadd/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].get[1].contains[pathadd]> :
                            - if <[msg].size.is[==].to[4]> :
                                - define loc1 l@<[msg].get[2]>,<[msg].get[3]>,<[msg].get[4]>,world
                                - flag <npc> path_index:!
                                - flag <npc> path_list:->:<[loc1]>
                                - CHAT "added <[loc1]>"

                            - else :
                                - flag <npc> path_index:!
                                - flag <npc> path_list:->:<npc.location>
                                - CHAT "added <npc.location>"


                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '12':
                    Trigger: /pathclear/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].get[1].contains[pathclear]> :
                            - flag <npc> path_index:!
                            - flag <npc> task:!
                            - flag <npc> path_list:!
                            - CHAT "cleared"

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '13':
                    Trigger: /pathgo/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - define msg <context.message.split>
                        - if <[msg].get[1].contains[pathgo]> :
                            - flag <npc> path_index:1
                            - flag <npc> task:->:path

                            - CHAT "pathing"

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '14':
                    Trigger: /hiring you/
                    Script:
                    - define msg <context.message.split>
                    - CHAT "Hey"
                    - if <npc.has_flag[canhire]> && !<npc.has_flag[hired_by]> :
                        - if <player.item_in_hand.material.is[==].to[diamond]> :
                            - flag <npc> hired_by:<player.name>
                            - flag <npc> hired_til:<player.item_in_hand.quantity.mul_int[3600000].add[<server.current_time_millis>]>
                            - flag <npc> bank:+:<player.item_in_hand.quantity>
                            - flag <npc> report:<player>
                            - take iteminhand quantity:64
                            - CHAT "I'm yours to command"

                        - if <player.item_in_hand.material.is[==].to[<material[bread]>]> :
                            - flag <npc> hired_by:<player.name>
                            - flag <npc> hired_til:<player.item_in_hand.quantity.mul_int[120000].add[<server.current_time_millis>]>
                            - flag <npc> food:+:<player.item_in_hand.quantity>
                            - flag <npc> report:<player>
                            - take iteminhand quantity:64
                            - CHAT "I'm yours to command"

                '15':
                    Trigger: /chest/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - run Task_chest def:<npc>

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"

                '16':
                    Trigger: /read/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - run read_book_task def:<npc>

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"
                '17':
                    Trigger: /harvest/
                    Script:
                    - if <proc[cancommand].context[<npc>|<player>]> :
                        - run Harvest_task def:<npc>

                    - else :
                        - CHAT "Hello <player.name>. You're not the boss of me"
                '94':
                    Trigger: /REGEX:.+/
                    Script:
                    - CHAT "I don't know what <context.message> is!"