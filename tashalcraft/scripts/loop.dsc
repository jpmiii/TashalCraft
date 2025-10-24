Inner_loop:
    type: task
    debug: false
    definitions: NPC
    script:

    # - foreach <server.npcs> :
    #     - if <[NPC].is_spawned> :
            - run Book_task def:<[NPC]>
            - if <[NPC].has_flag[task]> :
                - if <[NPC].has_flag[path_index]> && !<[NPC].has_flag[hold]> :
                    - define l <[NPC].flag[path_list].get[<[NPC].flag[path_index]>]>
                    #- announce "<[l]> <[NPC].flag[path_index]>"
                    - if <[l].y.is[MORE].than[0]> && <[l].distance_squared[<[NPC].location>].is[MORE].than[9]> :
                        - if <[l].distance_squared[<[NPC].location>].is[MORE].than[900]> :
                            - flag <[NPC]> path_index:!
                            - flag <[NPC]> task:!
                            - flag <[NPC]> fails:0

                        - else :
                        #

                            - if <[NPC].has_flag[fails]> :
                                - if <[NPC].flag[fails].is[MORE].than[2]> :
                                    - run Load_area_task def:<[l]>|<[NPC]>
                                    - if <[NPC].flag[fails].is[MORE].than[50]> :
                                        - define msg "<[NPC].name> <[l].simple> <red> MOVE FAIL: <[NPC].flag[fails]>"

                                    - if <[NPC].flag[fails].is[MORE].than[100]> :
                                        - flag <[NPC]> path_index:!
                                        - flag <[NPC]> task:!
                                        - flag <[NPC]> fails:0
                                        - walk <[NPC]> stop
                                        - define msg "<red>FAILED OUT! <[NPC].is_navigating> "
                                        - run Report_task def:<[NPC]>|<[msg]>

                                - flag <[NPC]> fails:++

                            - else :
                                - flag <[NPC]> fails:0

                            - walk <[NPC]> <[l]> speed:1.5
                            - flag <[NPC]> hold:moveing expire:30s
                            #- announce "walk path"


                    - else :
                        - if <[l].y.is[LESS].than[0]> :
                            - flag <[NPC]> hold:wait duration:<[l].y.abs>s

                        - flag <[NPC]> path_index:++
                        - flag <[NPC]> fails:0
                        - if <[NPC].flag[path_index].is[MORE].than[<[NPC].flag[path_list].size>]> :
                            - if <[NPC].flag[path_list].size.is[LESS].than[2]> :
                                - flag <[NPC]> path_index:!
                                - flag <[NPC]> task:!

                            - else :
                                - flag <[NPC]> path_index:1
                                - flag <[NPC]> hold:loop duration:30s
                                #- announce "<[NPC].name> looped"

                - if <[NPC].has_flag[follow]> && !<[NPC].has_flag[hold]> :
                    - define p <[NPC].flag[follow]>
                    - if <[p].location.distance_squared[<[NPC].location>].is[MORE].than[25]> :
                        - if <[p].location.distance_squared[<[NPC].location>].is[MORE].than[2500]> :
                            - flag <[NPC]> follow:!
                        - else :
                            - define rndx <util.random.int[1].to[7].add_int[-4]>
                            - define rndz <util.random.int[1].to[7].add_int[-4]>
                            - walk <[NPC]> <[p].location.add[<[rndx]>,0,<[rndz]>]> speed:1.5
                            - flag <[NPC]> hold:moveing expire:3s
                            #- announce "walk follow"

                - if <[NPC].has_flag[current_index]> && !<[NPC].has_flag[hold]> :
                    #- announce "<[NPC].flag[current_index]>"
                    - if <[NPC].flag[placetimeout].is[LESS].than[<server.current_time_millis>]> :
                        - if <[NPC].flag[placetimeout].is[!=].to[-1]> :

                            - if <[NPC].has_flag[bloc]> :
                                - run Fill_task instantly def:<[NPC]>

                            - if <[NPC].has_flag[schematic]> :
                                - run Build_task instantly def:<[NPC]>

                            - if <[NPC].has_flag[dig]> :
                                - run Dig_task instantly def:<[NPC]>

                        - else :
                            - if <[NPC].has_flag[bloc]> :
                                - flag <[NPC]> current_index:++

                            - if <[NPC].has_flag[schematic]> :
                                - flag <[NPC]> current_index:++
                                - run PlaceTimeout_task instantly :<[NPC]>

                            - if <[NPC].has_flag[dig]> :
                                - flag <[NPC]> current_index:++
                                - run BreakTimeout_task instantly def:<[NPC]>

