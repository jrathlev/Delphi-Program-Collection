(* Delphi-Unit
   Universal-Plotroutinen, CALCOMP-ähnlich
   für Bildschirm und Drucker
   Plotkoordinaten: cm oder inch (Standard: cm)

   © Dr. J. Rathlev, D-24222 Schwentinental (info(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Okt. 1995
   Vers. 2 - Okt. 1996
   Vers. 3 - Jun. 2001
   Vers. 3.1 - Mai 2005 added: TimeAxis
   Vers. 3.2 - Dez. 2006 fixed: sub- and superscript in PlotStr
   Vers. 3.3 - Mai 2021: Skalierung von Zeitachsen über viele Tage
   Vers. 3.4 - Juli 2023: optionale Beschriftung der X-Achse nur bis angegebenen
                          Maximalwert (z.B. für Tage des Monats)
   Vers. 3.5 - Juni 2024: eigene Farbe für Rasterlinien

   letzte Änderung: Juni 2023

 Hinweise zur Benutzung:
 -----------------------
 1. TPLOT:
   Die nachfolgenden Routinen (enthalten im Objekt "TPLOT") ermöglichen
   die Erstellung von maßstabsgerechten Grafiken auf dem Drucker. Die
   Bildschirmanzeige ist an jedes Fenster anpaßbar. Zur Ausgabe einer
   Grafik auf Bildschirm und/oder Drucker muß jeweils eine eigene
   TPLOT-Instanz mit dem Gerätespezifischen Canvas vorhanden sein.
   Das aufrufende Programm sollte sich an folgendes Schema halten:

   uses ... Printers, WinPlot, ...;

   var
     PrPlot,GrPlot  : TPlot;
     PrSize         : TFPoint;  { Papiergröße in cm/inch }
     Rand           : TFRect;   { Ränder in cm/inch }
     GrSize         : TPoint;   { Bildschirmgrafikfenster in Pixel }

   { Unterroutine Grafik zeichnen (Beispiel)}
   procedure ZeichneGrafik (Plot : TPlot);
   begin
     with Plot do begin
       StartPlot(true,white);               { Zeichenfeld löschen, Farbe weiß }
       CPlot(x0,y0,pmUpOrigin,mmNoMark);    { Nullpunkt festlegen }
       DefUserField (ufAbs,-dx0,dx0,-dy0,dy0);  { Zeichenfeld rel. zu Nullpunkt
                                              festlegen }
       SetTextHeight(0.5);
       PlotStr (0.0,dy0-0.1,'zentrierte Überschrift',alCenterTop,black);
       ...
       DefUserScale (1,stHorLin,0.0,100.0);   { Skalierung X-Achse in Benutzereinheiten}
       DefUserScale (5,stVertLin,min,max);    { Skalierung Y-Achse in Benutzereinheiten}
       Axis (1,scal(5,Min),10.0,5,[asGrid,asBottom],black);     { X-Achse ohne Raster, Beschriftung
                                          alle 10 Einh., 5 Unterteilungen }
       Axis (5,scal(1,0.0),GetGrid(5),10,[asGrid,asLeft],black);  { Y-Achse mit Raster, automatische
                                          Skalenmarken, 10 Unterteilungen }
       ...
       PlMode:=pmUp;
       repeat
         ...
         CPlot(x,y,PlMode,mmTriangle);  { Linie nach x,y mit Markierung }
         PlMode:=pmDown;
         until ....
       ...
       end;
     end;

   ...

   begin
     ...
     { Bildschirm }
     GrPlot:=TPlot.Create (Canvas);
     ...
     { Definition der Einheiten (bei metrisch nicht erforderlich) }
     GrPlot.Units:=unMetric;           {oder unEnglish }

     { Grafikgröße an Papierformat anpassen }
     with PrSize do GetPaperSize (Printer,X,Y);       { in cm/inch }
     GetDefMargins (Printer.Orientation,Rand);        { Standardränder }

     { Zeichenfeld definieren }
     GrPlot.SetPlotField (PrSize,Rand);

     { Bildschirmfenster }
     with GrSize do begin
       X:=640; Y:=480;     { oder an Form.Width/Height anpassen }
       end;
     ...
     { Drucker }
     with Printer do begin
       ...
       BeginDoc;
       Title:=''...':
       PrPlot:=TPlot.Create (Canvas);
       { Zeichenfeld definieren }
       PrPlot.SetPlotField (PrSize,Rand);
       PrPlot.SetPrintWindow (shMargin);  [Druckausgabe mit Rand }
       {Grafik zeichnen }
       ZeichneGrafik (PrPlot);
       PrPlot.Free;
       EndDoc;
       end;
     ...
   end;

   { Routine für OnPaint-Ereignis }
   procedure TFormxxx.OnPaint(Sender: TObject);
   begin
   GrPlot.SetScreenWindow (shNoMargin,GrSize); { Bildschirmausgabe ohne Rand }
   {Grafik zeichnen }
   ZeichneGrafik (GrPlot);
   end;

   2. Kopieren in die Zwischenablage:
    procedure TForm1.CopyItemClick(Sender: TObject);
    var
      FMeta    : TMetaFile;
      MfPlot   : TPlot;
      ACanvas  : TMetaFileCanvas;
      Mf       : word;
      AData    : THandle;
      APal     : HPalette;
      ClipRect : TRect;
      d        : integer;
    begin
      FMeta:=TMetaFile.Create;
      with GrPlot do if FrameOn then begin    // Ausschnitt in FramePos (Pixelkoord.)
        with FramePos do begin
          ClipRect:=FramePos;
          with ClipRect do begin
            if Left>Right then begin
              d:=Left; Left:=Right; Right:=d;
              end;
            if Top<Bottom then begin
              d:=Top; Top:=Bottom; Bottom:=d;
              end;
            end;
          end;
        end
      else begin               // ganzes Bild
        ClipRect:=WindField;
        end;
      with FMeta,ClipRect do begin
        MMWidth:=(Right-Left)*10;                   // Größe in 0,01 mm
        MMHeight:=(Top-Bottom)*10;
        end;
      ACanvas:=TMetaFileCanvas.Create (FMeta,0);
      MfPlot:=TPlot.Create(ACanvas);                // Plotobjekt auf MetaFileCanvas
      with MfPlot do begin
        PlotField:=GrPlot.PlotField;                // Größe von GrPlot übernehmen
        WindField:=GrPlot.WindField;
        SetClipWindow (ClipRect);                   // Abbildung auf Ausschnitt
        SetReverseDir(true);                        // Drehwinkel für Schrift
        end;
      Plot... (MfPlot)                              // Zeiche Bild
      MfPlot.Free;
      ACanvas.Free;
      FMeta.SaveToClipBoardFormat(Mf,AData,APal);
      ClipBoard.SetAsHandle(Mf,AData);
      FMeta.Free;
      end;

   *)

unit Winplot;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Printers, Vcl.ClipBrd,
  WinUtils, StringUtils;

type
  TUnits = (unMetric,unEnglish);
  TShowMargin = (shNoMargin,shMargin);
  TLineStyle = (lsNone,lsSolid,lsDashed,lsDotted);

  TAxis = record
    Digits        : integer;
    Abst,XG,XF,
    TSz,LnTh      : double;
    end;

  (* Skalierungstypen (lin/log), (hor/vert) *)
  TScaleType = (stLin,stLog,stHor,stVert);
  TScaleTypes = set of TScaleType;

  (* Achsentypen
   asGrid        = mit langen Rasterlinien bei den groben Skal.marken
   asNoText      = ohne Beschriftung
   asCenterText  = Beschriftung in der Mitte zwischen den Skalenmarken
   asPrefix      = Beschriftung unter Benutzung der
                   Einheitenvorsätze (z.B. m (Milli), k (Kilo))
   asFixed       = Beschriftung im ffFixed-Format
   asTop         = Beschriftung oberhalb der Hor.Achse
   asBottom      = Beschriftung unterhalb der Hor.Achse
   asLeft        = Beschriftung links der Vert.Achse
   asRight       = Beschriftung rechts der Vert.Achse
   asRotate      = Text in Achsenrichtung drehen
   asNoZero      = kein Beschriftung bei Wert = 0
   asWeekday     = Zeitachse mit Wochentag
   *)
  TAxisStyle = (asGrid,asNoText,asCenterText,asPrefix,asFixed,asLeft,asTop,
                asRight,asBottom,asRotate,asNoZero,asWeekday);
  TAxisStyles = set of TAxisStyle;


  (* Umrechnungsfaktoren: Benutzerkoord. ==> cm/inch *)
  TUserScale = record
    lin,                      (* lin/log *)
    hor            : boolean; (* hor./vert. Achse *)
    scanf,scend,              (* Anfang, Ende in Benutzerkoord. *)
    scfak,scoff    : double;  (* Skal.faktor und Offset *)
    end;

const
  varMax = 8;          (* max. Anzahl von variablen *)
  AutoDig = -999;      (* automatische Bestimmung der signif. Stellen bei
                          der Beschriftung der Achsen *)

  (* Standard-Achsentypen *)
  stHorLin = [stHor,stLin];
  stVertLin = [stVert,stLin];
  stHorLog = [stHor,stLog];
  stVertLog = [stVert,stLog];

  OneInch = 2.54;
  PtToCm = OneInch/72;

  (* Standardränder für Quer- und Hochformat in cm
    GetPapersize liefert eine Seitengröße, die pro Rand um jeweils 0,5 cm
    verkleinert ist *)
  QMetrRand : TFRect = (Left : 0.0; Top : 1.0; Right : 0.0; Bottom : 0.0);
  HMetrRand : TFRect = (Left : 1.0; Top : 0.0; Right : 0.0; Bottom : 0.0);
  QInchRand : TFRect = (Left : 0.0; Top : 0.4; Right : 0.0; Bottom : 0.0);
  HInchRand : TFRect = (Left : 0.4; Top : 0.0; Right : 0.0; Bottom : 0.0);
  OhneRand  : TFRect = (Left : 0.0; Top : 0.0; Right : 0.0; Bottom : 0.0);

  (* TP-Farbnamen *)
  Black = 0;
  Blue  = 1;
  Green = 2;
  Cyan  = 3;
  Red   = 4;
  Magenta = 5;
  Brown = 6;
  LightGray = 7;
  DarkGray = 8;
  LightBlue = 9;
  LightGreen = 10;
  LightCyan =11;
  LightRed = 12;
  LightMagenta = 13;
  Yellow =14;
  White = 15;

  (* TP-Standardfarbpalette *)
  MaxColors = 15;

type
  TColorList = array [0..MaxColors] of TColor;

const
{  PDummy : array [0..127] of word = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
}
{  clMaroon = TColor($004488);
  clGreen = TColor($008400);
  clOlive = TColor($008888);
  clNavy = TColor($880000);
  clPurple = TColor($880088);
  clTeal = TColor($888800);
  clGray = TColor($888888);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00F000);
  clYellow = TColor($00F8F8);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($F000F0);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($B0B0B0);
  clDkGray = TColor($808080);}

  clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);
  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0);
  clDkGray = TColor($808080);
  clBrown = TColor($004080);

  clColor01 = TColor($CC0000); (* dunkelblau *)
  clColor02 = TColor($00B200); (* dunkelgrün *)
  clColor03 = TColor($808000); (* dunkelcyan *)
  clColor04 = TColor($0000FF); (* rot *)
  clColor05 = TColor($C400C4); (* magenta *)
  clColor06 = TColor($004080); (* brown *)
  clColor07 = TColor($808080); (* dunkelgrau *)
  clColor08 = TColor($C0C0C0); (* hellgrau *)
  clColor09 = TColor($FF7575); (* hellblau *)
  clColor10 = TColor($00FF00); (* hellgrün *)
  clColor11 = TColor($FFFF00); (* hellcyan *)
  clColor12 = TColor($0080FF); (* orange *)
  clColor13 = TColor($FF80FF); (* hellviolett *)
  clColor14 = TColor($00FFFF); (* gelb *)

  StdPlotColor : TColorList
             = (clBlack,clColor01,clColor02,clColor03,
                clColor04,clColor05,clColor06,clColor07,
                clColor08,clColor09,clColor10,clColor11,
                clColor12,clColor13,clColor14,clWhite);

{ PlotColor : TColorList
             = (clBlack,clNavy,clGreen,clTeal,
                clMaroon,clPurple,clBrown,clDkGray,
                clLtGray,clBlue,clLime,clAqua,
                clRed,clFuchsia,clYellow,clWhite);}

  (* TP-Linien-Stilnamen *)
  SolidLn = 0;
  DottedLn = 1;
  CenterLn = 2;
  DashedLn = 3;
  UserBitLn = 4;

  (* TP-Standardstile *)
  MaxStyle = 4;
  PlotStyle : array [0..MaxStyle] of TPenStyle
             = (psSolid,psDot,psDashDot,psDash,psDashDotDot);

  (* Textstile *)
  tsNormal = 0;
  tsItalic = 1;
  tsBold = 2;
  tsBoldItalic = 3;

  MaxFontStyle = 3;
  PlotFontStyle : array [0..MaxFontStyle] of TFontStyles
             = ([],[fsItalic],[fsBold],[fsItalic]+[fsBold]);

  DefFontHeight = 0.5;       (* in cm *)
  DefFontName = 'Arial';
  DefFontAngle = 0.0;      (* Textrichtung = 0° *)

  DefSymbolHeight = 0.4;    (* Symbolgröße CPLOT in cm *)

  (* Textausrichtungen in PlotStr *)

  alLeftBottom = 1;
  alLeftCenter = 2;
  alLeftTop = 3;
  alCenterBottom = 4;
  alCenterAll = 5;
  alCenterTop = 6;
  alRightBottom = 7;
  alRightCenter = 8;
  alRightTop = 9;

  (* Penmodes in CPlot *)
  pmOld = 1;
  pmDown = 2;
  pmUp =3;
  pmOldScal =11;
  pmDownScal = 12;
  pmUpScal = 13;
  pmOldOrigin = -1;
  pmDownOrigin = -2;
  pmUpOrigin = -3;

  (* Markentypen in CPlot *)
  mmNoMark = 0;
  mmPlus = 1;
  mmCross = 2;
  mmTriangle = 3;
  mmSquare = 4;
  mmOctagon = 5;

  (* Zeichenfeld definieren (absolut oder relativ)*)
  ufAbs=1;
  ufRel=2;

  (* Standarddefinitionen für Achsen *)
  MetrAchse : TAxis = (Digits : AutoDig; (* automatisch Auswahl der sign. Stellen der
                                            Beschriftung *)
                       Abst : 0.25;  (* Abstand der Beschriftung von der Achse *)
                       XG   : 0.17;  (* Länge der Grobskalierungsstriche *)
                       XF   : 0.08;  (* Länge der Feinskalierungsstriche *)
                       TSz  : 0.3;   (* Textgröße *)
                       LnTh : 0.03); (* Dicke der Linien in cm *)

  InchAchse : TAxis = (Digits : AutoDig; (* automatisch Auswahl der sign. Stellen der
                                            Beschriftung *)
                       Abst : 0.1;   (* Abstand der Beschriftung von der Achse *)
                       XG   : 0.06;  (* Länge der Grobskalierungsstriche *)
                       XF   : 0.02;  (* Länge der Feinskalierungsstriche *)
                       TSz  : 0.12;  (* Textgröße *)
                       LnTh : 0.01); (* Dicke der Linien in inch *)

