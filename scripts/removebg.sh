#!/bin/bash
magick $1 -fuzz 10% -fill none -floodfill +0+0 white -shave 1x1 $1_no_bg.png
