## SVG Explorer 2.1

### Utility to explore SVG Icons on disk

The program is based on the SVG Icon Explorer by 
[Ethea](https://www.ethea.it/docs/SVGIconImageList)
, a demo program from the [SVGIconImageList](https://github.com/EtheaDev/SVGIconImageList) package. The following changes and extensions have been implemented:
- **ShellTreeView** component used for directory selection
- **Improved preview** by replacing the *TIconImage* component with *TPaintBox* for better rendering
- **Image properties** are displayed for the selected image
- **Edit button** to start an SVG editor such as [Inkscape](https://inkscape.org/) for the selected image
- **PNG export** in selectable size using the functions of *SVGIconUtils*
- **SVG optimizing** by calling the external program [SvgCleaner](https://github.com/RazrFalcon/svgcleaner) to losslessly reduce the sizes of SVG images 
- **Extended context menu** to copy and paste image files
- **Localization** using [GnuGettext for Delphi](https://github.com/jrathlev/GnuGetText-for-Delphi)

The **installation** provides an option to add entries in the **context menus** of directories and SVG files

**Languages:** English and German

[Application download ](https://www.rathlev-home.de/index-e.html?convert-e.html)

