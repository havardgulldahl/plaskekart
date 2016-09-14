#!/bin/bash
for I in 1024 120 152 167 180 29 40 58 76 80 87; 
do
    convert -density 1200 -resize $Ix$I! weather/svg/rain.svg logo/rain-$I.png
done
