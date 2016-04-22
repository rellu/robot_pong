import pygame, sys
from pygame.locals import *

#### PYGAME
def pygame_init():
    pygame.display.set_caption('Pong')
    pygame.init()

def basic_font():
    return pygame.font.Font('freesansbold.ttf', 20)

def get_clock():
    return pygame.time.Clock()

def get_surf(width, height):
    return pygame.display.set_mode((int(width),int(height)))

def rect(left, top, width, height):
    return pygame.Rect(int(left), int(top), int(width), int(height))

def draw_rect(surface, color, rect, width=0):
    pygame.draw.rect(surface, color, rect, int(width))
    
def draw_line(surface, color, start_pos, end_pos, width=1):
    pygame.draw.line(surface, color, start_pos, end_pos, int(width))

def get_event():
    return pygame.event.get()

def update():
    pygame.display.update()

### generic
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger


def loop_forever(keyword):
    while True:
        BuiltIn().run_keyword(keyword)