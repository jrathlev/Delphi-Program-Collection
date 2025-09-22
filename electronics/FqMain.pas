(* Delphi 10
   Graphical representation of the frequency responses of linear networks
   ======================================================================

   © 2006-2025 J. Rathlev D-24222 Schwentinental
      Web:  www.rathlev-home.de
      Mail: kontakt(a)rathlev-home.de

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Juni 2006
   last modified:  September 2025
   *)

unit FqMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ComCtrls, Vcl.Menus, Vcl.ExtCtrls, NumberEd,
  WinUtils, WinPlot, HListBox, Printers, PartDlg, VarValDlg;


resourcestring
  rsCaption = 'Calculation of frequency responses %s ';
  rsHelpName = 'fq-help-e.chm';

const
  Prog = 'Frequency Response';
  Vers = ' (Vers. 4.1)';

  DExt = 'nwd';

  DefWidth = 15;                 (* Spaltenbreite bei Export *)
  DefRand : TFRect = (Left : 1; Top : 1; Right : 1; Bottom : 1);

  TxtCol = clBlack;     (* Texte *)
  AxiCol = clBlack;     (* Achsen *)
  BgCol = white;        (* Hintergrund *)

  TitleHeight = 0.5;         (* Texthöhe für Diagramm-Titel in cm *)
  ProgVersHeight = 0.3;      (* Texthöhe für Progammversion in cm *)

  YAchsRand = 1.2;               (* X-Abstand der Y-Achse vom Rand*)
  XAchsRand = 1.2;               (* Y-Abstand der X-Achse vom Rand*)
  TitleSpace = 1.2*TitleHeight;  (* Platz am oberen Rand für Diagrammtitel*)
  BottomSpace = 0.8;             (* Platz am unteren Rand *)
  Abstand = 0.5;                 (* Abstand zwischen den beiden Systemen *)
  HorSpace = 0.25;               (* Rand links oder rechts ohne Achse *)

  URand          : TFRect =     (* Rand für Koord.system *)
    (Left : 0.75; Top : 0.75; Right : 0.25; Bottom :0.75);

  XVarNr = 1;
  YVarNr = 2;

  KuMax = 4;                     (* max. Anzahl Kurven/Ausgangsknoten *)
  FqMax = 500;                   (* max. Anzahl Freq.punkte *)

  fNorm = 1000.0;     (* Normierungsfrequenz *)
  RNorm = 1000.0;     (* Normierungswiderstand *)

  Pi2 = 2*Pi; InvPi = 1/Pi;

{$I ../../Common/JrGlobal.pas}

type
  TColorArr =  array[1..KuMax] of TColor;

const
  defCvFixColors : TColorArr = ($0000FF,$008000,$800080,$808000);
  defCvVarColors : TColorArr = ($4080FF,$40FF00,$FF00FF,$FFFF00);
  defCvFixStyle = SolidLn;
  defCvVarStyle = DashedLn;
  defCvFixWidth = 2;
  defCvVarWidth = 1;

  BitMapHeight=8;
  BitMapWidth=40;

