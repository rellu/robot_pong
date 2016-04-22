# robot_pong

Robot framework is a generic test automation framework, and now also a game development framework!

robot_pong is version of a classic game Pong implemented using Robot Framework's keyword language (and a small pygame wrapper library).

I did this demo as a joke to explore how you could use robot framework's keyword language to write "normal" programs. This example also illustrates why you really should not put complex logic in your keywords even though you can.

This project was the winner of IHP 2016 hackathon.

Implementation of the game is adopted from here: <http://trevorappleton.blogspot.fi/2014/04/writing-pong-using-python-and-pygame.html>

### install

`pip install hg+http://bitbucket.org/pygame/pygame`

`pip install robotframework`

### run

`pybot pong.robot`

### play

left side paddle is controlled using mouse

right side paddle is controlled by using arrow keys


