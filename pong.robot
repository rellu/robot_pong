*** Settings ****
Library    pong_lib.py

*** Variables ****

${WINDOWWIDTH}    ${400}
${WINDOWHEIGHT}    ${300}
${LINETHICKNESS}    ${10}
${PADDLESIZE}    ${50}
${PADDLEOFFSET}    ${20}
@{BOTTOM_RIGHT}    ${WINDOWWIDTH}    ${WINDOWHEIGHT}
${SPEEDINCREASE}    ${5}
${FPS}    ${200}

*** Test Cases ***

Pong
    @{BLACK}=    create list    ${0}    ${0}    ${0}
    @{WHITE}=    create list    ${255}    ${255}    ${255}
    @{TOP_LEFT}=    create list    ${0}    ${0}
    @{BOTTOM_RIGHT}=    create list    ${WINDOWWIDTH}    ${WINDOWHEIGHT}

    ${score1}=    set variable    ${0}
    ${score2}=    set variable    ${0}

    set global variable    @{BLACK}
    set global variable    @{WHITE}
    set global variable    @{TOP_LEFT}
    set global variable    @{BOTTOM_RIGHT}
    set global variable    ${FPS}
    set global variable    ${score1}
    set global variable    ${score2}

    pygame_init

    ${BASICFONT}=    basic_font
    ${FPSCLOCK}=    get_clock
    ${DISPLAYSURF}=    get_surf    ${WINDOWWIDTH}    ${WINDOWHEIGHT}

    set global variable    ${BASICFONT}
    set global variable    ${FPSCLOCK}
    set global variable    ${DISPLAYSURF}

    ${ballX}=    evaluate    ${WINDOWWIDTH}/2 - ${LINETHICKNESS}/2
    ${ballY}=    evaluate    ${WINDOWHEIGHT}/2 - ${LINETHICKNESS}/2
    ${playerOnePosition}=     evaluate    (${WINDOWHEIGHT} - ${PADDLESIZE}) /2
    ${playerTwoPosition}=    evaluate    (${WINDOWHEIGHT} - ${PADDLESIZE}) /2

    ${ballDirX}=    set variable    ${-1}
    ${ballDirY}=    set variable    ${-1}

    ${paddle1}=    rect    ${PADDLEOFFSET}    ${playerOnePosition}    ${LINETHICKNESS}    ${PADDLESIZE}
    ${paddle2_left}=    evaluate    ${WINDOWWIDTH} - ${PADDLEOFFSET} - ${LINETHICKNESS}
    ${paddle2}=    rect    ${paddle2_left}    ${playerTwoPosition}    ${LINETHICKNESS}    ${PADDLESIZE}
    ${ball}=     rect    ${ballX}    ${ballY}    ${LINETHICKNESS}    ${LINETHICKNESS}

    set test variable    ${paddle1}
    set test variable    ${paddle2}
    set test variable    ${ballX}
    set test variable    ${ballY}
    set test variable    ${playerOnePosition}
    set test variable    ${playerTwoPosition}
    set test variable    ${ball}
    set test variable    ${ballDirX}
    set test variable    ${ballDirY}

    loop forever    main game loop


*** Keywords ***

draw arena
    call method    ${DISPLAYSURF}    fill    ${BLACK}
    ${arena_width}=    evaluate    ${LINETHICKNESS}*2
    @{arena_rect}=    create list    @{TOP_LEFT}    @{BOTTOM_RIGHT}
    draw_rect    ${DISPLAYSURF}    ${WHITE}    ${arena_rect}    ${arena_width}
    ${half_window}=    evaluate    ${WINDOWWIDTH}/2
    @{top_center}=    create list   ${half_window}    ${0}
    @{bottom_center}=    create list  ${half_window}    ${WINDOWHEIGHT}
    ${center_line_width}=    evaluate    ${LINETHICKNESS}/4
    draw_line    ${DISPLAYSURF}    ${WHITE}    ${top_center}    ${bottom_center}    ${center_line_width}

draw paddle
    [arguments]    ${paddle}
    ${bottom}=    evaluate    ${WINDOWHEIGHT} - ${LINETHICKNESS}
    ${paddle.bottom}=    run keyword if    ${paddle.bottom} > ${WINDOWHEIGHT} - ${LINETHICKNESS}    set variable    ${bottom}    ELSE    set variable    ${paddle.bottom}
    ${paddle.top}=    run keyword if    ${paddle.top} < ${LINETHICKNESS}    set variable     ${LINETHICKNESS}    ELSE    set variable    ${paddle.top}
    draw_rect    ${DISPLAYSURF}    ${WHITE}     ${paddle}

draw ball
    [arguments]    ${ball}
    draw rect    ${DISPLAYSURF}    ${WHITE}     ${ball}


