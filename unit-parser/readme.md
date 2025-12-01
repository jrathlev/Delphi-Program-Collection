## Delphi Unit Parser

When creating programs with Delphi, many functions are used from user specific 
units. These units are mostly not located in the project directory but anywhere 
else. The search paths are specified in the project options.

If you want to pass the project as source to anyone, you have the problem
to know which units are needed and have to be included. Delphi itself has no
tool to do this in a clearly arranged way.

The **UnitParser** will help you. The program reads the name of the main source
(*dpr* file) and the unit search paths from the project options (*<ProjectName.dproj>*).
Then it will analyze the uses statement in all used units and create a list
sorted by search path of all units used in the project excluding system units.
The list also shows include files (*{$I ..}*) and linked object files (*{$L ..}*).

You can then copy all or some selected units to any target directory. Units that 
are not located in the project directory are copied either to the root directory, 
to a subdirectory called *Units*, or to several subdirectories, as specified in 
the project. When copying the main file (*dpr* file), the paths specified there 
for the units are adjusted accordingly.

[Application download ](https://www.rathlev-home.de/tools/download/unitparser-setup.exe)
