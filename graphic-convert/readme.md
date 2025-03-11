## Programs for the conversion of graphics

### Creating icons from PNG or SVG images

In Windows, each application is assigned an icon that is displayed on the desktop, 
in the Start menu or in the Explorer, representing the respective program. 
program to the user. An icon can contain images in different sizes. 
Windows automatically selects the best suitable size for the current display mode. 
Common sizes are 32x32, 64x64, 128x128 and 256x256 pixels. 

To avoid having to create a separate image for each size required, it is advisable 
to first create a graphic in scalable vector format (*SVG*). The 
[Inkscape](https://inkscape.org/) program, 
for example, is suitable for this. To convert such graphics into *PNG* images of any size, *Inkscape* has a built-in export function. However, this requires some manual work if you want to do it directly from the drawing program and the *PNG* images created in this way must then be converted into an icon (*ICO* format) using a suitable conversion program.

The programs provided here simplify this process: 

- **SvgToIcon:** Creates icons from one or more selected *SVG* images using the  [SVGIconImageList](https://github.com/EtheaDev/SVGIconImageList) program package provided by [Ethea](https://www.ethea.it/docs/SVGIconImageList). The desired sizes can be selected by the user.
- **PngToIcon:** Creates an icon from any selected *PNG* images. The sizes must be 256 pixel or less. 


### Converting SVG to PNG images

- **SvgToPng:** Converts one or more selected *SVG* images into *PNG* using the routines from the *SVGIconImageList* package mentioned above. The size of the generated raster graphics results from the *width* and *height* specifications in the *SVG* files. Optionally, a scaling factor (50%, 75%, 150% or 200%) can be specified in each case.


[Application download ](https://www.rathlev-home.de/index-e.html?convert-e.html)