move ball
    [arguments]    ${ball}    ${ballDirX}    ${ballDirY}
    ${new_x}=    evaluate    ${ball.x}+${ballDirX}*${SPEEDINCREASE}
    ${new_y}=    evaluate    ${ball.y}+${ballDirY}*${SPEEDINCREASE}

    ${ball.x}=    set variable    ${new_x}
    ${ball.y}=    set variable    ${new_y}
    [return]    ${ball}

check edge collision
    [arguments]    ${ball}    ${ballDirX}    ${ballDirY}

    ${ballDirY}=    run keyword if    ${ball.top} == (${LINETHICKNESS}) or ${ball.bottom} == (${WINDOWHEIGHT} - ${LINETHICKNESS})    evaluate    ${ballDirY} * -1    ELSE    set variable    ${ballDirY}
    ${ballDirX}=    run keyword if    ${ball.left} == (${LINETHICKNESS}) or ${ball.right} == (${WINDOWWIDTH} - ${LINETHICKNESS})    evaluate    ${ballDirX} * -1    ELSE    set variable    ${ballDirX}
    [return]    ${ballDirX}    ${ballDirY}

check hit ball
    [arguments]    ${ball}    ${paddle1}    ${paddle2}    ${ballDirX}
    run keyword if    ${ballDirX} == -1 and ${paddle1.right} == ${ball.left} and ${paddle1.top} < ${ball.top} and ${paddle1.bottom} > ${ball.bottom}    return from keyword    -1    ELSE IF    ${ballDirX} == 1 and ${paddle2.left} == ${ball.right} and ${paddle2.top} < ${ball.top} and ${paddle2.bottom} > ${ball.bottom}    return from keyword    -1    ELSE    return from keyword    1

check point scored
    [arguments]    ${ball}    ${score1}    ${score2}    ${ballDirX}
    ${score1}=    run keyword if    ${ball.left} == ${LINETHICKNESS}    evaluate    ${score1}+1    ELSE    set variable    ${score1}
    ${score2}=    run keyword if    ${ball.right} == ${WINDOWWIDTH} - ${LINETHICKNESS}    evaluate    ${score2}+1    ELSE    set variable    ${score2}
    [return]    ${score1}    ${score2}

draw scores
    [arguments]    ${score1}    ${score2}
    ${disp1}=    convert to string    ${score1}
    ${disp2}=    convert to string    ${score2}
    ${score1surf}=    call method    ${BASICFONT}    render    ${disp1}    ${TRUE}    ${WHITE}
    ${score2surf}=    call method    ${BASICFONT}    render    ${disp2}    ${TRUE}    ${WHITE}
    ${resultRect1}=    call method    ${score1surf}    get_rect
    ${resultRect2}=    call method    ${score2surf}    get_rect
    ${resultRect2.topleft}=    evaluate    (${WINDOWWIDTH} - 250, 25)
    ${resultRect1.topleft}=    evaluate    (${WINDOWWIDTH} - 150, 25)
    call method    ${DISPLAYSURF}    blit    ${score1surf}    ${resultRect1}
    call method    ${DISPLAYSURF}    blit    ${score2surf}    ${resultRect2}

handle key press
    [arguments]    ${event}    ${paddle2.y}
    ${ret}=    run keyword if    ${event.key} == 273    evaluate    ${paddle2.y}-10    ELSE IF    ${event.key} == 274    evaluate    ${paddle2.y}+10    ELSE    set variable    ${paddle2.y}
    [return]    ${ret}

main game loop
    ${QUIT}=    set variable    ${12}
    ${MOUSEMOTION}=    set variable    ${4}
    ${KEY}=    set variable   ${3}
    ${events}=     get_event
    :FOR    ${event}    IN    @{events}
    \    run keyword if    ${event.type} == ${QUIT}    FAIL
    \    ${paddle1.y}=    run keyword if    ${event.type} == ${MOUSEMOTION}    set variable    ${event.pos[1]}    ELSE    set variable    ${paddle1.y}
    \    ${paddle2.y}=    run keyword if    ${event.type} == ${KEY}   handle key press    ${event}    ${paddle2.y}    ELSE    set variable    ${paddle2.y}

    draw arena
    draw paddle    ${paddle1}
    draw paddle    ${paddle2}
    draw ball    ${ball}
    ${ball}=    move ball    ${ball}    ${ballDirX}    ${ballDirY}
    set test variable    ${ball}
    ${ballDirX}    ${ballDirY}=    check edge collision    ${ball}    ${ballDirX}    ${ballDirY}
    set test variable    ${ballDirX}
    set test variable    ${ballDirY}
    ${check_hit_coefficient}=    check hit ball    ${ball}    ${paddle1}    ${paddle2}    ${ballDirX}

    ${ballDirX}=    evaluate    ${ballDirX} * ${check_hit_coefficient}
    set test variable    ${ballDirX}
    ${score1}    ${score2}=    check point scored    ${ball}    ${score1}    ${score2}    ${ballDirX}
    set test variable    ${score1}
    set test variable    ${score2}
    draw scores    ${score1}    ${score2}

    update
    call method    ${FPSCLOCK}    tick    ${FPS}