var
  PlotColor : TColorList;

type
  (* Plot-Routinen für Bildschirm und Drucker *)
  TPlot = class (TObject)
  private
    (* Einheiten festlegen *)
    procedure SetUnits (NewUnits : TUnits);

    (* Einheiten abfragen *)
    function GetUnits : TUnits;

    (* OEMConvert setzen *)
    procedure SetOEMConvert (OEM : boolean);

  protected
    POEMConvert     : boolean;

    (* Hintergrundfarbe setzen *)
    procedure SetBgColor (Color : TColor);

    (* Hintergrundfarbe lesen *)
    function GetBgColor : TColor;

    (* TP-Farbe umsetzen *)
    function ConvColor (Farbe : word) : TColor;

    (* Stiftfarbe setzen *)
    procedure SetPenColor (Color : TColor);

    (* Stiftfarbe lesen *)
    function GetPenColor : TColor;

    (* neuen Font erzeugen *)
    procedure CreateNewFont (var NewFont,OldFont : HFont);

    (* neuen Font entfernen *)
    procedure DeleteNewFont (var NewFont,OldFont : HFont);

  protected
    PlotUnits       : TUnits;
    scx0,scy0       : double; (* Skal.faktoren cm <==> Drucker-/Bildsch.koord. *)
    PenStat         : integer;(* Penstatus *)
    ActPenColor,              (* Stiftfarbe *)
    ActBgColor      : TColor; (* Hintergrundfarbe *)
    ActBgTPFarbe    : word;   (* Index Hintergrundfarbe (TP-komp.)  *)
    Posit,                    (* akt. Plotposition in cm *)
    UserOrigin      : TFPoint;(* Nullpunkt für rel. Koord. in cm *)
    Offset,Fac      : TFPoint;
    Xsc             : array [1..varMax] of TUserScale;
    Tsc             : TUserScale;  // Zeitachse
    TextStyle       : TFontStyles;
    TextHgt,                   (* Textgröße in cm *)
    TextAngle       : single;  (* Textrichtung in Grad (math pos.) *)
    TextBackMode,              (* Text mit transparentem Hintergrund *)
    RotReverse,                (* Drehrichtung bei Textdrehung invertieren
                                  (nur für Einf. von Clipboard in OpenOffice) *)
    FontChange      : boolean;
    FXMaxLabel      : double;   (* max. Wert der x-Beschriftung, 0 = alle *)

  public
    PlotCanvas      : TCanvas;
    PlotField,
    UserField       : TFRect; (* Plotfeld für Koord.syst. in cm *)
    PaperField,
    WindRand,
    WindField       : TRect;  (* min./max. Koord. in Pixel *)
    AxisProperties  : TAxis;  (* Konstanten für Routine Axis *)
    Ratio,
    SymbolHeight    : double; (* Symbolgröße für CPLOT *)

    constructor Create (NewCanvas : TCanvas); virtual;
    constructor Create1;

    (* Windows-Stiftfarbe *)
    property PenColor : TColor read GetPenColor write SetPenColor;

    (* Windows-Hintergrundfarbe bei Texten *)
    property BackColor : TColor read GetBgColor write SetBgColor;

    (* Einheiten *)
    property Units : TUnits read GetUnits write SetUnits;

    (* max. Wert der x-Beschriftung, 0 = alle *)
    property XMaxLabel : double read FXMaxLabel  write FXMaxLabel;

    (* Papiergröße in cm ermitteln *)
    procedure GetPaperSize (APrinter         : TPrinter;
                            var Width,Height : double);

    (* Standardränder holen *)
    procedure GetDefMargins (Orientation : TPrinterOrientation;
                             var Margin  : TFRect);

   (* Plotfeld initialisieren *)
    procedure SetPlotField (ASize : TFPoint;
                            ARand : TFRect);

    function InPlotField (ix,iy : integer) : boolean;

    (* Fenster für Drucker festlegen
       ShowRand : Ränder anzeigen ein/aus *)
    procedure SetPrintWindow (ShowRand : TShowMargin);

    (* Fenster für Clipboard festlegen *)
    procedure SetClipWindow (Rect : TRect);

    (* Fenster für Bildschirm festlegen
       ShowRand : Ränder anzeigen ein/aus *)
    procedure SetScreenWindow (ShowRand : TShowMargin;
                               Size     : TPoint);

    (* Fensterausschnitt für Bildschirm festlegen *)
    procedure SetScreenWindowEx (WinSize,Origin : TPoint;
                                 Zoom           : TFPoint);

    (* aktuelle Abmessungen des Zeichenfensters *)
    procedure GetActWindow (var x,y : word);

    (* Bildschirmkoordinaten umrechnen *)
    procedure ViewToWindow (var Pt : TPoint);
    procedure WindowToView (var Pt : TPoint);

    (* Rahmen zeichnen *)
    procedure PlotFrame (Border : TRect;
                         FCol   : TColor;
                         FStyle : TPenStyle;
                         FMode  : TPenMode);

    (* Fademkruez zeichnen *)
    procedure PlotCrosshair (Center : TPoint;
                             FCol   : TColor;
                             FStyle : TPenStyle;
                             FMode  : TPenMode);

    (* Vordergrundfarbe oder Stift wechseln (TP-kompatibel) *)
    procedure SetColor (TPFarbe : word);

    (* Hintergrundfarbe setzen, bzw. lesen (TP-kompatibel) *)
    function SetBackColor (TPFarbe : word) : word;
    function GetBackColor : word;

    (* Linientyp verändern *)
    procedure SetLineStyle (Typ : word);
    (*   0 = durchgezogen, 1 = gepunktet, 2 = Strich-Punkt,
         3 = gestrichelt , 4 = Strich-Punkt-Punkt *)

    (* Linienbreite in 1/10 mm *)
    function GetLineWidth : word;
    procedure SetLineWidth (Width : word);

    (* Textmodus: ANSI oder OEM *)
    property OEMConvert : boolean read POEMConvert write SetOEMConvert;

    (* Texthöhe in cm berechnen *)
    function GetTextHeight : double; virtual;

    (* Textbreite in cm berechnen *)
    function GetTextWidth (s : string) : double; virtual;

    (* Textfont ändern  *)
    procedure SetTextFont (FName : string);

    (* Textgröße ändern (Size in cm) *)
    procedure SetTextHeight (ASize : double); virtual;

    (* Textgröße ändern (Size in pt) *)
    procedure SetTextSize (ASize : double); virtual;

    (* Schriftstil setzen *)
    procedure SetTextStyle (Style : word); virtual;

    (* Textrichtung setzen *)
    procedure SetTextDir (Angle : double); virtual;

    (* invertierte Drehrichtung für Text *)
    procedure SetReverseDir (Reverse : boolean);

    (* transparenter Hintergrund bei Textausgabe *)
    procedure SetTransparent (ATrans : boolean);

    (* Symbolgröße ändern (Size in cm) *)
    procedure SetSymbolSize (Size : double);

    (* nach X,Y bewegen *)
    procedure MoveA (X,Y : double);

    (* nach X,Y zeichnen *)
    procedure DrawA (X,Y : double);

    (* Umrechnung von abs. cm auf Bildschirmkoord. *)
    procedure RawScale (x,y       : double;
                        var gx,gy : integer);

    (* Umrechnung von abs. cm auf Bildschirmkoord.
       mit Prüfung auf Begrenzung durch WindField*)
    procedure Scale (x,y       : double;
                     var gx,gy : integer);

    (* Umrechnung von Bildschirmkoordinaten nach abs. cm *)
    procedure InvScale (gx,gy   : integer;
                        var x,y : double);

    (* Umrechnung von cm relativ zu Origin nach Pixel *)
    procedure CScale (X,Y       : double;
                      var IX,IY : integer);

    (* Umrechnung von Pixel nach cm relativ zu Origin *)
    procedure InvCScale (ix,iy   : integer;
                         var x,y : double);

    (* Drucker- oder Bildschirmgrafik initialisieren *)
    procedure InitPlot (Clear  : boolean;
                        Col    : TColor);
                        
    (* Grafik starten *)
    procedure StartPlot (Clear  : boolean;
                         BakCol : word);

    (* Grafik beenden *)
    procedure EndPlot;

    (* Zeichnen einer Linie (ähnlich zur Calcomp-Routine PLOT *)
    procedure CPlot (XIN,YIN      : double;
                     PenMode      : integer;
                     Mark         : integer = mmNoMark);

    procedure PlotLine (x,y : double; ACol : TColor; AStyle : TLineStyle; AMd : TPenMode = pmCopy);

    (* Zeichnen eines Punktes *)
    procedure PlotDot (x,y : double;
                       Col : TColor);

    (* Rechteck mit Farbe füllen *)
    procedure PlotRect (x1,y1,x2,y2 : double;
                        Col         : TColor);

    (* Polygon mit Farbe füllen *)
    procedure PlotPoly (const FPoints : array of TFPoint;
                        Col           : TColor);

    procedure PlotBitmap (x,y,w,h : double;
                          Bitmap  : TBitmap); overload;

    procedure PlotBitmap (x,y,w,h : double; BCol,RCol : TColor;
                          Bitmap  : TBitmap);  overload;

    procedure PlotPicture (x,y,w,h : double;
                           Picture : TPicture);

    (* Löschen eines Bildausschnitts, Koord. in cm *)
    procedure ClrBox (x1,y1,x2,y2 : double;
                      Bak         : word);

   (* String in der Länge beschneiden *)
    function StrTrunc (s : String;
                       x : double) : String;

    (* Ausgabe eines Strings (ASCII) in TP-kompatibler Farbe *)
    procedure PlotStr (X,Y       : double;
                       S         : string;
                       Format    : boolean;
                       Align,
                       TPFarbe   : word); virtual;

    (* Ausgabe eines Strings (ASCII) in best. Font *)
    procedure PlotFontStr (X,Y       : double;
                           S         : string;
                           Format    : boolean;
                           Align     : word;
                           Farbe     : TColor;
                           FName     : string);

    (* Ausgabe eines Strings (ASCII) *)
    procedure PlotColStr (X,Y       : double;
                          S         : string;
                          Format    : boolean;
                          Align     : word;
                          Farbe     : TColor); virtual;
    (* X, Y    : - Koordinaten des Strings in cm (linke untere Ecke)
       S       : - Text (im Text: _ ==> nachfolg. Text tiefstellen (rel.)
                                  ^ ==> nachfolg. Text hochstellen (rel.)
                         Bsp.: x_1^^2  = x (index) 1 hoch 2 )
       Align   : Textausrichtung rel. zu X,Y (siehe alXXX-Konstanten)
       TPFarbe : Textfarbe (siehe TP-Farbkonstanten) *)

    (* Die nachfolgenden Routinen ANumb und ZNumb sind aus
       Kompatbilitätsgründen noch enthalten.
       Stattdessen sollten besser die Routinen StrInt und StrDbl aus
       NumberUtils oder die Delphi-Bibliotheksfunktionen IntToStr, FloatToStr(F)
       benutzt werden *)
    (* Konvertieren einer Zahl in einen String, z.B. für die Skalenbeschriftung *)
    function ANumb (F   : double;
                    N   : integer) :  string;
    (* Zahl mit Stellenzwischenraum *)
    function ZNumb (x : double;
                    n : integer) : string;
    function FloatToPlotStr (Value   : double;
                    n : integer) : string;

    (* Vorgabe des Feldes in cm für das Benutzer-Koordinatensystem *)
    procedure DefUserField (Mode        : integer;
                            XL,XR,YU,YO : double);

    (* Prüfen, ob Wert im Benutzerfeld liegt *)
    function InUserField (x,y : double) : boolean;

    (* Definition der Skalierung in Benutzerkoordinaten *)
    procedure DefUserScale (varNr   : integer;
                            ScalTyp : TScaleTypes;
                            XLL,XUR : double);
    (*  varNr =    Nummer der variable (1 .. varMax)
        ScalTyp =  hor./vert, lin/log (siehe oben, stXXX-Konst.)
        XLL   =    hor. Achse:  linker Rand
                   vert. Achse: unterer Rand
        XUR   =    hor. Achse:  rechter Rand
                   vert. Achse: oberer Rand *)

    (* Umrechnung von abs. Benutzerkoord. auf cm *)
    function UserScale (varNr : integer;
                        Val   : double) : double;

    (* Umrechnung von rel. Benutzerkoord. auf cm *)
    function RelUserScale (varNr : integer;
                           Val   : double) : double;

    (* Umrechnung von cm auf Benutzerkoord. *)
    function InvUserScale (varNr : integer;
                           Val   : double) : double;

    (* Prüfen, ob Wert im zulässigen Bereich liegt *)
    function InUserRange (varNr   : integer;
                          var Val : double) : boolean;

    (* Bereichsanfang *)
    function GetUserMinValue(varNr : integer) : double;

    (* Bereichsende *)
    function GetUserMaxValue(varNr : integer) : double;

    (* individuelle Achseneigenschaften setzen *)
    procedure SetAxisProp (ADec : integer;
                           ASize,AThick,ADist,ACoLen,AFiLen : double);

    (* eine Koordinatenachse (lin/log) mit Beschriftung zeichnen *)
    procedure PlotColAxis (varNr    : integer;
                           Pos,
                           Grob     : double;
                           Teil     : integer;
                           AxStyle  : TAxisStyles;
                           Farbe    : TColor;
                           RastFarbe : TColor = clNone);
    (*  varNr:     Nummer der variable für diese Achse
        Pos:       Y-Koord. der X-Achse in cm oder
                   X-Koord. der Y-Achse in cm
        Grob:      grobe Skalierung bei lin. Skala
                   (automatische Berechnung mit GetGrid)
        Teil:      Anzahl der Rasterunterteilungen bei lin. Skala
        AxStyle:   siehe asXXX-Konstanten
        Farbe:     Farbe der Achse
        RastFarbe: Farbe der Rasterlinien *)

    (* eine Koordinatenachse (lin/log) mit Beschriftung zeichnen *)
    procedure Axis (varNr    : integer;
                    Pos,
                    Grob     : double;
                    Teil     : integer;
                    AxStyle  : TAxisStyles;
                    TPFarbe  : word);
     (* wie vor aber mit
        TPFarbe:   Farbe der Achse (TP-Farben 0..15) *)

    (* Berechnung des groben Rasters einer Skala *)
    function GetGrid (varNr : integer) : double;
    (* varNr =   Nummer der variable (1 -4 = hor., 5 - 8 = vert.)
       GetGrid = Rasterabstand in der Abstufung 1, 2, 5
                 zu dem mit DefScale vorgebenen Bereich
       Bsp.:     Bereich von -1 bis 10 ==> GetGrid = 2 *)

    (* Berechnung des groben Rasters einer Gradskala *)
    function GetDegreeGrid( varNr : integer) : double;

    (* Berechnung der feinen Unterteilung einer Skala *)
    function GetFGrid (varNr : integer;
                       Grob  : double) : integer;

    // Routinen für hor. Zeitachse
    procedure DefTimeScale (TAnf,TEnd : TDateTime);

    function TimeScale (Val : TDateTime) : double;

    function InvTimeScale (Val : double) : TDateTime;

    function TimeGrid (Anf,Ende                : TDateTime;
                      var AGrob,Zwg,AFein,Zwf : TDateTime;
                      var IFein               : integer) : boolean;

    function PlotTime (X,Y         : double;
                       DT,Zwg      : TDateTime;
                       Align       : word;
                       Farbe       : TColor) : boolean;

    procedure PlotDate (X,Y         : double;
                        DT          : TDateTime;
                        Wd          : boolean;
                        Align       : word;
                        Farbe       : TColor);

    procedure TimeAxis (Pos      : double;
                        AxStyle  : TAxisStyles;
                        Farbe    : TColor;
                        RastFarbe : TColor = clNone);
  end;

(* ------------------------------------------------------------------------ *)
  TPlotMetaFile = class (TMetaFile)
  private
    FCanvas   : TCanvas;
  public
    MetaPlot  : TPlot;
    constructor Create (ARect : TRect; APlot : TPlot);
    destructor Destroy;
    procedure SaveToFile (Filename : string);
    procedure CopyToClipBoard;
    end;


(* Koordinatenpaar als Double zuweisen (siehe auch Point) *)
function FPoint (ax,ay : double) : TFPoint;
function FRect (ax1,ay1,ax2,ay2 : double) : TFRect;

{-----------------------------------------------------------------------}
{-----------------------------------------------------------------------}
implementation

uses System.Math, DateUtils, MathUtils, NumberUtils;

{-----------------------------------------------------------------------}
(* Koordinatenpaar als Double zuweisen (siehe auch Point) *)
function FPoint (ax,ay : double) : TFPoint;
begin
  with Result do begin
    X:=ax; Y:=ay;
    end;
  end;

(* Rechteck als Double zuweisen (siehe auch Rect) *)
function FRect (ax1,ay1,ax2,ay2 : double) : TFRect;
begin
  with Result do begin
    Left:=ax1; Bottom:=ay1;
    Right:=ax2; Top:=ay2;
    end;
  end;

{-----------------------------------------------------------------------}
(* TPlot-Object erzeugen *)
constructor TPlot.Create (NewCanvas : TCanvas);
var
  i : integer;
begin
  inherited Create;
  PlotCanvas:=NewCanvas;
  scx0:=100; scy0:=100;  (* Skalierung in Pixel pro cm/inch *)
  PlotCanvas.Font.Name:=DefFontName;
  TextAngle:=DefFontAngle;
  TextHgt:=DefFontHeight;
  TextStyle:=PlotFontStyle[tsNormal];
  RotReverse:=false;
  TextBackMode:=false;
  FontChange:=true;
  PlotUnits:=unMetric;
(*  SetMapMode (PlotCanvas.Handle,MM_LOMETRIC);*)
  AxisProperties:=MetrAchse;
  (* Skalierungen initialisieren *)
  with Tsc do begin
    Lin:=true; Hor:=true;
    ScEnd:=0; ScAnf:=10; ScFak:=1; ScOff:=0;
    end;
  for i:=1 to varMax do with Xsc[i] do begin
    Lin:=true; Hor:=true;
    ScEnd:=0; ScAnf:=10; ScFak:=1; ScOff:=0;
    end;
  end;

(* TPlot-Object ohne Canvas erzeugen
   Canvas muss später zugewiesen werden *)
constructor TPlot.Create1;
var
  i : integer;
begin
  inherited Create;
  PlotCanvas:=nil;
  scx0:=100; scy0:=100;  (* Skalierung in Pixel pro cm/inch *)
  TextAngle:=DefFontAngle;
  TextHgt:=DefFontHeight;
  TextStyle:=PlotFontStyle[tsNormal];
  RotReverse:=false;
  TextBackMode:=false;
  FontChange:=true;
  PlotUnits:=unMetric;
  FXMaxLabel:=0.0;    // nur für Achse 1
(*  SetMapMode (PlotCanvas.Handle,MM_LOMETRIC);*)
  AxisProperties:=MetrAchse;
  (* Skalierungen initialisieren *)
  for i:=1 to varMax do with Xsc[i] do begin
    Lin:=true; Hor:=true;
    ScEnd:=0; ScAnf:=10; ScFak:=1; ScOff:=0;
    end;
  end;

{-----------------------------------------------------------------------}
(* Einheiten festlegen *)
procedure TPlot.SetUnits (NewUnits : TUnits);
begin
  PlotUnits:=NewUnits;
  if assigned(PlotCanvas) then if PlotUnits=unEnglish then begin
    SetMapMode (PlotCanvas.Handle,MM_HIENGLISH);
    AxisProperties:=InchAchse;
    end
  else begin
    SetMapMode (PlotCanvas.Handle,MM_LOMETRIC);
    AxisProperties:=MetrAchse;
    end;
  end;

{-----------------------------------------------------------------------}
(* Einheiten abfragen *)
function TPlot.GetUnits : TUnits;
begin
  GetUnits:=PlotUnits;
  end;

{-----------------------------------------------------------------------}
(* OEMConvert setzen *)
procedure TPlot.SetOEMConvert (OEM : boolean);
begin
  POEMConvert:=OEM;
  end;

{-----------------------------------------------------------------------}
(* Papiergröße in cm/inch ermitteln *)
procedure TPlot.GetPaperSize (APrinter         : TPrinter;
                              var Width,Height : double);
var
  w,h : integer;
begin
  with APrinter do if Printers.Count>0 then begin
    w:=GetDeviceCaps (Handle,HORZSIZE);
    h:=GetDeviceCaps (Handle,VERTSIZE);
    if w<=0 then Width:=29.4 else Width:=w/10.0;
    if h<=0 then Height:=21.0 else Height:=h/10.0;
    end
  else begin
    Width:=29.48; Height:=21.0;
    end;
  if PlotUnits=unEnglish then begin
    Width:=Width/OneInch; Height:=Height/OneInch;
    end;
  end;

{-----------------------------------------------------------------------}
(* Standardränder *)
procedure TPlot.GetDefMargins (Orientation : TPrinterOrientation;
                               var Margin  : TFRect);
begin
  if PlotUnits=unEnglish then
    if Orientation=poLandscape then Margin:=QInchRand
    else Margin:=HInchRand
  else if Orientation=poLandscape then Margin:=QMetrRand
    else Margin:=HMetrRand;
  end;

{-----------------------------------------------------------------------}
(* Plotfeld Initialisieren
  Size : Größe des Plotfelds in cm/inch (abs. Koord.)
  Rand : Ränder in cm/inch *)
procedure TPlot.SetPlotField (ASize : TFPoint;
                              ARand : TFRect);
begin
  with PlotField do begin
    Left:=ARand.Left;
    Top:=ASize.Y-ARand.Top;
    Bottom:=ARand.Bottom;
    Right:=ASize.X-ARand.Right;
    end;
  UserField:=PlotField; {Zeichenfeld in cm }
  with WindField do begin
    Top:=round(PlotField.Top*Scy0); Bottom:=round(PlotField.Bottom*Scy0);
    Left:=round(PlotField.Left*Scx0); Right:=round(PlotField.Right*Scx0);
    end;
  with WindRand do begin
    Top:=round(ARand.Top*Scy0); Bottom:=round(ARand.Bottom*Scy0);
    Left:=round(ARand.Left*Scx0); Right:=round(ARand.Right*Scx0);
    end;
  with PaperField do begin
    Top:=round((ASize.Y)*Scy0); Bottom:=0;
    Left:=0; Right:=round((ASize.X)*Scx0)
    end;
  end;

function TPlot.InPlotField (ix,iy : integer) : boolean;
var
  x,y : double;
begin
  InvScale(ix,iy,x,y);
  with PlotField do Result:=(x>=Left) and (x<=Right) and (y>=Bottom) and (y<=Top);
  end;

{-----------------------------------------------------------------------}
(* Fenster für Drucker festlegen
   ShowRand : Ränder anzeigen ein/aus *)
procedure TPlot.SetPrintWindow (ShowRand : TShowMargin);
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    if PlotUnits=unEnglish then SetMapMode (Handle,MM_HIENGLISH)
    else SetMapMode (Handle,MM_LOMETRIC);
    if ShowRand=shMargin then with PaperField do begin
      SetWindowOrgEx (Handle,Left,Top,nil);
      SetWindowExtEx (Handle,Right-Left,Bottom-Top,nil);
      end
    else with WindField do begin
      SetWindowOrgEx (Handle,Left,Top,nil);
      SetWindowExtEx (Handle,Right-Left,Bottom-Top,nil);
      end;
    end;
  end;

{-----------------------------------------------------------------------}
(* Fenster für Clipboard festlegen
*)
procedure TPlot.SetClipWindow (Rect : TRect);
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    SetMapMode (Handle,MM_LOMETRIC);
    with Rect do begin
      SetWindowOrgEx (Handle,Left,Top,nil);
      SetWindowExtEx (Handle,Right-Left,Bottom-Top,nil);
      end;
    end;
  end;

{-----------------------------------------------------------------------}
(* Standardfensterabbildung für Bildschirm festlegen
   ShowRand : Ränder anzeigen ein/aus *)
procedure TPlot.SetScreenWindow (ShowRand : TShowMargin;
                                 Size     : TPoint);
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    SetMapMode (Handle,MM_ANISOTROPIC);
    if ShowRand=shMargin then with PaperField do begin
      SetWindowOrgEx (Handle,Left,Top,nil);
      SetWindowExtEx (Handle,Right-Left,Bottom-Top,nil);
      end
    else with WindField do begin
      SetWindowOrgEx (Handle,Left,Top,nil);
      SetWindowExtEx (Handle,Right-Left,Bottom-Top,nil);
      end;
    SetViewportOrgEx (handle,0,0,nil);
    with Size do SetViewportExtEx (handle,X,Y,nil);
    with PlotField do Ratio:=Size.x*(Top-Bottom)/(Size.y*(Right-Left));
    end;
  end;

{-----------------------------------------------------------------------}
(* Fensterabbildung für Bildschirmausschnitt festlegen
   WinSize   : Bildschirmfenstergröße (X x Y) in Pixeln
   Origin    : linke obere Ecke (X,Y) des darzustellenden Fensters auf der
               Zeichenfläche in % der Gesamtfläche
               (siehe WindField in SetPlotField)
   Zoom      : Vergrößerungs-/ Verkleinerungsmaßstab *)
procedure TPlot.SetScreenWindowEx (WinSize,Origin : TPoint;
                                   Zoom           : TFPoint);
var
  x,y,dx,dy : integer;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    SetMapMode (Handle,MM_ANISOTROPIC);
    with WindField do begin
      x:=Right-Left;
      dx:=round(x/Zoom.X);
      if dx<x then x:=x-dx else x:=0;
      x:=round(Origin.X/100*x);
      y:=Bottom-Top;
      dy:=round(y/Zoom.Y);
      if dy>y then y:=y-dy else y:=0;
      y:=round(Origin.Y/100*y);
      SetWindowOrgEx (Handle,Left+x,Top+y,nil);
      SetWindowExtEx (Handle,dx,dy,nil);
      end;
    SetViewportOrgEx (handle,0,0,nil);
    with WinSize do SetViewportExtEx (handle,X,Y,nil);
    with PlotField do Ratio:=WinSize.x*(Top-Bottom)/(WinSize.y*(Right-Left));
    end;
  end;

{-----------------------------------------------------------------------}
(* aktuelle Abmessungen des Zeichenfensters *)
procedure TPlot.GetActWindow (var x,y : word);
var
  Pt : TPoint;
begin
  if assigned(PlotCanvas) then GetWindowExtEx (PlotCanvas.Handle,size(Pt));
  x:=Pt.X; y:=Pt.Y;
  end;

{-----------------------------------------------------------------------}
(* Bildschirmkoordinaten umrechnen *)
procedure TPlot.ViewToWindow (var Pt    : TPoint);
var
  PListe : array [1..1] of TPoint absolute Pt;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    SetMapMode(Handle,MM_ANISOTROPIC);
    DPToLP (Handle,PListe,1);
    end;
  end;

procedure TPlot.WindowToView (var Pt      : TPoint);
var
  PListe : array [1..1] of TPoint absolute Pt;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    SetMapMode(Handle,MM_ANISOTROPIC);
    LPToDP (Handle,PListe,1);
    end;
  end;

(* ----------procedure--RawScale---------------------------------------
   Umrechnung von abs. cm auf Bildschirmkoord. *)
procedure TPlot.RawScale (x,y       : double;
                          var gx,gy : integer);
(* x,y = Koord. in cm
   gx,gy = Koord. in Graph.Einh. *)
begin
  gx:=round(x*scx0); gy:=round(y*scy0);
  end;

(* ----------procedure--Scale------------------------------------------
   Umrechnung von abs. cm auf Bildschirmkoord.
   mit Prüfung auf Begrenzung durch WindField*)
procedure TPlot.Scale (x,y       : double;
                       var gx,gy : integer);
(* x,y = Koord. in cm
   gx,gy = Koord. in Graph.Einh. *)
begin
  with WindField do begin
    gx:=round(x*scx0);
    if gx<Left then gx:=Left; if gx>Right then gx:=Right;
    gy:=round(y*scy0);
    if gy<Bottom then gy:=Bottom; if gy>Top then gy:=Top;
    end;
  end;

(* ----------procedure--InvScale---------------------------------------
   Convert from Pixel-coord. to abs. cm *)
procedure TPlot.InvScale (gx,gy   : integer;
                          var x,y : double);
(* x,y = Koord. in cm
   gx,gy = Koord. in Graph.Einh. *)
begin
   x:=gx/scx0; y:=gy/scy0;
   end;

(* ----------procedure--PlotFrame---------------------------------------
   Rahmen zeichnen *)
procedure TPlot.PlotFrame (Border : TRect;
                           FCol   : TColor;
                           FStyle : TPenStyle;
                           FMode  : TPenMode);
var
  OldPen  : TPen;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    OldPen:=Pen;
    with Pen do begin
      Color:=FCol; Style:=FStyle; Mode:=FMode;
      end;
    with Border do begin
      MoveTo (Left,Top); LineTo (Right,Top); LineTo (Right,Bottom);
      MoveTo (Left,Top); LineTo (Left,Bottom); LineTo (Right,Bottom);
//      LineTo (Right,Bottom); LineTo (Left,Bottom);
//      LineTo (Left,Top);
      end;
    Pen:=OldPen;
    end;
  end;

(* ----------procedure--PlotFrame---------------------------------------
   Rahmen zeichnen *)
procedure TPlot.PlotCrosshair (Center : TPoint;
                               FCol   : TColor;
                               FStyle : TPenStyle;
                               FMode  : TPenMode);
var
  OldPen  : TPen;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    OldPen:=Pen;
    with Pen do begin
      Color:=FCol; Style:=FStyle; Mode:=FMode;
      end;
    with WindField do begin
      MoveTo (Left,Center.y); LineTo (Right,Center.y);
      MoveTo (Center.x,Top); LineTo (Center.x,Bottom);
      end;
    Pen:=OldPen;
    end;
  end;

{------------------------------------------------------------------}
(* TP-Farbe umsetzen *)
function TPLot.ConvColor (Farbe : word) : TColor;
begin
  if (Farbe>MaxColors) then Farbe:=MaxColors;
  ConvColor:=PlotColor[Farbe];
  end;

{------------------------------------------------------------------}
(* Stiftfarbe setzen *)
procedure TPlot.SetPenColor (Color : TColor);
begin
  if assigned(PlotCanvas) then PlotCanvas.Pen.Color:=Color;
  end;

{------------------------------------------------------------------}
(* Stiftfarbe lesen *)
function TPlot.GetPenColor : TColor;
begin
  if assigned(PlotCanvas) then GetPenColor:=PlotCanvas.Pen.Color;
  end;

{------------------------------------------------------------------}
(* Hintergrundfarbe setzen *)
procedure TPlot.SetBgColor (Color : TColor);
begin
  ActBgColor:=Color;
  PlotCanvas.Brush.Color:=Color;
  end;

{------------------------------------------------------------------}
(* Hintergrundfarbe lesen *)
function TPlot.GetBgColor : TColor;
begin
  Result:=ActBgColor;
  end;

{------------------------------------------------------------------}
(* Stiftfarbe setzen *)
procedure TPlot.SetColor (TPFarbe : word);
begin
  if assigned(PlotCanvas) then PlotCanvas.Pen.Color:=ConvColor(TPFarbe);
  end;

{------------------------------------------------------------------}
(* Hintergrundfarbe setzen (TP-kompatibel) *)
function TPlot.SetBackColor (TPFarbe : word) : word;
begin
  if (TPFarbe>MaxColors) then TPFarbe:=MaxColors;
  ActBgTPFarbe:=TPFarbe; ActBgColor:=PlotColor[TPFarbe];
  Result:=ActBgTPFarbe;
  end;

{------------------------------------------------------------------}
(* Hintergrundfarbe lesen (TP-kompatibel) *)
function TPlot.GetBackColor : word;
begin
  Result:=ActBgTPFarbe;
  end;

{------------------------------------------------------------------}
(* Linientyp verändern: Standard:
   0 = durchgezogen, 1 = gepunktet, 2 = Strich-Punkt,
   3 = gestrichelt,  4 = Strich-Punkt-Punkt *)
procedure TPlot.SetLineStyle (Typ : word);
begin
  if Typ>MaxStyle then Typ:=0;
  if assigned(PlotCanvas) then PlotCanvas.Pen.Style:=PlotStyle[Typ];
  end;

{------------------------------------------------------------------}
(* Linienbreite in 1/10 mm  *)
function TPlot.GetLineWidth : word;
begin
  if assigned(PlotCanvas) then Result:=round(100*PlotCanvas.Pen.Width/scx0);
  end;

(* Linienbreite in 1/10 mm setzen *)
procedure TPlot.SetLineWidth (Width : word);
begin
  if assigned(PlotCanvas) then PlotCanvas.Pen.Width:=round(scx0*Width/100.0);
  end;

{------------------------------------------------------------------}
(* Texthöhe in cm *)
function TPlot.GetTextHeight : double;
begin
{  Result:=PlotCanvas.TextHeight('X')/scy0;}
  Result:=TextHgt;
  end;

{------------------------------------------------------------------}
(* Textbreite in cm berechnen *)
function TPlot.GetTextWidth (S : string) : double;
var
  ii : integer;
begin
  if assigned(PlotCanvas) then begin
    ii:=1;
    if length(s)>0 then repeat
      if (S[ii]='_') or (S[ii]='^') then  delete(S,ii,1)
      else inc(ii);
      until ii>length(s);
    Result:=PlotCanvas.TextWidth(S)/scx0;
    end
  else Result:=0;
  end;

{------------------------------------------------------------------}
(* Textfont ändern  *)
procedure TPlot.SetTextFont (FName : string);
begin
  if assigned(PlotCanvas) then with PlotCanvas.Font do if Name<>FName then begin
    if not AnsiSameText(FName,Name) then begin
      Name:=FName;
      FontChange:=true;
      end;
    end;
  end;

{------------------------------------------------------------------}
(* Textgröße in cm setzen *)
procedure TPlot.SetTextHeight (ASize : double);
(* Size = Höhe in cm *)
var
  n : integer;
begin
  if assigned(PlotCanvas) then begin
    n:=-round(ASize*scy0);
    with PlotCanvas.Font do begin
      TextHgt:=ASize;
      Height:=n;
      FontChange:=true;
      end;
    end;
  end;

{------------------------------------------------------------------}
(* Textgröße ändern (Size in pt) *)
procedure TPlot.SetTextSize (ASize : double);
var
  n : integer;
begin
  if assigned(PlotCanvas) then with PlotCanvas.Font do begin
    n:=round(ASize);
    if n<>Size then begin
      Size:=n;
      TextHgt:=abs(Height/scy0);
      FontChange:=true;
      end;
    end;
  end;

{------------------------------------------------------------------}
(* Schriftstil setzen *)
procedure TPlot.SetTextStyle (Style : word);
begin
  if Style>MaxFontStyle then Style:=0;
  if TextStyle<>PlotFontStyle[Style] then begin
    FontChange:=true;
    TextStyle:=PlotFontStyle[Style];
    FontChange:=true;
    end;
  end;

{------------------------------------------------------------------}
(* Textrichtung setzen (siehe RotateFont) *)
procedure TPlot.SetTextDir (Angle : double);
begin
  if TextAngle<>Angle then begin
    TextAngle:=Angle;
    FontChange:=true;
    end;
  end;

(* invertierte Drehrichtung für Text *)
procedure TPlot.SetReverseDir (Reverse : boolean);
begin
  RotReverse:=Reverse;
  end;

{------------------------------------------------------------------}
(* transparenter Hintergrund bei Textausgabe *)
procedure TPlot.SetTransparent (ATrans : boolean);
begin
  TextBackMode:=ATrans;
  end;

{------------------------------------------------------------------}
(* Symbolgröße ändern (Size in cm) *)
procedure TPlot.SetSymbolSize (Size : double);
begin
  SymbolHeight:=Size;
  end;

(* ----------procedure--MoveA-------------------------------------------
  MOVE ABSOLUTE to X,Y  in cm *)
procedure TPlot.MoveA (X,Y : double);
var
  IX,IY : integer;
begin
  Scale (X,Y,IX,IY);
  if assigned(PlotCanvas) then PlotCanvas.MoveTo (IX,IY);
  end;

(* ----------procedure--DrawA-------------------------------------------
  DRAW ABSOLUTE to X,Y    *)
procedure TPlot.DrawA (X,Y : double);
var
  IX,IY : integer;
begin
  Scale (X,Y,IX,IY);
  if assigned(PlotCanvas) then PlotCanvas.LineTo (Ix,IY);
  end;

(* ----------procedure--CScale------------------------------------------
   Umrechnung von cm relativ zu Origin auf Pixel
*)
procedure TPlot.CScale (X,Y       : double;
                        var IX,IY : integer);
(* X und Y sind Koordinaten in cm
   IX und IY sind Bildschirm- oder Druckerkoord. *)
begin
  X:=X+UserOrigin.X; Y:=Y+UserOrigin.Y;
  Scale (X,Y,IX,IY);
  end;

(* ----------procedure--InvScale----------------------------------------
   Umrechnung von Pixel auf cm relativ zu Origin
*)
procedure TPlot.InvCScale (IX,IY   : integer;
                           var X,Y : double);
(* X und Y sind Koordinaten in cm
   IX und IY sind Bildschirm- oder Druckerkoord. *)
begin
   InvScale (IX,IY,X,Y);
   x:=x-UserOrigin.x; y:=y-UserOrigin.y;
   end;

(* ----------procedure--InitPlot----------------------------------------
   Drucker- oder Bildschirmgrafik starten *)
procedure TPlot.InitPlot (Clear  : boolean;
                          Col    : TColor);
begin
  with UserField do begin
    Left:=Left+UserOrigin.X; Right:=Right+UserOrigin.X;
    Bottom:=Bottom+UserOrigin.Y; Top:=Top+UserOrigin.Y;
    end;
  with UserOrigin do begin
    X:=0.0; Y:=0.0;
    end;
  with Offset do begin
    X:=0.0; Y:=0.0;
    end;
  with Posit do begin
    X:=0.0; Y:=0.0;
    end;
  with Fac do begin
    X:=1.0; Y:=1.0;
    end;
  PenStat:=3;
  ActBgColor:=Col;
  if assigned(PlotCanvas) then if Clear then with PlotCanvas do begin
    with Pen do begin
      Color:=Col xor $FFFFFF; Width:=1; Style:=psSolid; Mode:=pmCopy;
      end;
    TextHgt:=DefFontHeight;
    TextStyle:=PlotFontStyle[tsNormal];
    TextAngle:=DefFontAngle;
    with Font do begin
      Name:=DefFontName;
      Height:=round(TextHgt*scy0);
      Style:=TextStyle;
      end;
    FontChange:=true;
    with Brush do begin
      Color:=Col; Style:=bsSolid;
      end;
    SymbolHeight:=DefSymbolHeight;
    FillRect (WindField);
    end;
  with Posit do MoveA (X,Y); (* MOVE to START POSITION *)
  end;

(* ---------procedure--StartPlot---------------------------------------
   Drucker- oder Bildschirmgrafik starten *)
procedure TPlot.StartPlot (Clear  : boolean;
                           BakCol : word);
begin
  BakCol:=SetBackColor(BakCol);
  InitPlot (Clear,ConvColor(BakCol));
  end;

(* ----------procedure--PlotR-------------------------------------------
   Drucker- oder Bildschirmgrafik beenden
*)
procedure TPlot.EndPlot;
begin

  end;

(* ----------procedure--CPlot-------------------------------------------
   Zeichnen einer Linie (ähnlich zur Calcomp-Routine PLOT *)
procedure TPlot.CPlot (XIN,YIN      : double;
                       PenMode,Mark : integer);
(* XIN AND YIN : Koordinaten in cm
 * PenMode: (enstspricht der Calcomp-Konvention) - siehe Programmanfang
 *      1= alter Pen-Modus
 *      2= Pen unten oder sichtbarer Vektor
 *      3= Pen hoch oder unsichtbarer Vektor
 *     11,...,13 wie 1,...,3, außerdem werden XIN und YIN mit
 *             (X,Y)FSET und (X,Y)Fac skaliert (siehe Routine "OFFSET")
 *     <0: wie oben, aber der Zielpunkt XIN,YIN ist neuer Nullpunkt
 * Mark = 0: keine Marke
        = 1: Kreuz (+) bei XIN,YIN  (Markengröße: Symbolheight)
        = 2: Kreuz (x) bei XIN,YIN
        = 3: Dreieck bei XIN,YIN
        = 4: Quadrat bei XIN,YIN
        = 5: Achteck bei XIN,YIN *)
var
  X,Y,D,Q   : double;
  N1,N      : integer;
begin
  X:=XIN; Y:=YIN; N1:=PenMode;
  N:=ABS(N1);
(* apply Offsets, Scaling and Factors *)
  if N > 10 then begin
    N:=N-10; X:=(X-Offset.X)/Fac.X; Y:=(Y-Offset.Y)/Fac.Y;
    end;
  X:=X+UserOrigin.X; Y:=Y+UserOrigin.Y;
  if N <= 3 then begin
(* PUT OUT Vectors *)
  case N of
(* TAKE OLD PEN STATUS *)
  1 :     if PenStat = 3 then MoveA (X,Y) else DrawA (X,Y);
(* DRAW if Mode=2, -2, 12, -12 *)
  2 : begin
      PenStat:=2; DrawA(X,Y);
      end;
(* MOVE if Mode=3, -3, 13, -13 *)
  3 : begin
      PenStat:=3; MoveA(X,Y);
      end;
    end;
  end;
  If (N<=3) and (Mark<>0) then begin (* Marken *)
    D:=0.5*SymbolHeight;
    case Mark of
    mmPlus : begin (* Kreuz (+) *)
        MoveA(X-D,Y); DrawA(X+D,Y);
        MoveA(X,Y+D); DrawA(X,Y-D);
        end;
    mmCross : begin (* Kreuz (x) *)
        MoveA(X-D,Y-D); DrawA(X+D,Y+D);
        MoveA(X-D,Y+D); DrawA(X+D,Y-D);
        end;
    mmTriangle : begin (* Dreieck *)
        Q:=1.2*D; D:=0.7*D;
        MoveA(X-Q,Y-D); DrawA(X+Q,Y-D);
        DrawA(X,Y+2.16*D); DrawA(X-Q,Y-D);
        end;
    mmSquare : begin (* Quadrat *)
        MoveA(X-D,Y-D); DrawA(X+D,Y-D);
        DrawA(X+D,Y+D); DrawA(X-D,Y+D);
        DrawA(X-D,Y-D);
        end;
    mmOctagon : begin (* Achteck *)
        Q:=0.4*D;
        MoveA(X-D,Y-Q); DrawA(X-D,Y+Q); DrawA(X-Q,Y+D);
        DrawA(X+Q,Y+D); DrawA(X+D,Y+Q); DrawA(X+D,Y-Q);
        DrawA(X+Q,Y-D); DrawA(X-Q,Y-D); DrawA(X-D,Y-Q);
        end;
      end;
    MoveA(X,Y);
    end;
  Posit.X:=X; Posit.Y:=Y;
(* if Mode POSITIVE, BYPASS NEW ORIGIN *)
  if N1 < 0 then with UserField do begin
(* CHANGE ORIGIN AND PROCEDE *)
    Left:=Left-X+UserOrigin.X; Right:=Right-X+UserOrigin.X;
    Bottom:=Bottom-Y+UserOrigin.Y; Top:=Top-Y+UserOrigin.Y;
    UserOrigin.X:=X; UserOrigin.Y:=Y;
    end;
  end;

procedure TPlot.PlotLine (x,y : double; ACol : TColor; AStyle : TLineStyle; AMd : TPenMode);
var
  i,n   : integer;
  d,f,t : double;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    if AStyle=lsNone then MoveA(x,y)   // keine Linie
    else begin
      with Pen do begin
        Color:=ACol; Mode:=AMd;
        end;
      if AStyle=lsSolid then DrawA(x,y)  // durchgezogene Linie
      else begin
        d:=sqrt(sqr(Posit.x-x)+sqr(Posit.y-y));  // Länge der Linie in cm/inch
        if AStyle=lsDotted then begin
          n:=round(d/(GetLineWidth/30)); t:=0.3;
          end
        else begin
          n:=round(d/(GetLineWidth/10)); t:=0.5;
          end;
        if n>0 then begin
          if abs(x-Posit.x)>abs(y-Posit.y) then begin
            d:=(x-Posit.x)/n; f:=(y-Posit.y)/(x-Posit.x);
            for i:=0 to n-1 do begin
              MoveA(Posit.x+i*d,Posit.y+i*d*f);
              DrawA(Posit.x+(i+t)*d,Posit.y+(i+t)*d*f);
              end;
            end
          else begin
            d:=(y-Posit.y)/n; f:=(x-Posit.x)/(y-Posit.y);
            for i:=0 to n-1 do begin
              MoveA(Posit.x+i*d,Posit.y+i*d*f);
              DrawA(Posit.x+(i+t)*d*f,Posit.y+(i+t)*d);
              end;
            end;
          end;
        end;
      end;
    end;
  Posit.X:=X; Posit.Y:=Y;       // letzte Position in cm
  end;

(* ----------procedure--ClrBox------------------------------------------
(* Zeichnen eines Punktes *)
procedure TPlot.PlotDot (x,y : double;
                         Col : TColor);
var
  ix,iy : integer;
begin
  CScale (x,y,ix,iy);
  if assigned(PlotCanvas) then with PlotCanvas do begin
    MoveTo (ix,iy); LineTo(ix+1,iy);
    end;
  end;

(* ----------procedure--ClrBox------------------------------------------
   Löschen eines Bildausschnitts, Koord. in cm *)
procedure TPlot.ClrBox (x1,y1,x2,y2 : double;
                        Bak         : word);
(* x1,x2,y1,y2 in cm
   Bak        Farbe des Hintergrundes *)
begin
  Bak:=SetBackColor(Bak);
  PlotRect (x1,y1,x2,y2,ConvColor(Bak));
  end;

(* ----------procedure--PlotRect------------------------------------------
   Zeichnen eines gefüllten Rechtecks, Koord. in cm *)
procedure TPlot.PlotRect (x1,y1,x2,y2 : double;
                          Col         : TColor);
var
  Feld                : TRect;
  OBColor             : TColor;
  OBStyle             : TBrushStyle;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    with Brush do begin
      OBColor:=Color; OBStyle:=Style;
      Color:=Col; Style:=bsSolid;
      end;
    with Feld do begin
      CScale (x1,y1,Left,Bottom); CScale (x2,y2,Right,Top);
      end;
    FillRect (Feld);
    with Brush do begin
      Color:=OBColor; Style:=OBStyle;
      end;
    end;
  end;

(* ----------procedure--PlotPoly------------------------------------------
   Zeichnen eines gefüllten Rechtecks, Koord. in cm *)
procedure TPlot.PlotPoly (const FPoints : array of TFPoint;
                          Col           : TColor);
var
  OBColor             : TColor;
  OBStyle             : TBrushStyle;
  i                   : integer;
  Points              : array of TPoint;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    with Brush do begin
      OBColor:=Color; OBStyle:=Style;
      Color:=Col; Style:=bsSolid;
      end;
    Pen.Color:=Col;
    SetLength(Points,length(FPoints));
    for i:=0 to length(FPoints)-1 do with Points[i] do
      CScale (FPoints[i].X,FPoints[i].Y,x,y);
    Polygon(Points);
    with Brush do begin
      Color:=OBColor; Style:=OBStyle;
      end;
    end;
  end;

(* ----------procedure--PlotBitmap------------------------------------------
   Zeichen eines Bitmaps in eine Rechteck *)
procedure TPlot.PlotBitmap (x,y,w,h : double;
                            Bitmap      : TBitmap);
var
  Feld : TRect;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    with Feld do begin
      CScale (x,y,Left,Bottom);
      if w<0.1 then begin
        Right:=Left+Bitmap.Width;
        Top:=Bottom+Bitmap.Height;
        end
      else begin
        if h<0.1 then begin
          with Bitmap do h:=Height/Width*w;
          end;
        CScale (x+w,y+h,Right,Top);
        end;
      end;
    StretchDraw(Feld,Bitmap);
    end;
  end;

procedure TPlot.PlotBitmap (x,y,w,h : double; BCol,RCol : TColor;
                            Bitmap      : TBitmap);
var
  Feld    : TRect;
  OBColor : TColor;
  OBStyle : TBrushStyle;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    with Feld do begin
      CScale (x,y,Left,Bottom);
      if w<0.1 then begin
        Right:=Left+Bitmap.Width;
        Top:=Bottom+Bitmap.Height;
        end
      else begin
        if h<0.1 then begin
          with Bitmap do h:=Height/Width*w;
          end;
        CScale (x+w,y+h,Right,Top);
        end;
      end;
    with Brush do begin
      OBColor:=Color; OBStyle:=Style;
      Color:=BCol; Style:=bsSolid;
      end;
    BrushCopy(Feld,Bitmap,Rect(0,0,Bitmap.Width,Bitmap.Height),RCol);
    with Brush do begin
      Color:=OBColor; Style:=OBStyle;
      end;
    end;
  end;

procedure TPlot.PlotPicture (x,y,w,h : double;
                             Picture : TPicture);
var
  Feld : TRect;
begin
  if assigned(PlotCanvas) then with PlotCanvas do begin
    with Feld do begin
      CScale (x,y,Left,Bottom);
      if w<0.1 then begin
        Right:=Left+Picture.Width;
        Top:=Bottom+Picture.Height;
        end
      else begin
        if h<0.1 then begin
          with Picture do h:=Height/Width*w;
          end;
        CScale (x+w,y+h,Right,Top);
        end;
      end;
    StretchDraw(Feld,Picture.Bitmap);
    end;
  end;

{-----------------------------------------------------------------------}
(* neuen Font (Größe, Stil, Richtung) erzeugen *)
procedure TPlot.CreateNewFont (var NewFont,OldFont : HFont);
var
  FontName : PChar;
  Angle,
  Weight   : integer;
  Italic   : byte;
begin
  if assigned(PlotCanvas) then begin
    FontName:=StrAlloc (LF_FACESIZE);
    StrPCopy(FontName,PlotCanvas.Font.Name);
    if fsBold in TextStyle then Weight:=FW_DEMIBOLD else Weight:=FW_NORMAL;
    if fsItalic in TextStyle then Italic:=1 else Italic:=0;
    Angle:=round(10*TextAngle);
    if not RotReverse then Angle:=-Angle;
    NewFont:=CreateFont (-round(TextHgt*scy0),0,Angle,Angle,
                         Weight,Italic,0,0,
                         DEFAULT_CHARSET,
                         OUT_DEFAULT_PRECIS,
                         CLIP_LH_ANGLES	,
                         ANTIALIASED_QUALITY,
                         DEFAULT_PITCH or FF_DONTCARE,
                         FontName);
    OldFont:=SelectObject(PlotCanvas.Handle,NewFont);
    StrDispose(FontName);
    FontChange:=false;
    end;
  end;

{-----------------------------------------------------------------------}
(* neuen Font entfernen *)
procedure TPlot.DeleteNewFont (var NewFont,OldFont : HFont);
begin
  SelectObject(PlotCanvas.Handle,OldFont);
  DeleteObject (NewFont);
  end;

(* ----------procedure--PlotColStr--------------------------------------
(* Ausgabe eines Strings (ASCII) *)
procedure TPlot.PlotColStr (X,Y       : double;
                            S         : string;
                            Format    : boolean;
                            Align     : word;
                            Farbe     : TColor);
(* X, Y           - Koordinaten des Strings in cm (linke untere Ecke)
   S              - Text
   Format         - Textformatierung (ein/aus)
                    = true: im Text: _ ==> nachfolg. Text tiefstellen (rel.)
                                     ^ ==> nachfolg. Text hochstellen (rel.)
                      Bsp.: x_1^^2  = x (index) 1 hoch 2 )
   Textposition rel. zu X,Y:
   Align = 1       - links unten
         = 2       - links zentriert
         = 3       - links oben
         = 4       - zentriert unten
         = 5       - allseits zentriert
         = 6       - zentriert oben
         = 7       - rechts unten
         = 8       - rechts zentriert
         = 9       - rechts oben
   Farbe = Textfarbe *)
var
  ix,iy,ii,ic         : integer;
  yoff,
  SPhi,CPhi,xd,yd     : double;
  Shift               : boolean;
  T                   : string;
  OldColor            : TColor;
  OldFont,NewFont     : HFont;  (* Handle auf Font *)
begin
  with PlotCanvas do begin
    OldColor:=Font.Color;
    Font.Color:=Farbe;
//    Font.Height:=-round(TextHgt*scy0);
    end;
{ beim Drucken muß der Font immer neu erstellt werden }
  CreateNewFont (NewFont,OldFont);
{ nach ANSI konvertieren, falls erforderlich }
  if POEMConvert then s:=StrToANSI(s);
  Align:=Align mod 10;
  T:=S; yOff:=0.0;
  SPhi:=sin(Pi180*TextAngle); CPhi:=cos(Pi180*TextAngle);
  ii:=1;
  if length(s)>0 then repeat
    if (S[ii]='_') or (S[ii]='^') then  delete(S,ii,1)
    else inc(ii);
    until ii>length(s);
  Format:=Format and (length(t)<>length(s));
  xd:=GetTextWidth(S);
  yd:=GetTextHeight*0.9; (* Durchschuß beachten - abhängig vom Font ?? *)
  case Align of
  alLeftBottom : begin
      x:=x-SPhi*yd; y:=y+CPhi*yd;
      end;
  alLeftCenter : begin
      x:=x-0.55*SPhi*yd; y:=y+0.55*CPhi*yd;
      end;
  alLeftTop : begin
      x:=x-0.1*SPhi*yd; y:=y+0.1*CPhi*yd;
      end;
  alCenterBottom : begin
      x:=x-0.5*CPhi*xd-SPhi*yd; y:=y-0.5*SPhi*xd+CPhi*yd;
      end;
  alCenterAll : begin
      x:=x-0.5*CPhi*xd-0.55*SPhi*yd; y:=y-0.5*SPhi*xd+0.55*CPhi*yd;
      end;
  alCenterTop : begin
      x:=x-0.5*Cphi*xd-0.1*SPhi*yd; y:=y-0.5*Sphi*xd+0.1*CPhi*yd;
      end;
  alRightBottom : begin
      x:=x-CPhi*xd-SPhi*yd; y:=y-SPhi*xd+CPhi*yd;
      end;
  alRightCenter : begin
      x:=x-Cphi*xd-0.55*SPhi*yd; y:=y-Sphi*xd+0.55*CPhi*yd;
      end;
  alRightTop : begin
      x:=x-Cphi*xd-0.1*SPhi*yd; y:=y-Sphi*xd+0.1*CPhi*yd;
      end;
    end;
  if length(t)>0 then repeat
    if Format then begin
      Shift:=true;
      case T[1] of
      '_' : yoff:=yoff-0.4*yd;
      '^' : yoff:=yoff+0.4*yd;
      else Shift:=false;
        end;
      if Shift then delete(T,1,1);
      ic:=pos('_',T); ii:=pos('^',T);
      if ic+ii=0 then begin
        S:=T; T:='';
        end
      else begin
        if ic=0 then ic:=ii
        else if (ii<>0) and (ic>ii) then ic:=ii;
        S:=copy(T,1,pred(ic)); delete(T,1,pred(ic));
        end;
      end
    else begin      // kein hoch/tief
      s:=t; t:='';
      end;
    x:=x-SPhi*yoff; y:=y+CPhi*yoff;
    Scale (X+UserOrigin.X,Y+UserOrigin.Y,IX,IY);
    with PlotCanvas do begin
      if TextBackMode then SetBkMode(Handle,TRANSPARENT) else SetBkMode(Handle,OPAQUE);
      TextOut (IX,IY,s);
      end;
//    GetTextExtentPoint32(PlotCanvas.Handle,pchar(s),length(s),sz);
    xd:=GetTextWidth(S)+0.02;
//    xd:=sz.cx/scx0*(1+0.35*SPhi*(1+Ratio));  // Formel empirisch gefunden für 0 und 9o° ??
    x:=x+Cphi*xd+SPhi*yoff; y:=y+Sphi*xd-CPhi*yoff;
    until T='';
  DeleteNewFont (NewFont,OldFont);
  PlotCanvas.Font.Color:=OldColor;
  end;

(* ----------procedure--PlotFontStr--------------------------------------
   Plotten eines Strings (ASCII) in best. Font *)
procedure TPlot.PlotFontStr (X,Y       : double;
                             S         : string;
                             Format    : boolean;
                             Align     : word;
                             Farbe     : TColor;
                             FName     : string);
begin
  SetTextFont(FName);
  PlotColStr (X,Y,S,Format,Align,Farbe);
  end;

(* ----------procedure--StrTrunc----------------------------------------
(* String in der Länge beschneiden *)
function TPlot.StrTrunc (s : String;
                         x : double) : String;
begin
  while (GetTextWidth(s)>x) and (length(s)>0) do delete (s,length(s),1);
  StrTrunc:=s;
  end;

(* ----------procedure--PlotStr-----------------------------------------
   Plotten eines Strings (ASCII) mit TP-kompatibler Farbe *)
procedure TPlot.PlotStr (X,Y       : double;
                         S         : string;
                         Format    : boolean;
                         Align,
                         TPFarbe   : word);
(* Parameter siehe PlotColStr
   TPFarbe = Textfarbe (0..15) *)
begin
  PlotColStr (X,Y,S,Format,Align,ConvColor(TPFarbe));
  end;

(* ----------procedure--ANumb-------------------------------------------
   Konvertieren einer Zahl in einen String, z.B. für die Skalenbeschriftung *)
function TPlot.ANumb (F   : double;
                      N   : integer) :  string;
(* F              - Zahl
   N > 0          - Anzahl der Stellen hinter dem Komma
     = 0          - kein Komma
     < 0          - runde die letzten -N Stellen *)
var
  z,a     : double;
  i,j     : integer;
  s       : String;
begin
  if n<0 then begin
    a:=pwr(10.0,abs(n));
    z:=int(f/a+ASign(0.5,f))*a; j:=0;
    end
  else begin
    z:=f; j:=n;
    end;
  s:=FloatToStrX(z,10,j); // str (z:10:j,s);
  i:=0;
  repeat
    inc(i);
    until s[i]<>' ';
  ANumb:=copy (s,i,10-i+1);
  end;

{ ------------------------------------------------------------------ }
(* Zahl mit Stellenzwischenraum *)
function TPlot.ZNumb (x : double;
                      n : integer) : string;
(* Format wie ANumb *)
var
  s   : string;
  i,j : integer;
begin
  s:=ANumb(x,n);
  i:=pos('.',s);
  if i=0 then i:=succ(length(s));
  j:=i;
  while (j>3) do begin
    dec(j,3); insert (' ',s,j);
    end;
  inc(i,3);
  while (i<length(s)) do begin
    insert(' ',s,i); inc(i);
    end;
  ZNumb:=s;
  end;

(* Zahlen auf "Eng-Format" mit 10^..  umsetzen *)
function TPlot.FloatToPlotStr (Value   : double;
                               n       : integer) : string;
(* n    = Anzahl der signifikanten Stellen *)
var
  s : string;
  i : integer;
begin
  s:=FloatToStrE(Value,n,',');
  i:=Pos('E',s);
  if i>0 then begin
    delete(s,i,1); insert('·10^',s,i); s:=s+'_';
    end;
  Result:=s;
  end;


{ ------------------------------------------------------------------ }
(* ----------procedure--DefUserField-----------------------------------
   Vorgabe des Feldes für das Koordinatensystem *)
procedure TPlot.DefUserField (Mode        : integer;
                              XL,XR,YU,YO : double);
(*  Mode = ufAbs (1) : in absoluten Koordinaten (cm) rel.
                       zu XOrig,YOrig (siehe CPlot)
           ufRel (2) : rel. in cm zum vordefinierten Rand
    XL   =     linker Rand in cm
    XR   =     rechter Rand in cm
    YU   =     unterer Rand in cm
    YO   =     oberer Rand in cm  *)
begin
  with UserField do if Mode=ufAbs then begin
    Bottom:=YU; Top:=YO;
    Left:=XL; Right:=XR;
    end
  else begin
    Bottom:=PlotField.Bottom+YU-UserOrigin.Y;
    Top:=PlotField.Top-YO-UserOrigin.Y;
    Left:=PlotField.Left+XL-UserOrigin.X;
    Right:=PlotField.Right-XR-UserOrigin.X;
    end;
  end;

(* Prüfen, ob Wert im Benutzerfeld liegt *)
function TPlot.InUserField (x,y : double) : boolean;
begin
  with UserField do Result:=(x>=Left) and (x<=Right) and (y>=Bottom) and (y<=Top);
  end;

(* ----------procedure--ScalDef----------------------------------------
  Definition der Skalierung in Benutzerkoordinaten *)
procedure TPlot.DefUserScale (varNr   : integer;
                              ScalTyp : TScaleTypes;
                              XLL,XUR : double);
(*  varNr =    Nummer der variable (1 .. varMax)
    ScalTyp =  hor./vert, lin/log (siehe oben, stXXX-Konst.)
    XLL   =    hor. Achse:  linker Rand
               vert. Achse: unterer Rand
    XUR   =    hor. Achse:  rechter Rand
               vert. Achse: oberer Rand
  Skalierung in Xsc:
       Xsc[N].Lin   = true (Lin), false (Log)
       Xsc[N].Hor   = true (hor. Achse), false (vert. Achse)
       Xsc[N].ScAnf = XLL in Benutzerkoord.
       Xsc[N].ScEnd = XUR in Benutzerkoord.
       Xsc[N].ScFak = Skalierungsfaktor
       Xsc[N].ScOff = Skalenoffset   *)
var
  K      : integer;
  PQ,PL  : double;
  VAx    : boolean;
begin
  K:=abs(varNr);
  if k<=varMax then begin
    VAx:=stVert in ScalTyp; (* vert. Achse *)
    with UserField do if VAx then begin
      PQ:=Top-Bottom; PL:=Bottom;
      end
    else begin
      PQ:=Right-Left; PL:=Left;
      end;
    with Xsc[K] do begin
      Lin:=not (stLog in ScalTyp);
      Hor:=not VAx;
      if Lin then begin
        PQ:=PQ/(XUR-XLL); ScOff:=PL-PQ*XLL;
        end
      else begin
        PQ:=PQ/lg(XUR/XLL); ScOff:=PL-PQ*lg(XLL);
        end;
      ScFak:=PQ; ScEnd:=XUR; ScAnf:=XLL;
      end;
    end;
  end;

(* ----------function---UserScale--------------------------------------
   Umrechnung von abs. Benutzerkoord. auf cm *)
function TPlot.UserScale (varNr : integer;
                          Val   : double) : double;
(* varNr  =   Nummer der variable
   Val    =   Wert der variable in Benutzerkoord.
   Result =   Wert in cm *)
begin
  if varNr<=varMax then with Xsc[varNr] do begin
    if Lin then Result:=ScFak*Val+ScOff
    else Result:=ScFak*lg(Val)+ScOff;
    end
  else Result:=1;  // falsche varNr
  end;

(* ----------function---RelUserScale-----------------------------------
   Umrechnung von rel. Benutzerkoord. auf cm *)
function TPlot.RelUserScale (varNr : integer;
                             Val   : double) : double;
(* varNr  =   Nummer der variable
   Val    =   Wert der variable in Benutzerkoord.
   Result =  Wert in cm *)
begin
  if varNr<=varMax then with Xsc[varNr] do begin
    if Lin then Result:=ScFak*Val
    else Result:=ScFak*lg(Val);
    end
  else Result:=1;  // falsche varNr
  end;

(* ----------function---InvUserScale-----------------------------------
   Umrechnung von cm auf Benutzerkoord. *)
function TPlot.InvUserScale (varNr : integer;
                             Val   : double) : double;
(* varNr  =   Nummer der variable
   Val    =   Wert der variable in cm
   Result =  Wert in Benutzerkoord. *)
begin
  if varNr<=varMax then with Xsc[varNr] do begin
    if Lin then Result:=(Val-ScOff)/ScFak
    else Result:=Pwr(10.0,(Val-ScOff)/ScFak);
    end
  else Result:=1;  // falsche varNr
  end;

(* ----------function---InUserRange--------------------------------------
   Prüfen, ob Wert im zulässigen Bereich liegt *)
function TPlot.InUserRange (varNr   : integer;
                            var Val : double) : boolean;
(* varNr  =   Nummer der variable
   Val    =   Wert der variable in Benutzerkoord.
              setze auf Bereichenden, wenn außerhalb
   Result =   true, wenn im Bereich *)
begin
  if varNr<=varMax then with Xsc[varNr] do begin
    Result:=true;
    if ScAnf<=ScEnd then begin
      if (Val<ScAnf) then begin
        Result:=false; Val:=ScAnf;
        end
      else if (Val>ScEnd) then begin
        Result:=false; Val:=ScEnd;
        end;
      end
    else begin
      if (Val<ScEnd) then begin
        Result:=false; Val:=ScEnd;
        end
      else if (Val>ScAnf) then begin
        Result:=false; Val:=ScAnf;
        end;
      end;
    end
  else Result:=false;  // falsche varNr
  end;

(* ----------function---InUserRange--------------------------------------
   Bereichsanfang *)
function TPlot.GetUserMinValue(varNr : integer) : double;
(* varNr  =   Nummer der variable
   Result =   Bereichsanfang *)
begin
  if varNr<=varMax then with Xsc[varNr] do Result:=ScAnf
  else Result:=0;  // falsche varNr
  end;

(* ----------function---InUserRange--------------------------------------
   Bereichsende *)
function TPlot.GetUserMaxValue(varNr : integer) : double;
(* varNr  =   Nummer der variable
   Result =   Bereichsende *)
begin
  if varNr<=varMax then with Xsc[varNr] do Result:=ScEnd
  else Result:=10;  // falsche varNr
  end;

(* ----------procedure--SetAxisProp------------------------------------
   individuelle Achseneigenschaften setzen *)
procedure TPLot.SetAxisProp (ADec : integer;
                             ASize,AThick,ADist,ACoLen,AFiLen : double);
begin
  with AxisProperties do begin
    Digits:=ADec; (* automatische Auswahl der Dezimalstellen der
                     Beschriftung *)
    TSz:=ASize;    (* Größe der Beschriftung in cm *)
    LnTh:=AThick;  (* Dicke der Linien in cm *)
    Abst:=ADist;   (* Abstand Beschriftung - Achse in cm *)
    XG:=ACoLen;    (* Länge der Grobskalierungsstriche in cm *)
    XF:=AFiLen;    (* Länge der Feinskalierungsstriche in cm *)
    end;
  end;

(* ----------procedure--PlotColAxis------------------------------------
   eine Koordinatenachse mit Beschriftung bei den groben Skalenmarken
   zeichnen
   (lin/log - siehe ScalDef) *)
procedure TPlot.PlotColAxis (varNr    : integer;
                             Pos,
                             Grob     : double;
                             Teil     : integer;
                             AxStyle  : TAxisStyles;
                             Farbe,
                             RastFarbe : TColor);
(*  varNr:     Nummer der Variable für diese Achse
    Pos:       Y-Koord. der X-Achse in cm oder
               X-Koord. der Y-Achse in cm
    Grob:      grobe Skalierung bei lin. Skala
               (automatische Berechnung mit GetGrid)
    Teil:      Anzahl der Rasterunterteilungen bei lin. Skala
    AxStyle:   asGrid        = mit langen Rasterlinien
                               bei den groben Skal.marken
               asNoText      = ohne Beschriftung
               asPrefix      = Beschriftung unter Benutzung der
                               Einheitenvorsätze (z.B. m (Milli), k (Kilo))
               asFixed       = Beschriftung im ffFixed-Format
               asTop         = Beschriftung oberhalb der Hor.Achse
               asBottom      = Beschriftung unterhalb der Hor.Achse
               asLeft        = Beschriftung links der Vert.Achse
               asRight       = Beschriftung rechts der Vert.Achse
               asRotate      = Text in Achsenrichtung drehen
               asNoZero      = kein Beschriftung bei Wert = 0
    Farbe:     Farbe der Achse
    RastFarbe: Farbe der Rasterlinien *)
  var
    I,J,K,NDek,kk,II,JJ,Align,ND,N    : integer;
    ZWG,ZWF,GR,FEIN,DELTA,
    XX,AFEIN,AGROB,XS,YS,Y,DX         : double;
    Pref,ScText,Rot,Fixed,CenterText,
    VSW,LR,RSW,Txt                    : boolean;
    OldWidth                          : word;
    OldColor                          : TColor;
    OldTextStyle                      : TFontStyles;
    OldTextHgt,OldTextAngle           : single;
    s                                 : string;

  procedure GridLineX (Left,Right,Y : double; Col : TColor);
  begin
    if Col<>clNone then SetPenColor(Col);
    CPlot (Left,Y,3,0); CPlot (Right,Y,2,0);
    if Col<>clNone then SetPenColor(Farbe);
    end;

  procedure GridLineY (X,Top,Bottom : double; Col : TColor);
  begin
    if Col<>clNone then SetPenColor(Col);
    CPlot (X,Top,pmUp,0); CPlot (X,Bottom,pmDown,0);
    if Col<>clNone then SetPenColor(Farbe);
    end;

begin
  with PlotCanvas.Pen do begin
    OldColor:=Color; OldWidth:=Width;
    Color:=Farbe; Width:=round(scx0*AxisProperties.LnTh);
    end;
  (* Textfont sichern *)
  OldTextStyle:=TextStyle; OldTextHgt:=TextHgt; OldTextAngle:=TextAngle;
  N:=ABS(varNr);
  if N<=varMax then with AxisProperties do begin
    LR:=(asTop in AxStyle) or (asRight in AxStyle);
    Pref:=asPrefix in AxStyle;
    Fixed:=asFixed in AxStyle;
    ScText:=not (asNoText in AxStyle);
    CenterText:=asCenterText in AxStyle;
    Rot:=false;
    if ScText then begin
      SetTextHeight (TSz); SetTextStyle (tsNormal);
      Rot:=(asRotate in AxStyle) and not Xsc[N].Hor;
      if Rot then SetTextDir(90) else SetTextDir(0);
      end;
    VSW:=not Xsc[N].Hor;
    RSW:=asGrid in AxStyle;
    if Teil=0 then Teil:=10;
    if VSW then begin
      if LR then begin (* rechts *)
        if Rot then Align:=alCenterTop else Align:=alLeftCenter;
        XS:=ABST;
        end
      else begin (* links *)
        if Rot then Align:=alCenterBottom else Align:=alRightCenter;
        XS:=-ABST;
        end;
      YS:=0.0;
      end
    else begin
      if LR then begin (*oben *)
        Align:=alCenterBottom; YS:=ABST;
        end
      else begin (* unten *)
        Align:=alCenterTop; YS:=-ABST;
        end;
      XS:=0.0;
      end;
    with Xsc[N] do begin
      if Lin then begin
  (* Lin. Skala - Skalierungsmarken berechnen *)
        ZWG:=ABS(GROB); ZWF:=ZWG/abs(Teil); DELTA:=ScEnd-ScAnf;
        XX:=AInt(ScAnf/ZWF-0.1);
        Fein:=AInt(ScEnd/ZWF+0.1)-XX;
        AFEIN:=XX*ZWF;
        II:=round(ABS(FEIN));
    (* Länge der Skalenbeschriftung - nd = signifikante Stellen *)
        if Digits=AutoDig then nd:=round(lg(abs(2*(abs(ScAnf-ScEnd))/ZWG))+1)
        else nd:=Digits;
        for i:=0 to II do begin
          XX:=AFein+i*ZWF;
          if (XX>=ScAnf) and (XX<=ScEnd) then begin
            Y:=UserScale(N,XX);
            if abs(rmod(xx,Zwg))<0.5*Zwf then begin
              if abs(XX)<0.1*ZwF then XX:=0;
            (* grobe Skalenmarken, Raster und Beschriftung *)
              if NOT VSW then begin (* horizontale Achse *)
                if RSW then with UserField do begin
                (* vert. Raster *)
                  GridLineY (Y,Top,Bottom,RastFarbe);
                  end;
                (* grobe Skalenmarken und Beschriftung *)
                CPlot (Y,Pos-XG,3,0); CPlot (Y,Pos+XG,2,0);
                if ScText and not ((asNoZero in AxStyle) and (abs(XX)<ZwF))
                    and (IsZero(FXMaxLabel) or (XX<=FXMaxLabel)) then begin
                  if Pref then s:=FloatToPrefixStr(XX,nd,'',',')
                  else if Fixed then s:=FloatToFixStr(XX,nd,',')
                  else s:=FloatToPlotStr(XX,nd);
                  if CenterText then dx:=RelUserScale(N,-Zwf/2) else dx:=0;
                  PlotColStr (Y+XS+dx,Pos+YS,s,true,Align,Farbe);
                  end;
                end
              else begin (* vertikale Achse *)
                if RSW then with UserField do begin
                (* hor. Raster *)
                  GridLineX(Left,Right,Y,RastFarbe);
                  end;
                (* grobe Skalenmarken und Beschriftung *)
                CPlot (Pos-XG,Y,3,0); CPlot (Pos+XG,Y,2,0);
                if ScText and not ((asNoZero in AxStyle) and (abs(XX)<ZwF)) then begin
                  if Pref then s:=FloatToPrefixStr(XX,nd,'',',')
                  else if Fixed then s:=FloatToFixStr(XX,nd,',')
                  else s:=FloatToPlotStr(XX,nd);
                  if CenterText then dx:=-Zwf/2 else dx:=0;
                  PlotColStr (Pos+XS,Y+YS+dx,s,true,Align,Farbe);
                  end;
                end;
              end
            else begin
            (* feine Skalenmarken *)
              if VSW then begin
                CPlot (Pos-XF,Y,3,0); CPlot (Pos+XF,Y,2,0);
                end
              else begin
                CPlot (Y,Pos-XF,3,0); CPlot (Y,Pos+XF,2,0);
                end;
              end;
            end;
          end;
{        if DELTA < 0.0 then begin
          GR:=AInt(ScAnf/ZWG-0.9); XX:=AInt(ScAnf/ZWF-0.9);
          FEIN:=AInt(ScEnd/ZWF-0.9)-XX;
          end
        else begin
//          GR:=AInt(ScAnf/ZWG+1.1); XX:=AInt(ScAnf/ZWF+1.1);
          GR:=AInt(ScAnf/ZWG-0.1); XX:=AInt(ScAnf/ZWF-0.1);
          FEIN:=AInt(ScEnd/ZWF+0.1)-XX;
          end;
        AGROB:=GR*ZWG; ZWG:=SIGN(ZWG,DELTA);
        AFEIN:=XX*ZWF; ZWF:=SIGN(ZWF,FEIN);
        II:=round(ABS(FEIN));
    (* Länge der Skalenbeschriftung - nd = Stellen rechts vom Komma *)
(*        XX:=abs(ZWG); Normal (XX,GR,c);
        Y:=abs(Delta); Normal (Y,GR,c);
        if abs(Y/XX)<0.2 then nd:=-1 else nd:=0; *)
        if Digits=AutoDig then nd:=-round(aint(lg(abs(ZWG))))
        else nd:=Digits;
        for i:=0 to II do begin
          XX:=AFEIN+i*ZWF;
          if (ABS((XX-AGROB)/ZWF) <= 0.5) then begin
            if (XX>=ScAnf) and (XX<=ScEnd) then begin
              Y:=UserScale(N,XX);
      (* grobe Skalenmarken, Raster und Beschriftung *)
              if NOT VSW then begin
      (* horizontale Achse *)
                if RSW then with UserField do begin
      (* vert. Raster *)
                  CPlot (Y,Top,3,0); CPlot (Y,Bottom,2,0);
                  end;
      (* grobe Skalenmarken und Beschriftung *)
                CPlot (Y,Pos-XG,3,0); CPlot (Y,Pos+XG,2,0);
                if ScText and not ((asNoZero in AxStyle) and (abs(AGrob)<ZwF)) then begin
                  if Pref then
                     PlotColStr (Y+XS,Pos+YS,FloatToPrefixStr(XX,nd),Align,Farbe)
                  else PlotColStr (Y+XS,Pos+YS,ANumb(AGROB,nd),Align,Farbe);
                  end;
                end;
              AGROB:=AGROB+ZWG;
              end
            else begin
    (* vertikale Achse *)
              if RSW then with UserField do begin
    (* hor. Raster *)
                CPlot (Left,Y,3,0); CPlot (Right,Y,2,0);
                end;
    (* grobe Skalenmarken und Beschriftung *)
              CPlot (Pos-XG,Y,3,0); CPlot (Pos+XG,Y,2,0);
              if ScText and not ((asNoZero in AxStyle) and (abs(AGrob)<ZwF)) then begin
                if Pref then
                   PlotColStr (Pos+XS,Y+YS,FloatToPrefixStr(XX,nd),Align,Farbe)
                else PlotColStr (Pos+XS,Y+YS,ANumb(AGROB,nd),Align,Farbe);
                end;
              AGROB:=AGROB+ZWG;
              end;
            end;
          end;
    (* feine Skalenmarken *)
        with UserField do if VSW then CPlot (Pos,Top,3,0)
          else CPlot (Right,Pos,3,0);
        AGROB:=AGROB-ZWG;
        for i:=II downto 0 do begin
          XX:=AFEIN+i*ZWF;
          if ABS((XX-AGROB)/ZWF) <= 0.5 then AGROB:=AGROB-ZWG
          else begin
            Y:=UserScale(N,XX);
            if VSW then begin
              CPlot (Pos,Y,2,0); CPlot (Pos-XF,Y,2,0);
              CPlot (Pos+XF,Y,2,0); CPlot (Pos,Y,2,0);
              end
            else begin
              CPlot (Y,Pos,2,0); CPlot (Y,Pos-XF,2,0);
              CPlot (Y,Pos+XF,2,0); CPlot (Y,Pos,2,0);
              end;
            end;
          end; }
        (* Achsenlinie*)
        with UserField do if VSW then begin
          CPlot (Pos,Top,3,0); CPlot (Pos,Bottom,2,0);
          end
        else begin
          CPlot (Right,Pos,3,0);CPlot (Left,Pos,2,0);
          end;
        end
      else begin
  (* log. Skala - Skalierungsmarken berechnen *)
    (* Länge der Skalenbeschriftung - nd = signifikante Stellen *)
        if Digits=AutoDig then nd:=0 else nd:=Digits;
        XX:=ScEnd/ScAnf; NDek:=succ(trunc(lg(XX)));
        ii:=round(AInt(lg(scAnf)+0.001));
        if XX<=2.0 then begin
          jj:=89; Delta:=0.1;
          end
        else if XX<=5.0 then begin
          jj:=44; Delta:=0.2;
          end
        else if XX<=20.0 then begin
          jj:=17; Delta:=0.5;
          end
        else if XX<=100.0 then begin
            jj:=8; Delta:=1.0;
            end
          else if XX<=5E5 then begin
              jj:=1; Delta:=4.0; Fein:=1.0;
              end
            else begin
              jj:=0; Delta:=9.0; Fein:=1.0; kk:=9;
              end;
        with UserField do if VSW then CPlot (Pos,Bottom,3,0)
          else CPlot (Left,Pos,3,0);
        for i:=0 to NDek do begin
          for j:=0 to jj do begin   (* Raster *)
            Txt:=ScText; nd:=0;
            if jj=89 then begin
              if j<25 then begin
                kk:=3; Fein:=0.025;
                end
              else begin
                kk:=1; Fein:=0.05;
                Txt:=(j mod 2)=0;
                end;
              end
            else if jj=44 then begin
              if j<12 then begin
                kk:=3; Fein:=0.05;
                end
              else begin
                kk:=1; Fein:=0.1;
                Txt:=(j mod 5)=0;
                end;
              end
            else if jj=17 then begin
              if j<5 then begin
                kk:=4; Fein:=0.1;
                end
              else begin
                kk:=1; Fein:=0.25;
                Txt:=(j mod 2)=0;
                end;
              end
            else if jj=8 then begin
              if NDek=2 then begin
                if j<5 then begin
                  kk:=4; Fein:=0.2;
                  end
                else begin
                  kk:=1; Fein:=0.5;
                  Txt:=false;
                  end;
                end
              else begin
                if j<5 then begin
                  kk:=9; Fein:=0.1;
                  end
                else begin
                  kk:=4; Fein:=0.2;
                  end;
                end;
              end
            else if jj=1 then begin
//&              if j=0 then kk:=3 else kk:=4;
              if j=0 then begin
                kk:=7; Fein:=0.5;
                end
              else begin
                kk:=4; Fein:=1;
                end;
              end;
            for k:=0 to kk do begin
              xx:=(1.0+Delta*j+Fein*k)*Pwr(10.0,i+ii);
              if (xx>ScAnf) and (xx<ScEnd) then begin
                Y:=UserScale(N,XX);
                if NOT VSW then begin
                (* HORIZONTAL AXIS *)
                  CPlot (Y,Pos,2,0);
                  if k=0 then begin
                    if Rsw then with UserField do begin
                      GridLineY (Y,Top,Bottom,RastFarbe);
                      end;
                    if Txt then begin
                      if Pref then s:=FloatToPrefixStr(XX,nd,'',',')
                      else if Fixed then s:=FloatToFixStr(XX,nd,',')
                      else s:=FloatToPlotStr(XX,nd);
                      PlotColStr (Y+XS,Pos+YS,s,true,Align,Farbe);
                      end;
                    CPlot (Y,Pos-XG,3,0); CPlot (Y,Pos+XG,2,0);
                    end
                  else begin
                    CPlot (Y,Pos-XF,3,0); CPlot (Y,Pos+XF,2,0);
                    end;
                  CPlot (Y,Pos,3,0);
                  end
                else begin
                (* VERTICAL AXIS *)
                  CPlot (Pos,Y,2,0);
                  if k=0 then begin
                    if Rsw then with UserField do begin
                      GridLineX(Left,Right,Y,RastFarbe);
                      end;
                    if Txt then begin
                      if Pref then s:=FloatToPrefixStr(XX,nd,'',',')
                      else if Fixed then s:=FloatToFixStr(XX,nd,',')
                      else s:=FloatToPlotStr(XX,nd);
                      PlotColStr (Pos+XS,Y+YS,s,true,Align,Farbe);
                      end;
                    CPlot (Pos-XG,Y,3,0); CPlot (Pos+XG,Y,2,0);
                    end;
                  CPlot (Pos-XF,Y,3,0); CPlot (Pos+XF,Y,2,0);
                  CPlot (Pos,Y,3,0);
                  end;
                end;
              end;
            end;
          end;
        with UserField do if VSW then CPlot (Pos,Top,2,0)
        else CPlot (Right,Pos,2,0);
        end;
      end;
    with PlotCanvas.Pen do begin
      Color:=OldColor; Width:=OldWidth;
      end;
    if ScText then begin
      TextStyle:=OldTextStyle; TextHgt:=OldTextHgt; TextAngle:=OldTextAngle;
      end;
    end;
  end;

(* ----------procedure--Axis-------------------------------------------
   eine Koordinatenachse mit Beschriftung bei den groben Skalenmarken
   zeichnen mit TP-kompatibler Farbe
   (lin/log - siehe ScalDef) *)
procedure TPlot.Axis (varNr    : integer;
                      Pos,
                      Grob     : double;
                      Teil     : integer;
                      AxStyle  : TAxisStyles;
                      TPFarbe  : word);

(* Parameter siehe PlotColAxis
   TPFarbe:   Farbe der Axis (TP-Farben 0..15) *)
begin
  PlotColAxis (varNr,Pos,Grob,Teil,AxStyle,ConvColor(TPFarbe));
  end;

(* ------------------------------------------------------------------------ *)
(* Berechnung des groben Rasters einer Skala *)
function TPlot.GetGrid(varNr : integer) : double;
(* varNr =   Nummer der variable (1 -4 = hor., 5 - 8 = vert.)
   GetGrid = Rasterabstand in der Abstufung 1, 2, 5
             zu dem mit DefScale vorgebenen Bereich
   Bsp.:     Bereich von -1 bis 10 ==> GRaster = 2 *)
var
  xa,xb,dec   : double;
begin
  with Xsc[varNr] do begin
    xa:=ScEnd-ScAnf;
    end;
  try
    dec:=pwr(10.0,aint(lg(abs(xa))-0.05));
  except
    dec:=1;
    end;
  xa:=xa/dec;
  if xa<=2.1 then xb:=0.5 else
    if xa<=5.1 then xb:=1.0 else xb:=2.0;
  Result:=xb*dec;
  end;

(* Berechnung des groben Rasters einer Gradskala *)
function TPlot.GetDegreeGrid(varNr : integer) : double;
var
  xa,xb,dec   : double;
begin
  with Xsc[varNr] do begin
    xa:=ScEnd-ScAnf;
    end;
  dec:=pwr(10.0,aint(lg(abs(xa))-0.05)); xa:=xa/dec;
  if xa<=1.9 then xb:=0.25
  else if xa<=4.6 then xb:=0.5
  else if xa<=6.1 then xb:=1.0
  else xb:=1.5;
  Result:=xb*dec;
  end;
(* ------------------------------------------------------------------------ *)
(* Berechnung der feinen Unterteilung einer Skala *)
function TPlot.GetFGrid (varNr : integer;
                         Grob  : double) : integer;
(* varNr    =  Nummer der variable (1 -4 = hor., 5 - 8 = vert.)
   Grob     =  grobe Skalierung (s.o.)
   GetFGrid = Anzahl der Unterteilungen einer Grobskala *)
var
  xa   : double;
begin
  with Xsc[varNr] do begin
    xa:=ScFak*Grob; (* ein Raster in cm *)
    xa:=xa/AxisProperties.XF;
    end;
  if xa<=8 then Result:=2 else
    if xa<=15 then Result:=5 else Result:=10;
  end;


// Routinen für hor. Zeitachse
{ ------------------------------------------------------------------- }
(* Zeitskala definieren *)
procedure TPlot.DefTimeScale (TAnf,TEnd : TDateTime);
(*  TAnf  =    Anfangszeit
    TEnd  =    Endzeit
  Skalierung in Tsc:
       Tsc.Lin   = true (Lin)
       Tsc.Hor   = true (hor. Achse)
       Tsc.ScAnf = Anfangszeit
       Tsc.ScEnd = Endzeit
       Tsc.ScFak = Skalierungsfaktor
       Tsc.ScOff = Skalenoffset   *)
VAR
  PQ,PL  : double;
begin
  with UserField do begin
    PQ:=Right-Left; PL:=Left;
    end;
  if TEnd<=TAnf then TEnd:=TAnf+1/24.0;
  with Tsc do begin
    Lin:=true; Hor:=true;
    PQ:=PQ/(TEnd-TAnf); ScOff:=PL-PQ*TAnf;
    ScFak:=PQ; ScEnd:=TEnd; ScAnf:=TAnf;
    end;
  end;

{ ------------------------------------------------------------------- }
(* Umrechnung von Zeit auf cm *)
function TPlot.TimeScale (Val   : TDateTime) : double;
(* Val    =   Wert der Variable in Windows-Zeit.
   Result =  Wert in cm *)
begin
  with Tsc do Result:=ScFak*Val+ScOff
  end;

{ ------------------------------------------------------------------- }
(* Umrechnung von cm auf Zeit *)
function TPlot.InvTimeScale (Val   : double) : TDateTime;
(* Val    =   Wert der Variable in cm
   Result =  Wert in Windows-Zeit *)
begin
  with Tsc do Result:=(Val-ScOff)/ScFak;
  end;

{ ------------------------------------------------------------------- }
(*  berechnen der Rasterpunkte für eine Beschriftung
    der Zeitachse *)
function TPlot.TimeGrid (Anf,Ende                : TDateTime;
                         var AGrob,Zwg,AFein,Zwf : TDateTime;
                         var IFein               : integer) : boolean;
(*  Anf,Ende  : Zeitbereich im TDateTime-Format
    Ende muß größer sein als Anf
    es wird berechnet:
    AGrob - 1. Rasterpunkt
    Zwg -   Abstand der Rasterpunkte / Anzahl der Tage
    AFein - 1. Feinrasterpunkt
    Zwf -   Feinrasterabstand
    IFein - Anzahl der Feinrasterpunkte
    Result = true: ein Monat oder > 35 Tage, keine Rasterberechnung *)
var
  Delta,XG,XF,Fein : TDateTime;
begin
  Delta:=Ende-Anf+0.5*OneSecond;
  Result:=false;
  if Delta<0 then Delta:=1.0;
  if (DaysBetween(Anf,Ende)=DaysInMonth(Anf)) then begin // 1 Monat
    Zwg:=10; Zwf:=1; IFein:=0;
    AFein:=DateOf(Anf)+1; AGrob:=AFein+Zwg;
    Result:=true;
    Exit;
    end
  else if (Delta>35) then begin   (* mehr als 35 Tage *)
    if Delta<=93 then begin
      Zwg:=15; Zwf:=1; IFein:=1;
      AFein:=DateOf(Anf)+1; AGrob:=AFein+Zwg;
      end
    else if Delta<=189 then begin
      Zwg:=30; Zwf:=2; IFein:=2;
      AFein:=DateOf(Anf)+2; AGrob:=AFein+Zwg;
      end
    else begin
      Zwg:=60; Zwf:=5; IFein:=3;
      AFein:=DateOf(Anf)+5; AGrob:=AFein+Zwg;
      end;
    Result:=true;
    Exit;
    end
  else if Delta>20 then begin   (* mehr als 10 Tage *)
    Zwg:=5.0; Zwf:=12*OneHour;   (* 5 d, 12 h *)
    end
  else if Delta>10 then begin   (* mehr als 10 Tage *)
    Zwg:=2.0; Zwf:=6*OneHour;   (* 2 d, 6 h *)
    end
  else if Delta>5 then begin
    Zwg:=1.0; Zwf:=2*OneHour;   (* 1 d, 2 h *)
    end
  else if Delta>2 then begin
    Zwg:=0.5; Zwf:=OneHour;   (* 12 h, 1 h *)
    end
  else if Delta>1 then begin
    Zwg:=6*OneHour; Zwf:=30*OneMinute;   (* 6 h, 30 min *)
    end
  else if Delta>0.5 then begin   (* mehr als 12 h *)
    Zwg:=3*OneHour; Zwf:=15*OneMinute;   (* 3 h, 15 min *)
    end
  else if Delta>0.25 then begin   (* mehr als 6 h *)
    Zwg:=OneHour; Zwf:=5*OneMinute;   (* 1 h, 5 min *)
    end
  else if Delta>3*OneHour then begin   (* mehr als 3 h *)
    Zwg:=30*OneMinute; Zwf:=2*OneMinute;   (* 30 min, 2 min *)
    end
  else if Delta>OneHour then begin   (* mehr als 1 h *)
    Zwg:=15*OneMinute; Zwf:=OneMinute;   (* 15 min, 1 min *)
    end
  else if Delta>30*OneMinute then begin   (* mehr als 30 min *)
    Zwg:=5*OneMinute; Zwf:=30*OneSecond;   (* 5 min, 30 s *)
    end
  else if Delta>15*OneMinute then begin   (* mehr als 15 min *)
    Zwg:=2*OneMinute; Zwf:=15*OneSecond;   (* 2 min, 15 s *)
    end
  else if Delta>5*OneMinute then begin   (* mehr als 5 min *)
    Zwg:=OneMinute; Zwf:=5*OneSecond;   (* 1 min, 5 s *)
    end
  else if Delta>2*OneMinute then begin   (* mehr als 2 min *)
    Zwg:=30*OneSecond; Zwf:=2*OneSecond;   (* 30 s, 2 s *)
    end
  else if Delta>OneMinute then begin   (* mehr als 1 min *)
    Zwg:=15*OneSecond; Zwf:=OneSecond;   (* 15 s, 1 s *)
    end;
  XG:=AInt((Anf-0.5*OneSecond)/Zwg+1.0);
  XF:=AInt((Anf-0.5*OneSecond)/Zwf+1.0);
  Fein:=AInt(Ende/Zwf-0.1)-XF;
  AGrob:=XG*Zwg; Zwg:=ASign(Zwg,Delta);
  AFein:=XF*Zwf; Zwf:=ASign(Zwf,Fein);
  IFein:=round(abs(Fein));
  end;

{ ------------------------------------------------------------------- }
(* schreiben der Uhrzeit an der Stelle X,Y *)
function TPlot.PlotTime (X,Y         : double;
                         DT,Zwg      : TDateTime;
                         Align       : word;
                         Farbe       : TColor) : boolean;

(*  X,Y     Koordinaten der linken unteren Ecke der Beschriftung in cm
    DT      Datum und Zeit
    Zwg     Rasterabstand
    Align   siehe "PlotColStr" *)
var
  XL,dx : double;
  S     : String;
begin
  if Zwg<1 then begin  (* Raster feiner als 1 Tag *)
    if Zwg>=1/24.0 then s:='hh:00'
    else if Zwg>=OneSecond then s:='hh:nn'
      else s:='hh:nn:ss';
    s:=FormatDateTime (s,DT);
    XL:=0.5*GetTextWidth(S);
    with PlotField do dx:=Right-Left;
    if X+XL>dx then X:=dx-XL;
    PlotColStr (X,Y,S,false,Align,Farbe);
    Result:=true;
    end
  else Result:=false;
  end;

{ ------------------------------------------------------------------- }
(* schreiben des Datums an der Stelle X,Y *)
procedure TPlot.PlotDate (X,Y         : double;
                          DT          : TDateTime;
                          Wd          : boolean;
                          Align       : word;
                          Farbe       : TColor);
(*  X,Y     Koordinaten der linken unteren Ecke der Beschriftung in cm
    DT      Datum und Zeit
    Align   siehe "PlotColStr" *)
var
  XL,dx : double;
  S     : String;
begin
  if Wd then s:=FormatDateTime ('dd.mm.yy (ddd)',DT)
  else s:=FormatDateTime ('dd.mm.yy',DT);
  XL:=0.5*GetTextWidth(S);
  with PlotField do dx:=Right-Left;
  if X+XL>dx then X:=dx-XL;
  PlotColStr (X,Y,S,false,Align,Farbe);
  end;

{ ------------------------------------------------------------------- }
(* Hor. Zeitachse *)
procedure TPlot.TimeAxis (Pos      : double;
                          AxStyle  : TAxisStyles;
                          Farbe,RastFarbe : TColor);
var
  OldWidth,
  I,IFein      : integer;
  Grid,AFein,ng,
  Zwf,Zwg,XT   : TDateTime;
  X,Y,ts       : double;
  OldColor     : TColor;
  first,dr     : boolean;

  procedure PlotScaleMark(xt : double);
  begin
    with AxisProperties do begin
      X:=TimeScale(xt);
      if asGrid in AxStyle then with UserField do begin
      (* vert. Raster *)
        if RastFarbe<>clNone then SetPenColor(RastFarbe);
        CPlot (X,Top,pmUp,mmNoMark);
        CPlot (X,Bottom,pmDown,mmNoMark);
        if RastFarbe<>clNone then SetPenColor(Farbe);
        end;
    (* grobe Skalenmarken und Beschriftung *)
      CPlot (X,Pos-XG,pmUp,mmNoMark);
      CPlot (X,Pos+XG,pmDown,mmNoMark);
      Y:=Pos-Abst;
      PlotDate (X,Y,xt,asWeekday in AxStyle,alCenterTop,Farbe);
      end;
    end;

  procedure SetNextGrid;
  begin
    if IFein=0 then Grid:=IncDay(Grid,10)  // 1 Monat
    else if IFein=1 then Grid:=IncDay(Grid,15)   // < 94 Tage
    else if IFein=2 then Grid:=IncMonth(Grid,1)  // <= 189 Tage
    else Grid:=IncMonth(Grid,2)  // > 189 Tage
    end;

begin
  with PlotCanvas.Pen do begin
    OldColor:=Color; OldWidth:=Width;
    Color:=Farbe; Width:=round(scx0*AxisProperties.LnTh);
    end;
  ts:=GetTextHeight; SetTextHeight (AxisProperties.TSz);
  with Tsc do dr:=TimeGrid (ScAnf,ScEnd,Grid,Zwg,AFein,Zwf,IFein);
  first:=true;
  with AxisProperties do if dr then begin  // > 35 Tage oder genau ein Monat
    XT:=AFein; Zwg:=Zwf/2;
    Grid:=StartOfTheMonth(XT);
    if Tsc.ScAnf<=Grid then PlotScaleMark(Grid);     // Monatsmarke am Anfang
    SetNextGrid;
    ng:=Grid;
    while (XT>=Tsc.ScAnf) and (XT<Tsc.ScEnd) do begin
      dr:=(Grid-XT<Zwg);
      if dr then SetNextGrid;
      if dr then begin    // grobe Skalierung
        PlotScaleMark(ng);     // Monatsmarke
        ng:=Grid;
        end;
      (* feine Skalenmarken *)
      X:=TimeScale(XT);
      CPlot (X,Pos-XF,pmUp,mmNoMark);
      CPlot (X,Pos+XF,pmDown,mmNoMark);
      XT:=XT+Zwf;
      end;
    end
  else begin
    for i:=0 to IFein do begin
      XT:=AFein+i*Zwf; X:=TimeScale(XT);
      if ABS((XT-Grid)/Zwf) <= 0.5 then begin
     (*  zeichne die groben Skalierungen mit Beschriftung und
        das vertikale Raster der Hor. Achse *)
        if asGrid in AxStyle then with UserField do begin
        (* vert. Raster *)
          if RastFarbe<>clNone then SetPenColor(RastFarbe);
          CPlot (X,Top,pmUp,mmNoMark);
          CPlot (X,Bottom,pmDown,mmNoMark);
          if RastFarbe<>clNone then SetPenColor(Farbe);
          end;
      (* grobe Skalenmarken und Beschriftung *)
        CPlot (X,Pos-XG,pmUp,mmNoMark);
        CPlot (X,Pos+XG,pmDown,mmNoMark);
        Y:=Pos-Abst;
        if PlotTime (X,Y,Grid,Zwg,alCenterTop,Farbe) then
           y:=Y-1.2*TSz;
        if (First) or (abs(frac(Grid))<OneSecond) then begin
          PlotDate (X,Y,Grid,asWeekday in AxStyle,alCenterTop,Farbe);
          first:=false;
          end;
        Grid:=Grid+Zwg;
        end;
      end;
  (* feine Skalenmarken *)
    with UserField do CPlot (Right,Pos,pmUp,mmNoMark);
    Grid:=Grid-ZWG;
    with AxisProperties do for i:=IFein downto 0 do begin
      XT:=AFEIN+i*ZWF;
      if ABS((XT-Grid)/ZWF) <= 0.5 then Grid:=Grid-ZWG
      else begin
        X:=TimeScale(XT);
        CPlot (X,Pos-XF,pmUp,mmNoMark);
        CPlot (X,Pos+XF,pmDown,mmNoMark);
        end;
      end;
    end;
//  with UserField do CPlot (Left,Pos,pmDown,mmNoMark);
  PenColor:=OldColor;
  SetTextHeight (ts);
  end;

(* ------------------------------------------------------------------------ *)
(* ------------------------------------------------------------------------ *)
(* Zeichnen in Metafile oder Zwischenablage *)
constructor TPlotMetaFile.Create (ARect : TRect;
                                  APlot : TPlot);
begin
  inherited Create;
  with ARect do begin
    MMWidth:=(Right-Left)*10;                   // Größe in 0,01 mm
    MMHeight:=(Top-Bottom)*10;
    end;
//  FCanvas:=TMetaFileCanvas.Create (self,0);
  MetaPlot:=TPlot.Create(TMetaFileCanvas.Create (self,0));
  with MetaPlot do begin
    PlotField:=APlot.PlotField;                 // Größe von GrPlot übernehmen
    WindField:=APlot.WindField;
    SetClipWindow (ARect);                   // Abbildung auf Ausschnitt
//    SetReverseDir(true);
    end;
  end;

procedure TPlotMetaFile.SaveToFile (Filename : string);
begin
  SaveToFile(Filename);
  end;

procedure TPlotMetaFile.CopyToClipBoard;
var
  Mf       : word;
  AData    : THandle;
  APal     : HPalette;
begin
  SaveToClipBoardFormat(Mf,AData,APal);
  ClipBoard.SetAsHandle(Mf,AData);
  end;

destructor TPlotMetaFile.Destroy;
begin
  FCanvas.Free; MetaPlot.Free;
  inherited Destroy;
  end;

begin
  PlotColor:=StdPlotColor;
end.