type
  TFreqArr   = array[0..FqMax] of double;

  TFreqData = record
    Data      : TFreqArr;
    DColor    : TColor;
    DMin,DMax : double;
    end;

  TNodeArr   = array[1..KuMax] of integer;
  TPartArr   = array[1..PartMax] of TPart;
  TSortArr   = array[0..PartMax] of integer;
  TResArr    = array[1..KnMax] of double;
  TLwMatrix  = array[1..KnMax] of TResArr;

  TGlSysArr     = array[1..2*KnMax] of double;
  TGlSysMatrix  = array[1..2*KnMax] of TGlSysArr;
  TDataMatrix   = array[1..VarMax,1..KuMax] of TFreqData;

  TScaleMode = (scLin,scLog,scdB);
  TScale = record
    Auto : boolean;
    Mode : TScaleMode;
    SBeg,SEnd : double;
    end;

  TMainForm = class(TForm)
    pnlTools: TPanel;
    pnlData: TPanel;
    pnlDiagram: TPanel;
    StatusBar: TStatusBar;
    MainMenu: TMainMenu;
    Schaltung1: TMenuItem;
    ItemInfo: TMenuItem;
    ItemNew: TMenuItem;
    ItemLoad: TMenuItem;
    ItemSave: TMenuItem;
    N1: TMenuItem;
    ItemQuit: TMenuItem;
    gbCircuit: TGroupBox;
    lvParts: TListView;
    Label1: TLabel;
    btnNew: TBitBtn;
    btnEdit: TBitBtn;
    btnDel: TBitBtn;
    pcDiagram: TPageControl;
    tsFreq: TTabSheet;
    tsOk: TTabSheet;
    gbFreq: TGroupBox;
    gbAmpl: TGroupBox;
    gbPhas: TGroupBox;
    rbFrLin: TRadioButton;
    rbFrLog: TRadioButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    GrafikFeld: TPaintBox;
    btnShow: TBitBtn;
    btnNewCirc: TSpeedButton;
    rbAmLin: TRadioButton;
    rbAmLog: TRadioButton;
    rbAmdB: TRadioButton;
    cbAmAuto: TCheckBox;
    Label9: TLabel;
    Label10: TLabel;
    cbPhAuto: TCheckBox;
    Label11: TLabel;
    Label12: TLabel;
    edAmFrom: TEdit;
    edAmTo: TEdit;
    edPhFrom: TEdit;
    edPhTo: TEdit;
    edFrFrom: TEdit;
    edFrTo: TEdit;
    laDegFrom: TLabel;
    laDegTo: TLabel;
    N2: TMenuItem;
    Dateiliste: TMenuItem;
    ItemSaveAs: TMenuItem;
    edDescription: TEdit;
    GroupBox1: TGroupBox;
    Label18: TLabel;
    Label19: TLabel;
    cbRtAuto: TCheckBox;
    edRtFrom: TEdit;
    edRtTo: TEdit;
    gbImag: TGroupBox;
    Label23: TLabel;
    Label24: TLabel;
    cbItAuto: TCheckBox;
    edItFrom: TEdit;
    edItTo: TEdit;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    btnVar: TBitBtn;
    btnLoadCirc: TSpeedButton;
    btnSaveCirc: TSpeedButton;
    btnCopy: TSpeedButton;
    btnPrint: TSpeedButton;
    btnDraw: TSpeedButton;
    btnExit: TSpeedButton;
    gbNodes: TGroupBox;
    Label2: TLabel;
    edInput: TEdit;
    Label4: TLabel;
    edRef: TEdit;
    edOutputs: TEdit;
    Label3: TLabel;
    Einstellungen1: TMenuItem;
    ItemPrintSetup: TMenuItem;
    PrinterSetupDialog: TPrinterSetupDialog;
    Diagramm1: TMenuItem;
    ItemDraw: TMenuItem;
    ItemPrint: TMenuItem;
    ItemCopy: TMenuItem;
    ItemDir: TMenuItem;
    tsLines: TTabSheet;
    Label20: TLabel;
    Label21: TLabel;
    edLwFix: TFloatRangeEdit;
    edLwVar: TFloatRangeEdit;
    Label29: TLabel;
    pnlLsFix: TPanel;
    rbFixSolid: TRadioButton;
    rbFixDashed: TRadioButton;
    sbFix1: TSpeedButton;
    sbFix2: TSpeedButton;
    sbFix3: TSpeedButton;
    sbFix4: TSpeedButton;
    sbVar1: TSpeedButton;
    sbVar2: TSpeedButton;
    sbVar3: TSpeedButton;
    sbVar4: TSpeedButton;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Panel2: TPanel;
    Image2: TImage;
    rbFixDotted: TRadioButton;
    Image3: TImage;
    Image1: TImage;
    Label33: TLabel;
    pnlLsVar: TPanel;
    Image5: TImage;
    Image6: TImage;
    Image4: TImage;
    rbVarSolid: TRadioButton;
    rbVarDashed: TRadioButton;
    rbVarDotted: TRadioButton;
    ColorDialog: TColorDialog;
    pnColFix: TPanel;
    pnColVar: TPanel;
    Label28: TLabel;
    btnExport: TSpeedButton;
    ItemExport: TMenuItem;
    ItemHelp: TMenuItem;
    ItemShowHelp: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    udLwVar: TNumUpDown;
    udLwFix: TNumUpDown;
    procedure ItemQuitClick(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ItemSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNewClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure ItemNewClick(Sender: TObject);
    procedure ItemSaveAsClick(Sender: TObject);
    procedure ItemLoadClick(Sender: TObject);
    procedure GrafikFeldPaint(Sender: TObject);
    procedure cbAmAutoClick(Sender: TObject);
    procedure cbPhAutoClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure cbRtAutoClick(Sender: TObject);
    procedure cbItAutoClick(Sender: TObject);
    procedure ItemInfoClick(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure ItemPrintSetupClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure pcDiagramChange(Sender: TObject);
    procedure ItemDirClick(Sender: TObject);
    procedure btnVarClick(Sender: TObject);
    procedure lvPartsClick(Sender: TObject);
    procedure lvPartsExit(Sender: TObject);
    procedure sbFixClick(Sender: TObject);
    procedure sbVarClick(Sender: TObject);
    procedure edLwFixChange(Sender: TObject);
    procedure edLwVarChange(Sender: TObject);
    procedure DataModifiedClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnExportClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ItemShowHelpClick(Sender: TObject);
  private
    { Private-Deklarationen }
    DataPath,AppPath,
    PrgPath,PrgName,
    Ininame,VerName,
    SchName,
    PrtName        : string;
    PrSize         : TFPoint; (* Papiergröße in cm einschl. Rand *)
    PrPlot,
    GrPlot         : TPlot;
    FileList       : THistoryList;
    FormPos        : TRect;
    Calculated,
    DataModified   : boolean;
    GrSize         : TPoint;   { Bildschirmgrafikfenster in Pixel }
    PartCount      : integer;
    Parts          : TPartArr;
    ONodeCount,
    InNode         : integer;
    OutNodes       : TNodeArr;
    ScFreq,ScAmpl,
    ScPhase,ScReal,
    ScImag         : TScale;
    VarNdx,VarCount,
    NewVarCount    : integer;
    VarValues      : TVarArr;
    NPkt           : integer;
    Freq           : TFreqArr;
    Ampl,Phase,
    Real,Imag      : TDataMatrix;
    BitMap         : TBitMap;
    CvFixColors,
    CvVarColors    : TColorArr;
    CvFixStyle,
    CvVarStyle,
    CvFixWidth,
    CvVarWidth     : word;

    procedure InitLineStyles;
    procedure ShowLineStyles;
    procedure ShowStatus;
    procedure SetViewPort;
    procedure GetPaperSize (var PrSize : TFPoint);
    procedure InitPlotField (var APlot : TPlot);
    function DataChanged : boolean;
    procedure ResetChanged;
    function StringToOutNodes (s : string) : boolean;
    function OutNodesToString : string;
    function LoadCircuit(AFilename : string) : boolean;
    procedure SaveCircuit(AFilename : string);
    procedure NewCircuit;
    procedure ShowParts;
    procedure ShowScale;
    function ReadData : boolean;
    procedure SetStyles;
    procedure LoadDataListClick (Sender     : TObject;
                                 FileName   : string);
    procedure PlotDiagram;
    function Compute : boolean;
    procedure PlotRect (Canvas : TCanvas; BMWidth,BMHeight : integer; Farbe : TColor);
    procedure PlotKurve(APlot : TPlot);
  public
    { Public-Deklarationen }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses System.Math, Vcl.ClipBrd, System.IniFiles, GnuGetText,
  WinShell, WinApiUtils, FileUtils,
  StringUtils, PathUtils, NumberUtils, ShellDirDlg, MsgDialogs;

{ ------------------------------------------------------------------- }
const
  IniExt = 'ini';
  CfgSekt = 'Config';
  BildSekt = 'Form';
  FileSekt = 'Files';
  PrtSekt = 'Printer';
  FontSekt = 'Font';

  iniDir = 'WorkDir';
  iniLast = 'Last';
  iniName = 'Name';
  IniPrtIndex = 'PrtIndex';
  iniLeft = 'Left';
  iniTop = 'Top';
  iniWidth = 'Width';
  iniHeight = 'Height';

procedure TMainForm.FormCreate(Sender: TObject);
var
  IniFile  : TMemIniFile;
  s        : string;
  i        : integer;
  ok       : boolean;
begin
  TranslateComponent(self);
  PrgPath:=ExtractFilePath(Application.ExeName);
  PrgName:=ExtractFileName(DelExt(Application.ExeName));
  VerName:=GetFileVersionName(Application.Exename,Prog,Vers);
  DataPath:=GetPersonalFolder;
  AppPath:=GetAppDataFolder;
  if length(AppPath)>0 then begin
    AppPath:=SetDirName(AppPath)+AppSubDir;  // Pfad zu Anwendungsdaten
    ok:=ForceDirectories(AppPath);
    end
  else ok:=false;
  if not ok then AppPath:=DataPath;
  IniName:=Erweiter(AppPath,PrgName,IniExt);
  if FileExists(IniName) then s:=IniName
  else s:=Erweiter(PrgPath,PrgName,IniExt);
  IniFile:=TMemIniFile.Create(s);
  with IniFile do begin
    DataPath:=ReadString(CfgSekt,iniDir,DataPath);
    SchName:=ReadString(CfgSekt,iniLast,'');
    with FormPos do begin
      Left:=ReadInteger (BildSekt,iniLeft,25);
      Top:=ReadInteger (BildSekt,iniTop,25);
      Right:=ReadInteger (BildSekt,iniWidth,750);
      Bottom:=ReadInteger (BildSekt,iniHeight,550);
      end;
    WindowState:=TWindowState(ReadInteger (BildSekt,'State',Ord(wsNormal)));
    PrtName:=ReadString (PrtSekt,iniName,'');
    Free;
    end;
  Caption:=Format(rsCaption,[VerName])+_(' [unknown]');
  (* Datei-Menü erweitern *)
  FileList:=THistoryList.Create;
  with FileList do begin
    LoadFromIni (IniName,FileSekt);
    RadioMenu:=true;
    Menu:=DateiListe;
    OnAutoItemClick:=LoadDataListClick;
    end;
  GrPlot:=TPlot.Create (GrafikFeld.Canvas);
  Calculated:=false;
  with Printer do begin
    PrinterIndex:=Printers.IndexOf(PrtName);
    Orientation:=poPortrait;
    PrtName:=Printers[PrinterIndex];
    PrPlot:=TPlot.Create (Canvas);
    end;
  NPkt:=FqMax;       (* Anzahl der Stützpunkte < FqMax *)
  PartCount:=0; VarNdx:=0; VarCount:=0; NewVarCount:=0;
  BitMap:=TBitMap.Create;
  with BitMap do begin
    Height:=BitMapHeight; Width:=BitMapWidth;
    end;
  InitLineStyles;
  if ParamCount>0 then begin
    for i:=1 to ParamCount do begin
      s:=ParamStr(i);
      if not (s[1]='/') or (s[1]='-') then SchName:=Erweiter(DataPath,s,DExt);
      end;
    end;
  ResetChanged;
  FileList.SelectMenuItem(SchName);
  laDegFrom.Caption:=#176;
  laDegTo.Caption:=#176;
  end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if DataChanged and ConfirmDialog (Prog,_('Save circuit?')) then ItemSaveClick(Sender);
  try HtmlHelp(0,nil,HH_CLOSE_ALL,0); except end;
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
var
  IniFile  : TMemIniFile;
begin
  DefaultInstance.DebugLogToFile('ggt.log');
  IniFile:=TMemIniFile.Create(IniName);
  with IniFile do begin
    WriteString(CfgSekt,iniDir,DataPath);
    WriteString(CfgSekt,iniLast,SchName);
    WriteInteger (BildSekt,'Left',Left);
    WriteInteger (BildSekt,'Top',Top);
    WriteInteger (BildSekt,'Width',ClientWidth);
    WriteInteger (BildSekt,'Height',ClientHeight);
    WriteInteger (BildSekt,'State',ord(WindowState));
    WriteString (PrtSekt,'Name',PrtName);
    UpdateFile;
    Free;
    end;
  with FileList do begin
    SaveToIni (IniName,FileSekt,true);
    Free;
    end;
  BitMap.Free;
  GrPlot.Free;
  PrPlot.Free;
  end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  GetPaperSize(PrSize);
  { Bildschirmfenster }
  Left:=FormPos.Left; Top:=FormPos.Top;
  ClientWidth:=FormPos.Right; ClientHeight:=FormPos.Bottom;
  InitPlotField (GrPlot);
  ShowStatus;
  if (length(SchName)>0) then begin
    if not LoadCircuit(SchName) then NewCircuit;
    end
  else NewCircuit;
  end;

procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key=#$0D then Key:=#0;
  end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key=VK_RETURN) then btnShowClick(Sender);
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.ShowStatus;
begin
  with Printer do begin
    if Printers.Count>0 then begin
      PrtName:=Printers[PrinterIndex];
      StatusBar.SimpleText:=_(' Printer: ')+PrtName;
      ItemPrint.Enabled:=true;
      btnPrint.Enabled:=true;
      end
    else begin
      StatusBar.SimpleText:=_(' No printer installed');
      ItemPrint.Enabled:=false;
      BtnPrint.Enabled:=false;
      end;
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.ItemQuitClick(Sender: TObject);
begin
  Close;
  end;

function TMainForm.DataChanged : boolean;
var
  i   : integer;
begin
  for i:=0 to ComponentCount-1 do if Components[i] is TCustomEdit then begin
    DataModified:=DataModified or (Components[i] as TCustomEdit).Modified;
    end;
  Result:=DataModified;
  DataModified:=false;
  end;

procedure TMainForm.ResetChanged;
var
  i   : integer;
begin
  for i:=0 to ComponentCount-1 do if Components[i] is TCustomEdit then begin
    (Components[i] as TCustomEdit).Modified:=false;
    end;
  DataModified:=false;
  end;

{ ------------------------------------------------------------------- }
(* Zeichnen einer neuen Bitmap *)
procedure TMainForm.PlotRect (Canvas  : TCanvas;
                               BMWidth,BMHeight : integer;
                               Farbe            : TColor);
begin
  with BitMap.Canvas do begin
    Brush.Color:=clWhite;
    Brush.Style:=bsSolid;
    FillRect(Rect(0,0,BMWidth-1,BMHeight-1));
    Brush.Color:=Farbe; Pen.Color:=Farbe;
    Rectangle(2,2,BMWidth-3,BMHeight-3);
    end;
  end;

procedure TMainForm.InitLineStyles;
begin
  CvFixColors:=defCvFixColors;
  CvVarColors:=defCvVarColors;
  CvFixStyle:=defCvFixStyle;
  CvVarStyle:=defCvVarStyle;
  CvFixWidth:=defCvFixWidth;
  CvVarWidth:=defCvVarWidth;
  ShowLineStyles;
  end;

procedure TMainForm.ShowLineStyles;
var
  i        : integer;
begin
  edLwFix.Value:=CvFixWidth/10;
  edLwVar.Value:=CvVarWidth/10;
  case CvFixStyle of
  DashedLn : rbFixDashed.Checked:=true;
  DottedLn : rbFixDotted.Checked:=true;
    else rbFixSolid.Checked:=true;
    end;
  case CvVarStyle of
  DashedLn : rbVarDashed.Checked:=true;
  DottedLn : rbVarDotted.Checked:=true;
    else rbVarSolid.Checked:=true;
    end;
  with pnColFix do for i:=0 to ControlCount-1 do if (Controls[i] is TSpeedButton) then
   with (Controls[i] as TSpeedButton) do begin
    PlotRect(BitMap.Canvas,BitMapWidth,BitMapHeight,CvFixColors[Tag]);
    Glyph:=BitMap;
    end;
  with pnColVar do for i:=0 to ControlCount-1 do if (Controls[i] is TSpeedButton) then
   with (Controls[i] as TSpeedButton) do begin
    PlotRect(BitMap.Canvas,BitMapWidth,BitMapHeight,CvVarColors[Tag]);
    Glyph:=BitMap;
    end;
  end;

{ ------------------------------------------------------------------- }
const
  GlobSekt = 'Global';
  PartSekt = 'Part';
  MultiSekt = 'MultiVal';
  FreqSekt = 'Frequency';
  AmplSekt = 'Amplitude';
  PhasSekt = 'Phase';
  RealSekt = 'RealPart';
  ImagSekt = 'ImagPart';
  FLnSekt =  'FixLine';
  VLnSekt =  'VarLine';

  nwdDesc  = 'Description';
  nwdPCount = 'PartCount';
  nwdInNd  = 'InputNode';
  nwdOutNd = 'OutputNode';
  nwdType  = 'Type';
  nwdNum   = 'Number';
  nwdVal   = 'Value';
  nwdFreq  = 'CoFreq';
  nwdKnP   = 'NodeP';
  nwdKnN   = 'NodeN';
  nwdKnO   = 'NodeO';
  nwdCount = 'Count';
  nwdIndex = 'Index';
  nwdAuto  = 'AutoScale';
  nwdScale = 'ScaleType';
  nwdBeg   = 'ScaleFrom';
  nwdEnd   = 'ScaleTo';
  nwdColor = 'Color';
  nwdWidth = 'Width';
  nwdStyle = 'Style';

function TMainForm.StringToOutNodes (s : string) : boolean;
var
  n    : integer;
  err  : boolean;
begin
  ONodeCount:=0; err:=false;
  while (length(s)>0) and not err do begin
    n:=ReadNxtInt(s,',',0,err);
    if not err then begin
      inc(ONodeCount);
      OutNodes[ONodeCount]:=n;
      end;
    end;
  Result:=err;
  end;

function TMainForm.OutNodesToString : string;
var
  i : integer;
begin
  Result:='';
  for i:=1 to ONodeCount do begin
    Result:=Result+IntToStr(OutNodes[i]);
    if i<ONodeCount then Result:=Result+',';
    end;
  end;

function TMainForm.LoadCircuit(AFilename : string) : boolean;
var
  DatFile  : TMemIniFile;
  i,n      : integer;
  s        : string;

  procedure ReadScale (Sekt : string; var AScale : TScale);
  begin
    with DatFile,AScale do begin
      Auto:=ReadBool(Sekt,nwdAuto,Auto);
      Mode:=TScaleMode(ReadInteger(Sekt,nwdScale,integer(Mode)));
      SBeg:=ReadFloat(Sekt,nwdBeg,SBeg);
      SEnd:=ReadFloat(Sekt,nwdEnd,SEnd);
      end;
    end;

begin
  if FileExists(AFilename) then begin
    NewCircuit;
    SchName:=AFilename;
    Caption:=Format(rsCaption,[VerName])+'['+ExtractFilename(AFilename)+']';
    DatFile:=TMemIniFile.Create(AFileName);
    with DatFile do begin
      edDescription.Text:=ReadString(GlobSekt,nwdDesc,'');
      PartCount:=ReadInteger(GlobSekt,nwdPCount,0);
      InNode:=ReadInteger(GlobSekt,nwdInNd,1);
      edInput.Text:=IntToStr(InNode);
      StringToOutNodes (ReadString(GlobSekt,nwdOutNd,'2'));
      edOutputs.Text:=OutNodesToString;
      for i:=1 to PartCount do with Parts[i] do begin
        s:=PartSekt+ZStrInt(i,2);
        Typ:=TPartType(ReadInteger(s,nwdType,integer(ptR)));
        Nr:=ReadInteger(s,nwdNum,1);
        KnP:=ReadInteger(s,nwdKnP,0);
        KnN:=ReadInteger(s,nwdKnN,0);
        KnO:=ReadInteger(s,nwdKnO,0);
        Desc:=ReadString(s,nwdDesc,'');
        Value:=ReadFloat(s,nwdVal,1000);
        Freq:=ReadFloat(s,nwdFreq,20);
        end;
      VarNdx:=ReadInteger(MultiSekt,nwdIndex,0);
      n:=ReadInteger(MultiSekt,nwdCount,0);
      SetLength(VarValues,n);
      for i:=0 to n-1 do
        VarValues[i]:=ReadFloat(MultiSekt,nwdVal+ZStrInt(i+1,2),(i+1)*100);
      ReadScale(FreqSekt,ScFreq);
      ReadScale(AmplSekt,ScAmpl);
      ReadScale(PhasSekt,ScPhase);
      ReadScale(RealSekt,ScReal);
      ReadScale(ImagSekt,ScImag);
      CvFixStyle:=ReadInteger(FLnSekt,nwdStyle,defCvFixStyle);
      CvFixWidth:=ReadInteger(FLnSekt,nwdWidth,defCvFixWidth);
      for i:=1 to KuMax do
        CvFixColors[i]:=ReadInteger (FLnSekt,nwdColor+IntToStr(i),defCvFixColors[i]);
      CvVarStyle:=ReadInteger(VLnSekt,nwdStyle,defCvVarStyle);
      CvVarWidth:=ReadInteger(VLnSekt,nwdWidth,defCvVarWidth);
      for i:=1 to KuMax do
        CvVarColors[i]:=ReadInteger (VLnSekt,nwdColor+IntToStr(i),defCvVarColors[i]);
      Free;
      end;
    ShowParts;
    ShowScale;
    ShowLineStyles;
    ResetChanged;
    Calculated:=Compute;
    Result:=true;
    end
  else begin
    ErrorDialog(Prog,Format(_('File "%s" not found!'),[AFilename]));
    FileList.RemString(AFilename);
    FileList.SelectMenuItem(SchName);
    Result:=false;
    end;
  end;

procedure TMainForm.SaveCircuit(AFilename : string);
var
  DatFile  : TMemIniFile;
  i,n      : integer;
  s        : string;

  procedure WriteScale (Sekt : string; const AScale : TScale);
  begin
    with DatFile,AScale do begin
      WriteBool(Sekt,nwdAuto,Auto);
      WriteInteger(Sekt,nwdScale,integer(Mode));
      WriteString(Sekt,nwdBeg,FloatToStrE(SBeg,5,FormatSettings.DecimalSeparator));
      WriteString(Sekt,nwdEnd,FloatToStrE(SEnd,5,FormatSettings.DecimalSeparator));
      end;
    end;

begin
  DatFile:=TMemIniFile.Create(AFileName);
  with DatFile do begin
    WriteString(GlobSekt,nwdDesc,edDescription.Text);
    WriteInteger(GlobSekt,nwdPCount,PartCount);
    WriteInteger(GlobSekt,nwdInNd,InNode);
    WriteString(GlobSekt,nwdOutNd,OutNodesToString);
    for i:=1 to PartCount do with Parts[i] do begin
      s:=PartSekt+ZStrInt(i,2);
      WriteInteger(s,nwdType,integer(Typ));
      WriteInteger(s,nwdNum,Nr);
      WriteInteger(s,nwdKnP,KnP);
      WriteInteger(s,nwdKnN,KnN);
      WriteInteger(s,nwdKnO,KnO);
      WriteString(s,nwdDesc,Desc);
      WriteString(s,nwdVal,FloatToStrE(Value,5,FormatSettings.DecimalSeparator));
      WriteString(s,nwdFreq,FloatToStrE(Freq,5,FormatSettings.DecimalSeparator));
      end;
    WriteInteger(MultiSekt,nwdIndex,VarNdx);
    n:=length(VarValues);
    WriteInteger(MultiSekt,nwdCount,n);
    for i:=0 to n-1 do
      WriteString(MultiSekt,nwdVal+ZStrInt(i+1,2),FloatToStrE(VarValues[i],5,FormatSettings.DecimalSeparator));
    WriteScale(FreqSekt,ScFreq);
    WriteScale(AmplSekt,ScAmpl);
    WriteScale(PhasSekt,ScPhase);
    WriteScale(RealSekt,ScReal);
    WriteScale(ImagSekt,ScImag);
    WriteInteger(FLnSekt,nwdStyle,CvFixStyle);
    WriteInteger(FLnSekt,nwdWidth,CvFixWidth);
    for i:=1 to KuMax do WriteInteger (FLnSekt,nwdColor+IntToStr(i),CvFixColors[i]);
    WriteInteger(VLnSekt,nwdStyle,CvVarStyle);
    WriteInteger(VLnSekt,nwdWidth,CvVarWidth);
    for i:=1 to KuMax do WriteInteger (VLnSekt,nwdColor+IntToStr(i),CvVarColors[i]);
    UpdateFile;
    Free;
    end;
  ResetChanged;
  end;

procedure TMainForm.NewCircuit;
begin
  edDescription.Text:='';
  PartCount:=0;
  InNode:=1;
  ONodeCount:=1;
  OutNodes[1]:=2;
  VarCount:=0; VarValues:=nil;
  lvParts.Clear;
  with ScFreq do begin
    Auto:=true; Mode:=scLog;
    SBeg:=10; SEnd:=1E5;
    end;
  with ScAmpl do begin
    Auto:=true; Mode:=scdB;
    SBeg:=-50; SEnd:=10;
    end;
  with ScPhase do begin
    Auto:=true; Mode:=scLin;
    SBeg:=-90; SEnd:=80;
    end;
  with ScReal do begin
    Auto:=true; Mode:=scLin;
    SBeg:=-1; SEnd:=1;
    end;
  with ScImag do begin
    Auto:=true; Mode:=scLin;
    SBeg:=-1; SEnd:=1;
    end;
  Calculated:=false;
  ShowScale;
  InitLineStyles;
  Caption:=Format(rsCaption,[VerName])+_(' [unknown]');
  ResetChanged;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.ShowParts;
var
  i,j   : integer;
  pt  : TPartType;
  s   : string;
begin
  with lvParts do begin
    Clear;
    Items.BeginUpdate;
    for pt:=ptR to ptOP do begin
      for i:=1 to PartCount do with Parts[i] do if Typ=pt then begin
        with Items.Add do begin
          Caption:=PartNames[Typ]+IntToStr(Nr);
          Data:=pointer(i);
          if Typ=ptOP then begin
            SubItems.Add(Desc);
            SubItems.Add(IntToStr(KnP)+' | '+IntToStr(KnN)+' -> '+IntToStr(KnO));
            end
          else begin
            s:=FloatToPrefixStr(Value,4);
            if (VarNdx=i) and (length(VarValues)>0) then begin
              s:=s+' ('+FloatToPrefixStr(VarValues[0],4);
              for j:=1 to High(VarValues) do s:=s+','+FloatToPrefixStr(VarValues[j],4);
              s:=s+')';
              end;
            SubItems.Add(s);
            SubItems.Add(IntToStr(KnP)+' - '+IntToStr(KnN));
            end;
          end;
        end;
      end;
    Items.EndUpdate;
    if Items.Count>0 then begin
      ItemIndex:=0;
      btnVar.Enabled:=Parts[integer(Items[0].Data)].Typ<>ptOP;
      end;
    end;
  edInput.Text:=IntToStr(InNode);
  edOutputs.Text:=OutNodesToString;
  end;

procedure TMainForm.ShowScale;
begin
  with ScFreq do begin
    if Mode=scLin then rbFrLin.Checked:=true
    else rbFrLog.Checked:=true;
    edFrFrom.Text:=FloatToPrefixStr(SBeg,4);
    edFrTo.Text:=FloatToPrefixStr(SEnd,4);
    end;
  with ScAmpl do begin
    cbAmAuto.Checked:=Auto;
    if Mode=scLin then rbAmLin.Checked:=true
    else if Mode=scLog then rbAmLog.Checked:=true
    else rbAmDb.Checked:=true;
    edAmFrom.Text:=FloatToPrefixStr(SBeg,4);
    edAmTo.Text:=FloatToPrefixStr(SEnd,4);
    end;
  with ScPhase do begin
    cbPhAuto.Checked:=Auto;
    edPhFrom.Text:=FloatToPrefixStr(SBeg,4);
    edPhTo.Text:=FloatToPrefixStr(SEnd,4);
    end;
  with ScReal do begin
    cbRtAuto.Checked:=Auto;
    edRtFrom.Text:=FloatToPrefixStr(SBeg,4);
    edRtTo.Text:=FloatToPrefixStr(SEnd,4);
    end;
  with ScImag do begin
    cbItAuto.Checked:=Auto;
    edItFrom.Text:=FloatToPrefixStr(SBeg,4);
    edItTo.Text:=FloatToPrefixStr(SEnd,4);
    end;
  end;

function TMainForm.ReadData : boolean;
begin
  Result:=false;
  try
    InNode:=StrToInt(edInput.Text);
  except
    ErrorDialog(Prog,rsNumError); edInput.SetFocus; Exit;
    end;
  if StringToOutNodes (edOutputs.Text) then begin
    ErrorDialog(Prog,rsNumError); edOutputs.SetFocus; Exit;
    end;
  with ScFreq do begin
    if rbFrLin.Checked then Mode:=scLin else Mode:=scLog;
    if not PrefixStrToVal(edFrFrom.Text,SBeg) then begin
      ErrorDialog(Prog,rsNumError); edFrFrom.SetFocus; Exit;
      end;
    if not PrefixStrToVal(edFrTo.Text,SEnd) then begin
      ErrorDialog(Prog,rsNumError); edFrTo.SetFocus; Exit;
      end;
    end;
  with ScAmpl do begin
    Auto:=cbAmAuto.Checked;
    if rbAmLin.Checked then Mode:=scLin
    else if rbAmLog.Checked then Mode:=scLog
    else Mode:=scdB;
    if not PrefixStrToVal(edAmFrom.Text,SBeg) then begin
      ErrorDialog(Prog,rsNumError); edAmFrom.SetFocus; Exit;
      end;
    if not PrefixStrToVal(edAmTo.Text,SEnd) then begin
      ErrorDialog(Prog,rsNumError); edAmTo.SetFocus; Exit;
      end;
    end;
  with ScPhase do begin
    Auto:=cbPhAuto.Checked;
    if not PrefixStrToVal(edPhFrom.Text,SBeg) then begin
      ErrorDialog(Prog,rsNumError); edPhFrom.SetFocus; Exit;
      end;
    if not PrefixStrToVal(edPhTo.Text,SEnd) then begin
      ErrorDialog(Prog,rsNumError); edPhTo.SetFocus; Exit;
      end;
    end;
  with ScReal do begin
    Auto:=cbRtAuto.Checked;
    if not PrefixStrToVal(edRtFrom.Text,SBeg) then begin
      ErrorDialog(Prog,rsNumError); edRtFrom.SetFocus; Exit;
      end;
    if not PrefixStrToVal(edRtTo.Text,SEnd) then begin
      ErrorDialog(Prog,rsNumError); edRtTo.SetFocus; Exit;
      end;
    end;
  with ScImag do begin
    Auto:=cbItAuto.Checked;
    if not PrefixStrToVal(edItFrom.Text,SBeg) then begin
      ErrorDialog(Prog,rsNumError); edItFrom.SetFocus; Exit;
      end;
    if not PrefixStrToVal(edItTo.Text,SEnd) then begin
      ErrorDialog(Prog,rsNumError); edItTo.SetFocus; Exit;
      end;
    end;
  Result:=true;
  end;

procedure TMainForm.SetStyles;
begin
  if Calculated then begin
    if rbFixDashed.Checked then CvFixStyle:=DashedLn
    else if rbFixDotted.Checked then CvFixStyle:=DottedLn
    else CvFixStyle:=SolidLn;
    if rbVarDashed.Checked then CvVarStyle:=DashedLn
    else if rbVarDotted.Checked then CvVarStyle:=DottedLn
    else CvVarStyle:=SolidLn;
    CvFixWidth:=round(10*edLwFix.Value);
    CvVarWidth:=round(10*edLwVar.Value)
    end;
  end;

{ ------------------------------------------------------------------- }
(* Klick auf Dateilistenmenü *)
procedure TMainForm.LoadDataListClick (Sender     : TObject;
                                       FileName   : string);
begin
  if DataChanged and ConfirmDialog (Prog,_('Save circuit?')) then ItemSaveClick(Sender);
  LoadCircuit(Filename);
  end;

procedure TMainForm.ItemLoadClick(Sender: TObject);
begin
  if DataChanged and ConfirmDialog (Prog,_('Save circuit?')) then ItemSaveClick(Sender);
  with OpenDialog do begin
    if length(SchName)>0 then InitialDir:=ExtractFilePath(SchName)
    else InitialDir:=DataPath;
    DefaultExt:=DExt;
    Filename:=''; Filter:=_('Circuits')+'|*.'+DExt+_('|all')+'|*.*';
    Title:=_('Load circuit');
    if Execute then begin
      FileList.AddString(FileName);
      LoadCircuit(Filename);
      GrafikFeld.Invalidate;
      end;
    end;
  end;

procedure TMainForm.ItemSaveClick(Sender: TObject);
begin
  if ReadData then begin
    if length(SchName)>0 then SaveCircuit(SchName)
    else ItemSaveAsClick(Sender);
    end;
  end;

procedure TMainForm.ItemShowHelpClick(Sender: TObject);
begin
  HtmlHelp(GetDesktopWindow,pchar(PrgPath+rsHelpName),HH_DISPLAY_TOPIC,0);
  end;

procedure TMainForm.ItemSaveAsClick(Sender: TObject);
begin
  with SaveDialog do begin
    InitialDir:=DataPath;
    Filename:=DelExt(ExtractFilename(SchName));
    DefaultExt:=DExt;
    Filter:=_('Circuits')+'|*.'+DExt+_('|all')+'|*.*';
    Title:=_('Save circuit');
    if Execute then begin
      FileList.AddString(FileName);
      SaveCircuit(Filename);
      SchName:=Filename;
      Caption:=Format(rsCaption,[VerName])+'['+ExtractFilename(Filename)+']';
      end;
    end;
  end;

procedure TMainForm.ItemNewClick(Sender: TObject);
begin
  if DataChanged and ConfirmDialog (Prog,_('Save circuit?')) then ItemSaveClick(Sender);
  SchName:='';
  NewCircuit;
  edDescription.SetFocus;
  end;

{ ------------------------------------------------------------------- }
function TMainForm.Compute : boolean;
var
  KnSort                         : TSortArr;
  ResG,ResC,ResL,ResV,ResT       : TResArr;
  MatG,MatC,MatL,MatV            : TLwMatrix;
  dx0,dy0                        : double;
  NRest                          : integer;
  i,j,k                          : integer;
  LNorm,CNorm,OmNorm,SvVal       : double;

  {------------------------------------------------------------------}
  (* Minima und Maxima suchen *)
  procedure MinMax (var Data : TFreqData);
  var
    i : integer;
  begin
    with Data do begin
      DMin:=MaxDouble; DMax:=MinDouble;
      for i:=0 to NPkt do begin
        if (Data[i]<DMin) then DMin:=Data[i];
        if (Data[i]>DMax) then DMax:=Data[i];
        end;
      end;
    end;

  {------------------------------------------------------------------}
  (* nach DeziBel umrechnen *)
  function DeziBel (x : double) : double;
  begin
    if x>0.0 then DeziBel:=20.0*log10(x) else DeziBel:=-200.0;
    end;

  (* Bereiche für automatische Skalierung festlegen *)
  procedure InitAutoScale (var Scal : TScale; const Data : TDataMatrix);
  var
    k,j : integer;
    SMin,SMax,
    dx : double;
  begin
    SMin:=MaxDouble; SMax:=MinDouble;
    for k:=1 to VarCount+1 do for j:=1 to ONodeCount do with Data[k,j] do begin
      if (DMin<SMin) then SMin:=DMin;
      if (DMax>SMax) then SMax:=Dmax;
      end;
    with Scal do begin
      if Mode=scLin then begin
        if SMin=SMax then begin
          SMin:=SMin-0.5; SMax:=SMax+0.5;
          end;
        dx:=0.05*(SMax-SMin); SMin:=SMin-dx; SMax:=SMax+dx;
        if (Mode<>scLin) and (SMin<=0.0) then SMin:=SMax/1E6;
        end
      else begin
        if SMin=SMax then begin
          SMin:=0.95*SMin; SMax:=1.05*SMax;
          end;
        dx:=2; //1.0+0.01*SMax/SMin;
        SMin:=SMin/dx; SMax:=SMax*dx;
        end;
      if Auto then begin
        if Mode=scdB then begin
          SBeg:=DeziBel(SMin); SEnd:=DeziBel(SMax);
          end
        else begin
          SBeg:=SMin; SEnd:=SMax;
          end;
        end;
      end;
    end;

  {------------------------------------------------------------------}
  (* Lösung des Gleichungssystems *)
  function Householder (nz,ns     : integer;
                        var a     : TGlSysMatrix;
                        var x,y,d : TGlSysArr) : boolean;
  (* Ergebnis = true  : ok
                false : Singularität im Gleichungssystem *)
  var
    sigma,hi1,hi2,sum : double;
    i,j,k             : integer;
  begin
    Result:=false;
    for j:=1 to ns do begin
      sigma:=0.0;
      for i:=j to nz do sigma:=sigma+sqr(a[i,j]);
      if sigma>0.0 then begin
        sigma:=sqrt(sigma);
        if a[j,j]<0.0 then sigma:=-sigma;
        hi1:=a[j,j]+sigma; hi2:=1.0/(hi1*sigma);
        d[j]:=-sigma; a[j,j]:=hi1;
        if j<>ns then for k:=succ(j) to ns do begin
          sum:=0.0;
          for i:=j to nz do sum:=sum+a[i,j]*a[i,k];
          sum:=sum*hi2;
          for i:=j to nz do a[i,k]:=a[i,k]-sum*a[i,j];
          end;
        end
      else exit;
      sum:=0.0;
      for i:=j to nz do sum:=sum+a[i,j]*y[i];
      sum:=sum*hi2;
      for i:=j to nz do y[i]:=y[i]-sum*a[i,j];
      end;
    for i:=ns downto 1 do begin   (* Lösung berechnen *)
      sum:=0.0;
      for j:=succ(i) to ns do sum:=sum+a[i,j]*x[j];
      x[i]:=(y[i]-sum)/d[i];
      end;
    Result:=true;
    end;

  (* Netzwerkknoten sortieren *)
  procedure SortNodes;
  var
    i,j,KnLast  : integer;
  begin
    KnLast:=0;
    for i:=1 to PartCount do with Parts[i] do begin
      if KnP>KnLast then KnLast:=KnP;
      if KnN>KnLast then KnLast:=KnN;
      if (Typ=ptOP) and (KnO>KnLast) then KnLast:=KnO;
      end;
    for i:=0 to KnLast do KnSort[i]:=i;
    if InNode<>KnLast then begin
      i:=0;
      repeat inc(i) until KnSort[i]=InNode;
      j:=KnSort[KnLast]; KnSort[KnLast]:=InNode; KnSort[i]:=j;
      end;
    NRest:=pred(KnLast);
    end;

  {------------------------------------------------------------------}
  (* Frequenzgang berechnen *)
  function CompFq (nv : integer) : boolean;
  (* CompFq = true  : ok
            = false : Singularität im Intervall  *)
  var
    i,j,k,ip,
    quad,quado     : integer;
    Ls             : TGlSysMatrix;
    Loes,Rs,Di     : TGlSysArr;
    df,fnt,f,fn,hi,
    Rt,It          : double;
  begin
    Result:=false;
    for i:=1 to 2*KnMax do begin
      Rs[i]:=0.0; Loes[i]:=0.0; Di[i]:=0.0;
      for j:=0 to 2*KnMax do Ls[i,j]:=0.0;
      end;
    with ScFreq do begin
      if Mode=scLin then df:=(SEnd-SBeg)/NPkt
      else df:=exp(ln(SEnd/SBeg)/NPkt);
      f:=SBeg;
      end;
    for i:=0 to NPkt do begin
      Freq[i]:=f; fn:=f/fNorm;
      for j:=1 to NRest do
        for k:=1 to NRest do begin
          Ls[j,k]:=MatG[j,k];
          Ls[j,k+NRest]:=MatL[j,k]/fn-MatC[j,k]*fn;
          if ResT[j]<>0.0 then begin
            fnt:=fn*ResT[j]; hi:=MatV[j,k]/(1.0+sqr(fnt));
            Ls[j,k]:=Ls[j,k]+hi;
            Ls[j,k+NRest]:=Ls[j,k+NRest]+hi*fnt;
            end;
          end;
      for j:=1 to NRest do
        for k:=1 to NRest do begin
          Ls[j+NRest,k+NRest]:=Ls[j,k];
          Ls[j+NRest,k]:=-Ls[j,k+NRest];
          end;
      for j:=1 to NRest do begin
        Rs[j]:=ResG[j]; Rs[j+NRest]:=-ResL[j]/fn+ResC[j]*fn;
        if ResT[j]<>0.0 then begin
          fnt:=fn*ResT[j]; hi:=ResV[j]/(1.0+sqr(fnt));
          Rs[j]:=Rs[j]+hi; Rs[j+NRest]:=Rs[j+NRest]-hi*fnt;
          end;
        end;
      if Householder (2*NRest,2*NRest,Ls,Loes,Rs,Di) then begin
        for j:=1 to ONodeCount do begin
          Real[nv,j].Data[i]:=Loes[KnSort[OutNodes[j]]];         (* Realteil *)
          Imag[nv,j].Data[i]:=Loes[KnSort[OutNodes[j]]+NRest];   (* Imaginärteil *)
          end;
        end
      else Exit;  // Fehler
      if ScFreq.Mode=scLin then f:=f+df else f:=f*df;
      end;
    for j:=1 to ONodeCount do begin
      ip:=0;
      for i:=0 to NPkt do begin
        Rt:=Real[nv,j].Data[i]; It:=Imag[nv,j].Data[i];
        if (Rt>=0.0) then begin
          if (It>=0.0) then quad:=1 else quad:=4;
          end
        else begin
          if (It>=0.0) then quad:=2 else quad:=3;
          end;
        if i=0 then begin
          if quad=2 then ip:=1;
          if quad=3 then ip:=-1;
          end
        else begin
          if (quad=3) and (quado=4) then dec(ip);
          if (quad=4) and (quado=3) then inc(ip);
          if (quad=1) and (quado=2) then dec(ip);
          if (quad=2) and (quado=1) then inc(ip);
          end;
        quado:=quad;
        Phase[nv,j].Data[i]:=(arctan(It/Rt)*InvPi+ip)*180.0;
        Ampl[nv,j].Data[i]:=sqrt(sqr(Rt)+sqr(It));
        end;
      MinMax(Real[nv,j]);
      MinMax(Imag[nv,j]);
      MinMax(Phase[nv,j]);
      MinMax(Ampl[nv,j]);
      end;
    Result:=true;
    end;

{------------------------------------------------------------------}
(* Berechnung der Matrizen und Vektoren *)
begin
  Result:=false;
  VarCount:=length(VarValues);
  OmNorm:=Pi2*fNorm; LNorm:=RNorm/OmNorm; CNorm:=1.0/(RNorm*OmNorm);
  SortNodes;
  if VarNdx>0 then SvVal:=Parts[VarNdx].Value;
  for k:=0 to VarCount do begin
    if k>0 then Parts[VarNdx].Value:=VarValues[k-1];
    for i:=1 to KnMax do begin
      ResT[i]:=0.0; ResG[i]:=0.0; ResC[i]:=0.0; ResL[i]:=0.0; ResV[i]:=0.0;
      for j:=1 to KnMax do begin
        MatG[i,j]:=0.0; MatC[i,j]:=0.0; MatL[i,j]:=0.0; MatV[i,j]:=0.0;
        end;
      end;
    for i:=1 to PartCount do with Parts[i] do
      if not ((KnSort[KnP]=0) or (KnSort[KnN]=0) or
              (KnSort[KnP]=KnSort[InNode]) or
              (KnSort[KnN]=KnSort[InNode])) then
      case Typ of
      ptR : begin
            MatG[KnSort[KnP],KnSort[KnN]]:=-RNorm/Value;
            MatG[KnSort[KnN],KnSort[KnP]]:=-RNorm/Value;
            end;
      ptC : begin
            MatC[KnSort[KnP],KnSort[KnN]]:=-Value/CNorm;
            MatC[KnSort[KnN],KnSort[KnP]]:=-Value/CNorm;
            end;
      ptL : begin
            MatL[KnSort[KnP],KnSort[KnN]]:=-LNorm/Value;
            MatL[KnSort[KnN],KnSort[KnP]]:=-LNorm/Value;
            end;
        end;
    for i:=1 to NRest do for j:=1 to PartCount do with Parts[j] do
      if (KnSort[KnP]=i) or (KnSort[KnN]=i) then
      case Typ of
      ptR : MatG[i,i]:=MatG[i,i]+RNorm/Value;
      ptC : MatC[i,i]:=MatC[i,i]+Value/CNorm;
      ptL : MatL[i,i]:=MatL[i,i]+LNorm/Value;
        end;
    for j:=1 to PartCount do with Parts[j] do begin
      if KnSort[KnP]=KnSort[InNode] then
      case Typ of
      ptR : ResG[KnSort[KnN]]:=RNorm/Value;
      ptC : ResC[KnSort[KnN]]:=Value/CNorm;
      ptL : ResL[KnSort[KnN]]:=LNorm/Value;
        end;
      if KnSort[KnN]=KnSort[InNode]then  with Parts[j] do
      case Typ of
      ptR : ResG[KnSort[KnP]]:=RNorm/Value;
      ptC : ResC[KnSort[KnP]]:=Value/CNorm;
      ptL : ResL[KnSort[KnP]]:=LNorm/Value;
        end;
      end;
    for i:=1 to PartCount do with Parts[i] do if Typ=ptOP then begin
      for j:=1 to NRest do begin
        MatG[KnSort[KnO],j]:=0.0;
        MatC[KnSort[KnO],j]:=0.0;
        MatL[KnSort[KnO],j]:=0.0;
        end;
      ResG[KnSort[KnO]]:=0.0;
      ResC[KnSort[KnO]]:=0.0;
      ResL[KnSort[KnO]]:=0.0;
      ResT[KnSort[KnO]]:=fNorm/Freq;
      MatG[KnSort[KnO],KnSort[KnO]]:=1.0;
      if KnSort[KnP]<>0 then
        if KnSort[KnP]=KnSort[InNode] then
          ResV[KnSort[KnO]]:=Value
        else MatV[KnSort[KnO],KnSort[KnP]]:=-Value;
      if KnSort[KnN]<>0 then
        if KnSort[KnN]=KnSort[InNode] then
          ResV[KnSort[KnO]]:=-Value
        else MatV[KnSort[KnO],KnSort[KnN]]:=Value
      end;
    if not CompFq(k+1) then begin
      ErrorDialog(Prog,_('Error in calculation!'));
      end;
    end;
  if VarNdx>0 then Parts[VarNdx].Value:=SvVal;
  InitAutoScale (ScReal,Real);
  InitAutoScale (ScImag,Imag);
  InitAutoScale (ScAmpl,Ampl);
  InitAutoScale (ScPhase,Phase);
  Result:=true;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.GetPaperSize (var PrSize : TFPoint);
var
  xx : double;
begin
  with PrSize do begin
    GrPlot.GetPaperSize (Printer,X,Y);
    if x>y then begin
      xx:=x; x:=y; y:=xx;
      end;
    end;
  end;

procedure TMainForm.SetViewPort;
begin
  with GrSize do begin
    X:=GrafikFeld.Width; Y:=GrafikFeld.Height;
    end;
  GrPlot.SetScreenWindowEx (GrSize,
            Point(0,0),FPoint(1,1));
  end;

{ ------------------------------------------------------------------- }
(* Zeichenfeld auf Papiergröße einrichten *)
procedure TMainForm.InitPlotField (var APlot : TPlot);
var
  Rand  : TFRect;
begin
  (* Zeichenfläche *)
  Rand:=DefRand;
  with APlot do begin
    SetPlotField (PrSize,Rand);
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.PlotKurve(APlot : TPlot);
var
  x1,y1,x2,y2,
  dys,grid,x,ya,xa,
  xm,ym,xf,yf,
  xalt,yalt   : double;
  i,j,k,pm    : integer;
  sta         : TScaleType;
  axx,axy     : TAxisStyles;

  (* Fenster in normalisierten Koord. initianlisieren *)
  procedure IniClip (x1,y1,x2,y2 : double);
  begin
    xm:=0.5*(x2+x1); ym:=0.5*(y2+y1);
    xf:=0.5*(x2-x1); yf:=0.5*(y2-y1);
    xalt:=x1; yalt:=y1;
    end;

  (* Umrechnung von Plotkoord. in norm. Koord. *)
  function XNorm (x : double) : double;
  begin
    XNorm:=(x-xm)/xf;
    end;

  function YNorm (y : double) : double;
  begin
    YNorm:=(y-ym)/yf;
    end;

  (* Umrechnung von norm. Koord. in Plotkoord. *)
  function XPlot (x : double) : double;
  begin
    XPlot:=x*xf+xm;
    end;

  function YPlot (y : double) : double;
  begin
    YPlot:=y*yf+ym;
    end;

  (* Linien mit Bereichsprüfung zeichen *)
  procedure ClipPlot (xneu,yneu : double;
                      Md        : integer);
  (* Mode = 2,3 *)
  var
    x1,y1,x2,y2,dx,dy : double;
  begin
    if Md=2 then begin
      x1:=XNorm(xneu); y1:=YNorm(yneu);
      x2:=XNorm(xalt); y2:=YNorm(yalt);
      dx:=x1-x2; dy:=y1-y2;
      if (abs(x1)<=1.0) and (abs(y1)<=1.0) then begin
    (* neuer Punkt innerhalb *)
        if (abs(x2)>1.0) or (abs(y2)>1.0) then begin
    (* alter Punkt außerhalb *)
          if abs(y2)<abs(x2) then begin
            x2:=sign(x2); y2:=(x2-x1)*dy/dx+y1;
            end
          else begin
            y2:=sign(y2); x2:=(y2-y1)*dx/dy+x1;
            end;
          APlot.CPlot (XPlot(x2),YPlot(y2),3,0);
          end;
        APlot.CPlot (xneu,yneu,2,0);
        end
      else begin
    (* neuer Wert außerhalb *)
        if (abs(x2)<=1.0) and (abs(y2)<=1.0) then begin
    (* alter Punkt innerhalb *)
          if abs(y1)<abs(x1) then begin
            x1:=sign(x1); y1:=(x1-x2)*dy/dx+y2;
            end
          else begin
            y1:=sign(y1); x1:=(y1-y2)*dx/dy+x2;
            end;
          APlot.CPlot (XPlot(x1),YPlot(y1),2,0);
          end;
        end;
      end
    else APlot.CPlot (xneu,yneu,3,0);
    xalt:=xneu; yalt:=yneu;
    end;

begin
  with APlot do begin
    StartPlot(true,BGCol);                { Zeichenfeld löschen, Hintergrundfarbe setzen }
  (* Überschrift *)
    with PlotField do begin
      SetTextHeight (TitleHeight);
      PlotColStr(Left+0.5,Top,edDescription.Text,true,alCenterTop,TxtCol);
      SetTextHeight (ProgVersHeight);
      PlotColStr(Left+0.2,Bottom+0.25,Prog+Vers,true,alLeftBottom,TxtCol);
      PlotColStr(Right-0.2,Bottom+0.25,ExtractFilename(SchName)+' ('+
          FormatDateTime('d.m.yyyy',Date)+')',false,alRightBottom,TxtCol);
      x1:=Left+YAchsRand; x2:=Right-HorSpace;
      y1:=Bottom+BottomSpace;
      end;
    if pcDiagram.ActivePageIndex<>1 then begin  // Bode-Diagramm
      dys:=(PlotField.Top-y1-TitleSpace-Abstand)/2-TitleSpace-XAchsRand;
    // Amplitude
      y2:=y1+dys+Abstand+TitleSpace+1.5*XAchsRand;
      IniClip (x1,y2,x2,y2+dys);
      DefUserField (1,x1,x2,y2,y2+dys);
      with ScFreq do begin
        if Mode=scLin then sta:=stLin else sta:=stLog;
        DefUserScale (XVarNr,[sta,stHor],SBeg,SEnd);   (* X-Skala *)
        end;
      with ScAmpl do begin
        if Mode=scLog then sta:=stLog else sta:=stLin;
        DefUserScale (YVarNr,[sta,stVert],SBeg,SEnd);   (* Y-Skala *)
        end;
      grid:=GetGrid(XVarNr);
      PlotColAxis (XVarNr,y2,grid,GetFGRid(XVarNr,grid),[asBottom,asPrefix,asGrid],AxiCol);
      grid:=GetGrid(YVarNr);
      PlotColAxis (YVarNr,x1,grid,GetFGRid(YVarNr,grid),[asLeft,asPrefix,asGrid],AxiCol);
      SetTextHeight (AxisProperties.TSz);
      PlotColStr (PlotField.Left+0.2,y2+dys+0.4,_('Amplitude'),true,alLeftBottom,TxtCol);
      PlotColStr (x2,y2-1.8*AxisProperties.TSz,'f/Hz',true,alRightTop,AxiCol);
      for j:=1 to ONodeCount do begin
        for k:=VarCount downto 0 do begin
          if k=0 then begin
            SetLineStyle(CvFixStyle);
            PenColor:=CvFixColors[j];
            SetLineWidth(CvFixWidth);
            end
          else begin
            SetLineStyle(CvVarStyle);
            PenColor:=CvVarColors[j];
            SetLineWidth(CvVarWidth);
            end;
          pm:=pmUp;
          for i:=0 to NPkt do begin
            x:=Ampl[k+1,j].Data[i];
            if ScAmpl.Mode=scdB then x:=20.0*log10(x);
            ClipPlot (UserScale(XVarNr,Freq[i]),UserScale(YVarNr,x),pm);
            pm:=pmDown;
            end;
          end;
        SetLineStyle(SolidLn);
        end;
    // Phase
      y2:=y1+XAchsRand;
      IniClip (x1,y2,x2,y2+dys);
      DefUserField (1,x1,x2,y2,y2+dys);
      with ScFreq do begin
        if Mode=scLin then sta:=stLin else sta:=stLog;
        DefUserScale (XVarNr,[sta,stHor],SBeg,SEnd);   (* X-Skala *)
        end;
      with ScPhase do begin
        DefUserScale (YVarNr,[stLin,stVert],SBeg,SEnd);   (* Y-Skala *)
        end;
      grid:=GetGrid(XVarNr);
      PlotColAxis (XVarNr,y2,grid,GetFGRid(XVarNr,grid),[asBottom,asPrefix,asGrid],AxiCol);
      grid:=GetDegreeGrid(YVarNr);
      PlotColAxis (YVarNr,x1,grid,GetFGRid(YVarNr,grid),[asLeft,asPrefix,asGrid],AxiCol);
      SetTextHeight (AxisProperties.TSz);
      PlotColStr (PlotField.Left+0.2,y2+dys+0.4,_('Phase'),true,alLeftBottom,TxtCol);
      PlotColStr (x2,y2-1.8*AxisProperties.TSz,'f/Hz',true,alRightTop,AxiCol);
      for j:=1 to ONodeCount do begin
        for k:=VarCount downto 0 do begin
          if k=0 then begin
            SetLineStyle(CvFixStyle);
            PenColor:=CvFixColors[j];
            SetLineWidth(CvFixWidth);
            end
          else begin
            SetLineStyle(CvVarStyle);
            PenColor:=CvVarColors[j];
            SetLineWidth(CvVarWidth);
            end;
          pm:=pmUp;
          for i:=0 to NPkt do begin
            ClipPlot (UserScale(XVarNr,Freq[i]),UserScale(YVarNr,Phase[k+1,j].Data[i]),pm);
            pm:=pmDown;
            end;
          end;
        SetLineStyle(SolidLn);
        end;
      end
    else begin // Ortskurve
      dys:=PlotField.Top-y1-TitleSpace-XAchsRand;;
      y2:=y1+XAchsRand;
      with ScReal do begin                   // Realteil
        axx:=[asLeft];
        if SBeg<0.0 then begin
          x1:=PlotField.Left+HorSpace;
          if SEnd>0.0 then begin
            xa:=0.0;
            axx:=axx+[asNoZero];
            end
          else begin
            axx:=[asRight];
            x2:=PlotField.Right-YAchsRand;
            end;
          end
        else xa:=SBeg;
        end;
      with ScImag do begin                  // Imaginärteil
        axy:=[asBottom];
        if SBeg<0.0 then begin
          if SEnd>0.0 then begin
            ya:=0.0;
            axy:=axy+[asNoZero];
            y2:=y1;
            end
          else begin
            ya:=SEnd;
            axy:=[asTop];
            y2:=y1;
            dys:=dys+XAchsRand;
            end;
          end
        else ya:=SBeg;
        end;
      IniClip (x1,y2,x2,y2+dys);
      DefUserField (1,x1,x2,y2,y2+dys);
      with ScReal do                         // Realteil
        DefUserScale (XVarNr,[stLin,stHor],SBeg,SEnd);   (* X-Skala *)
      with ScImag do                         // Imaginärteil
        DefUserScale (YVarNr,[stLin,stVert],SBeg,SEnd);   (* Y-Skala *)
      ya:=UserScale(YVarNr,ya);   // Position der X-Achse
      xa:=UserScale(XVarNr,xa);   // Position der Y-Achse
      grid:=GetGrid(XVarNr);
      PlotColAxis (XVarNr,ya,grid,GetFGRid(XVarNr,grid),axx+[asPrefix,asGrid],AxiCol);
      grid:=GetGrid(YVarNr);
      PlotColAxis (YVarNr,xa,grid,GetFGRid(YVarNr,grid),axy+[asPrefix,asGrid],AxiCol);
      SetTextHeight (AxisProperties.TSz);
      PlotColStr (xa-XAchsRand+0.2,y2+dys+0.4,_('Imaginary part'),true,alLeftBottom,TxtCol);
      PlotColStr (x2,ya-1.8*AxisProperties.TSz,_('Real part'),true,alRightTop,AxiCol);
      for j:=1 to ONodeCount do begin
        for k:=VarCount downto 0 do begin
          if k=0 then begin
            SetLineStyle(CvFixStyle);
            PenColor:=CvFixColors[j];
            SetLineWidth(CvFixWidth);
            end
          else begin
            SetLineStyle(CvVarStyle);
            PenColor:=CvVarColors[j];
            SetLineWidth(CvVarWidth);
            end;
          pm:=pmUp;
          for i:=0 to NPkt do begin
            ClipPlot (UserScale(XVarNr,Real[k+1,j].Data[i]),UserScale(YVarNr,Imag[k+1,j].Data[i]),pm);
            pm:=pmDown;
            end;
          end;
        end;
      SetLineStyle(SolidLn);
      end;
    end;
  end;

procedure TMainForm.GrafikFeldPaint(Sender: TObject);
begin
  if Calculated then begin
    SetViewPort;
    PlotKurve(GrPlot);
    end;
  end;

procedure TMainForm.btnShowClick(Sender: TObject);
begin
  PlotDiagram;
  end;

procedure TMainForm.PlotDiagram;
begin
  if ReadData and Compute then begin
    Calculated:=true;
    GrafikFeld.Invalidate;
    end
  else begin
    ErrorDialog(Prog,_('Error during data processing!'));
    Calculated:=false;
    end;
  end;

{ ------------------------------------------------------------------- }
// Bauteile bearbeiten
procedure TMainForm.btnNewClick(Sender: TObject);
var
  i,n : integer;
  pt  : TPartType;
begin
  if PartCount<PartMax then begin
    inc(PartCount);
    Parts[PartCount]:=PartDialog.NewPart;
    if PartDialog.Execute(Parts[PartCount]) then begin
      // Teilenummer festlegen
      n:=0;
      pt:=Parts[PartCount].Typ;
      for i:=1 to PartCount-1 do with Parts[i] do
        if (Typ=pt) and (Nr>=n) then n:=Nr;
      Parts[PartCount].Nr:=n+1;
      ShowParts;
      DataModified:=true;
      end;
    end
  else ErrorDialog(Prog,_('Max. number of components: '+IntToStr(PartMax)));
  end;

procedure TMainForm.btnEditClick(Sender: TObject);
begin
  with lvParts do if ItemIndex>=0 then begin
    if PartDialog.Execute(Parts[integer(Items[ItemIndex].Data)]) then begin
      ShowParts;
      PlotDiagram;
      DataModified:=true;
      end;
    end;
  end;

procedure TMainForm.btnDelClick(Sender: TObject);
var
  i,n : integer;
  s   : string;
begin
  with lvParts do if (ItemIndex>=0) then begin
    n:=integer(Items[ItemIndex].Data);
    with Parts[n] do s:=PartNames[Typ]+IntToStr(Nr);
    if ConfirmDialog (Prog,Format(_('Remove %s from circuit?'),[s])) then begin
      dec(PartCount);
      for i:=n to PartCount do Parts[i]:=Parts[i+1];
      ShowParts;
      DataModified:=true;
      end;
    end;
  end;

procedure TMainForm.lvPartsClick(Sender: TObject);
begin
  with lvParts do if (ItemIndex>=0) then begin
    btnVar.Enabled:=Parts[integer(Items[ItemIndex].Data)].Typ<>ptOP;
    end
  else btnVar.Enabled:=false;
  end;

procedure TMainForm.lvPartsExit(Sender: TObject);
begin
  with lvParts do btnVar.Enabled:=(ItemIndex>=0);
  end;

procedure TMainForm.btnVarClick(Sender: TObject);
var
  n : integer;
  vv : TVarArr;
begin
  with lvParts do if ItemIndex>=0 then begin
    n:=integer(Items[ItemIndex].Data);
    if n=VarNdx then vv:=VarValues else vv:=nil;
    if VarValueDialog.Execute(Parts[n],vv) then begin
      VarValues:=vv;
      if length(vv)>0 then VarNdx:=n
      else VarNdx:=0;
      ShowParts;
      PlotDiagram;
      DataModified:=true;
      end;
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.ItemInfoClick(Sender: TObject);
begin
  InfoDialog(VerName+' - '+DateToStr(FileDateToDateTime(FileAge(Application.ExeName)))
    +sLineBreak+GetFileVersionCopyright(Application.ExeName,CopRgt));
  end;

procedure TMainForm.btnCopyClick(Sender: TObject);
var
  FMeta    : TMetaFile;
  MfPlot   : TPlot;
  ACanvas  : TMetaFileCanvas;
  Mf       : word;
  AData    : THandle;
  APal     : HPalette;
  ClipRect : TRect;
begin
  FMeta:=TMetaFile.Create;
  ClipRect:=GrPlot.WindField;
  with FMeta,ClipRect do begin
    MMWidth:=(Right-Left)*10;
    MMHeight:=(Top-Bottom)*10;
    end;
  ACanvas:=TMetaFileCanvas.Create (FMeta,0);
  MfPlot:=TPlot.Create(ACanvas);
  with MfPlot do begin
    PlotField:=GrPlot.PlotField;
    WindField:=GrPlot.WindField;
    SetClipWindow (ClipRect);
    end;
  PlotKurve(MfPlot);
  MfPlot.Free; ACanvas.Free;
  FMeta.SaveToClipBoardFormat(Mf,AData,APal);
  ClipBoard.SetAsHandle(Mf,AData);
  FMeta.Free;
  end;

procedure TMainForm.btnExportClick(Sender: TObject);
var
  FMeta    : TMetaFile;
  MfPlot   : TPlot;
  ACanvas  : TMetaFileCanvas;
  ClipRect : TRect;
begin
  with SaveDialog do begin
    InitialDir:=DataPath;
    Filename:=DelExt(ExtractFilename(SchName));
    DefaultExt:='emf';
    Filter:=_('Windows Meta file')+'|*.emf';
    Title:=_('Save diagram as Meta file');
    if Execute then begin
      FMeta:=TMetaFile.Create;
      ClipRect:=GrPlot.WindField;
      with FMeta,ClipRect do begin
        MMWidth:=(Right-Left)*10;
        MMHeight:=(Top-Bottom)*10;
        end;
      ACanvas:=TMetaFileCanvas.Create (FMeta,0);
      MfPlot:=TPlot.Create(ACanvas);
      with MfPlot do begin
        PlotField:=GrPlot.PlotField;
        WindField:=GrPlot.WindField;
        SetClipWindow (ClipRect);
        end;
      PlotKurve(MfPlot);
      MfPlot.Free; ACanvas.Free;
      FMeta.SaveToFile(Filename);
      FMeta.Free;
      end;
    end;
  end;

procedure TMainForm.ItemPrintSetupClick(Sender: TObject);
begin
  if PrinterSetupDialog.Execute then begin
    with Printer do PrtName:=Printers[PrinterIndex];
    GetPaperSize(PrSize);
    ShowStatus;
    InitPlotField (GrPlot);
    GrafikFeld.Invalidate;
    end;
  end;

procedure TMainForm.btnPrintClick(Sender: TObject);
begin
  if ConfirmDialog (Prog,Format(_('Start printing on %s?'),[PrtName])) then with Printer do begin
    BeginDoc;
    Title:=Prog+': '+edDescription.Text;
    InitPlotField (PrPlot);
    PrPlot.SetPrintWindow (shMargin);
    PlotKurve(PrPlot);
    EndDoc;
    end;
  end;

procedure TMainForm.ItemDirClick(Sender: TObject);
var
  s : string;
begin
  s:=DataPath;
  if ShellDirDialog.Execute(_('Directory for circuit files'),false,true,false,'',s) then begin
    DataPath:=s;
    end;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.pcDiagramChange(Sender: TObject);
begin
  GrafikFeld.Invalidate;
  end;

procedure TMainForm.DataModifiedClick(Sender: TObject);
begin
  SetStyles;
  pcDiagramChange(Sender);
  DataModified:=true;
  end;

procedure TMainForm.cbAmAutoClick(Sender: TObject);
begin
  edAmFrom.Enabled:=not cbAmAuto.Checked;
  edAmTo.Enabled:=not cbAmAuto.Checked;
  DataModified:=true;
  end;

procedure TMainForm.cbPhAutoClick(Sender: TObject);
begin
  edPhFrom.Enabled:=not cbPhAuto.Checked;
  edPhTo.Enabled:=not cbPhAuto.Checked;
  DataModified:=true;
  end;

procedure TMainForm.cbRtAutoClick(Sender: TObject);
begin
  edRtFrom.Enabled:=not cbRtAuto.Checked;
  edRtTo.Enabled:=not cbRtAuto.Checked;
  DataModified:=true;
  end;

procedure TMainForm.cbItAutoClick(Sender: TObject);
begin
  edItFrom.Enabled:=not cbItAuto.Checked;
  edItTo.Enabled:=not cbItAuto.Checked;
  DataModified:=true;
  end;

{ ------------------------------------------------------------------- }
procedure TMainForm.sbFixClick(Sender: TObject);
begin
  if Sender is TSpeedButton then with ColorDialog do begin
    Color:=CvFixColors[(Sender as TComponent).Tag];
    if Execute then begin
      CvFixColors[(Sender as TComponent).Tag]:=Color;
      PlotRect (Bitmap.Canvas,BitMapWidth,BitMapHeight,Color);
      (Sender as TSpeedButton).Glyph:=BitMap;
      DataModified:=true;
      pcDiagramChange(Sender);
      end;
    end;
  end;

procedure TMainForm.sbVarClick(Sender: TObject);
begin
  if Sender is TSpeedButton then with ColorDialog do begin
    Color:=CvVarColors[(Sender as TComponent).Tag];
    if Execute then begin
      CvVarColors[(Sender as TComponent).Tag]:=Color;
      PlotRect (Bitmap.Canvas,BitMapWidth,BitMapHeight,Color);
      (Sender as TSpeedButton).Glyph:=BitMap;
      DataModified:=true;
      pcDiagramChange(Sender);
      end;
    end;
  end;

procedure TMainForm.edLwFixChange(Sender: TObject);
begin
  SetStyles;
  pcDiagramChange(Sender);
  end;

procedure TMainForm.edLwVarChange(Sender: TObject);
begin
  SetStyles;
  pcDiagramChange(Sender);
  end;

end.
