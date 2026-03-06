unit HListBox;
{ enthält
   - THistoryList, verwendbar zur Verwaltung
     von geladenen Dateien und zum Anhängen an ein Menü
   - THistoryCombo, die Combobox, die diese
     die Eingaben automatisch in einer Liste sammelt

   Autor: Elmar Warken, 1995

   erweitert: J. Rathlev, Jun. 1996
   - THistoryCombo.AddItem hinzugefügt
   - Separator in THistoryList.AddMenuItems
   - FList (ähnlich FMenu) hinzugefügt zur Verwaltung der
     HistoryList in den Dialog-Komponenten
   - THistoryCombo.AddItemObject hinzugefügt, DoExit geändert
   - DoEnter und Modified hinzugefügt
   Feb. 2008:
   - 2. Menü für THistoryList
   Jun. 2009
   - SeparatorCount eingefügt, da sonst bei angehängten Menüs mit Ternnlinie
     in RemoveMenuItems der Index auf die Stringlist falsch berechnet wird
   Okt. 2012
   - Delete durch Free ersetzt, um den für TMenuItem belegten Speicher freizugeben
   Apr. 2022
   - opt. Unterdrückung von "&" als Hotkey (ShowHotKeys)
   - OnDrawItem hinzugefügt
   - OnMeasureItem hinzugefügt für opt. DPI-Skalierung
   Apr. 2024
   - LoadFromIni und SaveToIni erweitert
    }

interface

uses
  System.SysUtils, System.Types, WinApi.Messages, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.IniFiles, Vcl.Menus;

// Definiere CompPalPage (siehe Register)
{$Include UserComps.pas }

type
  { Event, das bei Anwahl eines der automatisch zum Menü
    hinzugefügten Einträge ausgelöst wird: }
  TListMenuEvent = procedure(Sender : TObject; MenuText : string)
                     of object;
  TListMenuEventIndex = procedure(Sender : TObject; Index : integer)
                     of object;

(* ----------------------------------------------------------------------- *)
{ Stringliste, die
  - sich selbst an ein Menü anhängen kann, wobei sie
    die Menüpunkte mit Zahlen durchnumeriert,
  - sich in eine INI-Datei speichern
    und von dort wieder lesen kann }
  THistoryList = class(TStringList)
  private
    FMenu,FMenu2 : TMenuItem;
    FList : TStrings;
    SeparatorCount,
    ListSizeBefore,
    MenuSizeBefore : integer;
    { Speichert die vorherige Menügröße zur späteren
      Rekonstruktion }
    FOnAutoItemClick       : TListMenuEvent;
    FOnAutoItemClickIndex  : TListMenuEventIndex;
    FOnAutoDrawItem        : TMenuDrawItemEvent;
    FOnAutoMeasureItem     : TMenuMeasureItemEvent;
    FShowHotKeys,
    FRadioMenu : boolean;
    FCheckedItem : string;

    procedure SetMenu(Menu : TMenuItem);
    procedure SetList(List : TStrings);
    procedure AddMenuItems;
    procedure RemoveMenuItems;
    procedure UpdateMenuItems;
    procedure AddListItems;
    procedure RemoveListItems;
    procedure SetShowHotKeys (Value : boolean);
    procedure SetRadioMenu (Value : boolean);

  protected
    FMaxLen : integer;
    procedure SetMaxLen(AnInt : integer);
    procedure DoAutoItemClick (Sender : TObject); virtual; // empfängt die OnClick-Ereignisse
    procedure DoAutoDrawItem (Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
    procedure DoAutoMeasureItem (Sender: TObject; ACanvas: TCanvas; var Width, Height: Integer);

  public
    constructor Create;
    destructor Destroy; override;

    { Maximale Länge der Liste, Voreinstellung 10
      (wird nicht gespeichert, daher kein default-Teil): }
    property MaxLen : integer read FMaxLen write SetMaxLen;

    { Aufnahme eines Strings in die Liste, doppelte
      werden gelöscht: }
    procedure AddString(s : string);
    procedure AddStringObject(s : string; AObject: TObject);

    { String aus der Liste entfernen }
    procedure RemString(s : string);
    procedure ClearAll;

    (* Menüeintrag auswählen
       Ergebnis = true - Eintrag vorhanden, = false - Eintrag nicht vorhanden *) 
    function SelectMenuItem (s : string) : boolean;

    { Funktionsbereich INI-Datei: die beiden folgenden
      Funktionen müssen manuell aufgerufen werden
      (für die Automatisierung gibt es die THistoryCombo): }
    procedure SaveToIni (IniFile : TCustomIniFile; const IniSection : string;
                        Erase : boolean); overload;
    procedure SaveToIni(const IniName, IniSection : string;
                        Erase : boolean); overload;
    procedure LoadFromIni (IniFile : TCustomIniFile; const IniSection : string); overload;
    procedure LoadFromIni(const IniName,IniSection : string); overload;

    procedure AssignList (AList : TStrings);

    { Funktionsbereich Menü: sobald Menu einmal gesetzt ist,
      paßt die Liste das Menü immer an. }
    property Menu : TMenuItem read FMenu write SetMenu;
    property Menu2 : TMenuItem read FMenu2 write FMenu2;

    { Funktionsbereich Liste: sobald StrList einmal gesetzt ist,
      passen sich die Listen immer an. }
    property StrList : TStrings read FList write SetList;

    property OnAutoItemClick : TListMenuEvent read FOnAutoItemClick write FOnAutoItemClick;
    property OnAutoItemClickIndex : TListMenuEventIndex read FOnAutoItemClickIndex
                                            write FOnAutoItemClickIndex;
    property OnAutoDrawItem: TMenuDrawItemEvent read FOnAutoDrawItem write FOnAutoDrawItem;
    property OnAutoMeasureItem: TMenuMeasureItemEvent read FOnAutoMeasureItem write FOnAutoMeasureItem;

    property ShowHotKeys : boolean read FShowHotKeys write SetShowHotKeys default true;
    property RadioMenu : boolean read FRadioMenu write SetRadioMenu default false;

    end;

(* ----------------------------------------------------------------------- *)
{ Combobox, die beim Laden aus einem Stream automatisch
  einen in einer INI-Datei gespeicherten Zustand wiederherstellt,
  und bei Programmende die INI-Datei aktualisiert.
  Setzt voraus, daß die Instanzen dieser Klasse aus einer
  Formulardatei geladen werden (anstatt dynamisch erzeugt zu
  werden). }
  THistoryCombo = class(TComboBox)
  private
    FSaveText    : string;
    FReadOnly,
    FModified,
    FAutoUpdate  : boolean; // JR - siehe DoExit
    property Items;
  protected
    FIniFileName,
    FIniSection  : string;
    FHistoryList : THistoryList;
    FEraseSection : boolean;  // JR - siehe SaveToIni

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override; { hier wird die INI-Datei geschrieben }
    procedure DoEnter; override;
    procedure DoExit; override; { hier wird die Liste aktualisiert }
    function GetMaxItems : integer;
    procedure SetMaxItems (n : integer);
    procedure SetReadOnly (Value : boolean);

  public
    procedure LoadFromIni(const IniName,IniSection : string); overload;
    procedure LoadFromIni(IniFile : TCustomIniFile; const IniSection : string); overload;
    procedure SaveToIni (IniFile : TCustomIniFile; const IniSection : string;
                         Erase : boolean = true);
    procedure AssignList (AList : TStrings);
    procedure Loaded; override; { Laden der INI-Datei findet nur hier statt }
    procedure UpdateList; { Laden der HistoryList in die eigenen Items. }
    procedure AddItem (s : string); { *neu* siehe THistoryList.AddString}
    procedure AddItemObject (s : string; AObject: TObject); { *neu* siehe THistoryList.AddStringObject}
    procedure DeleteItem (s : string); { *neu* siehe THistoryList.RemString}
    function FindItem (const AText : string) : integer;
    property HistoryList : THistoryList read FHistoryList write FHistoryList; { verwaltet
      die Liste der Strings (automatische Längenbeschränkung etc) }
    { Eintrag wurde geändert }
    property Modified : boolean read FModified write FModified;
    property ReadOnly : boolean read FReadOnly write SetReadOnly;

  published
    { automatisches Update der Liste }
    property AutoUpdate : boolean read FAutoUpdate write FAutoUpdate default true;
    { max. Anzahl der Einträge in der Liste }
    property MaxItems : integer read GetMaxItems write SetMaxItems;
    { Name der zu verwendenden INI-Datei: }
    property IniFileName : string read FIniFileName write FIniFileName;
    { Name des zu verwendenden INI-Datei-Abschnitts: }
    property IniSection : string read FIniSection write FIniSection;
    property EraseSection : boolean read FEraseSection write FEraseSection default false;
  end;

procedure Register;

implementation

uses  System.StrUtils;

(********** THistoryList ***********)

constructor THistoryList.Create;
begin
  inherited Create;
  FMaxLen:=15;
  FRadioMenu:=false; FShowHotKeys:=true;
  FCheckedItem:='';
  FMenu:=nil; FMenu2:=nil;
  end;

destructor THistoryList.Destroy;
begin
  RemoveMenuItems;
  inherited Destroy;
  end;

procedure THistoryList.SetRadioMenu (Value : boolean);
begin
  if FRadioMenu<>Value then begin
    FRadioMenu:=Value;
    UpdateMenuItems;
    end;
  end;

procedure THistoryList.SetShowHotKeys (Value : boolean);
begin
  if FShowHotKeys<>Value then begin
    FShowHotKeys:=Value;
    UpdateMenuItems;
    end;
  end;

procedure THistoryList.SaveToIni (const IniName,IniSection : string;
                                  Erase : boolean);
var
  IniFile : TMemIniFile;
begin
  try
    IniFile:=TMemIniFile.Create(IniName);
    SaveToIni(IniFile,IniSection,Erase);
  finally
    IniFile.UpdateFile;
    IniFile.Free;
    end;
  end;

procedure THistoryList.SaveToIni (IniFile : TCustomIniFile; const IniSection : string;
                                  Erase : boolean);
var
  i : integer;
begin
  if Erase then IniFile.EraseSection(IniSection);
  { Falls die INI.Datei mehr Einträge enthält, als die aktuelle
    Liste, werden die überzähligen Einträge nicht überschrieben. }
  for i:=0 to Count-1 do begin
    if Strings[i]=' ' then Strings[i]:='?';   // sonst ist String leer
    IniFile.WriteString(IniSection,'History'+IntToStr(i), Strings[i]);
    end;
  end;

procedure THistoryList.LoadFromIni (const IniName,IniSection : string);
var
  IniFile : TMemIniFile;
begin
  try
    IniFile:=TMemIniFile.Create(IniName);
    LoadFromIni(IniFile,IniSection);
  finally
    IniFile.Free;
    end;
  end;

procedure THistoryList.LoadFromIni (IniFile : TCustomIniFile; const IniSection : string);
var
  i : integer;
  s : string;
begin
  Clear;
    { TMemIniFile.ReadSection sieht zwar aus, als könne sie
      die Strings auf einen Schlag lesen, liest aber nur die
      Variablennamen vor dem = }
  for i:=0 to FMaxLen-1 do begin
    s:=IniFile.ReadString(IniSection,'History'+IntToStr(i), '');
    if s='?' then s:=' ';   // sonst ist String leer
    if (s<>'') then Add(s);
    end;
  end;

procedure THistoryList.AssignList (AList : TStrings);
var
  i : integer;
begin
 Clear;
 for i:=0 to FMaxLen-1 do if i<AList.Count then Add(AList[i]);
 end;

procedure THistoryList.SetMenu(Menu : TMenuItem);
begin
  if Assigned(FMenu) then RemoveMenuItems;
  FMenu:=Menu; { Property-zugehörige Variable setzen }
  SeparatorCount:=0;
  MenuSizeBefore:=Menu.Count; { bisherige Menügröße speichern }
  AddMenuItems; { ab sofort bleibt das Menü aktuell }
  end;

procedure THistoryList.RemoveMenuItems;
var
  n : integer;
begin
  { alle Menüeinträge ab der gespeicherten Position
    MenuSizeBefore wieder entfernen: }
  FCheckedItem:='';
  if Assigned(FMenu) then with FMenu do while Count>MenuSizeBefore do begin
    n:=Count-1-MenuSizeBefore-SeparatorCount;
    if Items[Count-1].Checked then FCheckedItem:=Strings[n];
    Items[Count-1].Free;
//    Delete(Count-1);
    end;
  if Assigned(FMenu2) then with FMenu2 do while Count>0 do begin
    Items[Count-1].Free;
//    Delete(Count-1);
    end;
  end;

procedure THistoryList.AddMenuItems;
{ Gegenstück zu RemoveMenuItems }
var
  i  : integer;
  mi : TMenuItem;
  ch : boolean;
  s  : string;

  procedure CloneMenuItem(source, dest : TMenuItem);
  begin
     with dest do begin
       Action  := source.Action;
       Caption := source.Caption;
       ShortCut := source.ShortCut;
       Checked  := source.Checked;
       Enabled  := source.Enabled;
       Visible  := source.Visible;
       OnClick  := source.OnClick;
       OnDrawItem := source.OnDrawItem;
       OnMeasureItem := source.OnMeasureItem;
       HelpContext := source.HelpContext;
       Hint        := source.Hint;
       RadioItem   := source.RadioItem;
       end;
    end;

begin
  if Assigned(FMenu) then begin
    (* Änderung - keine Linie, wenn Menü leer *)
    if MenuSizeBefore>0 then begin
      mi:=NewLine;
      with mi do begin
        if assigned(FOnAutoDrawItem) then OnDrawItem:=DoAutoDrawItem;
        if assigned(FOnAutoMeasureItem) then OnMeasureItem:=DoAutoMeasureItem;
        end;
      FMenu.Add(mi); { mit einem Separator abtrennen }
      SeparatorCount:=1;
      end;
    for i:=0 to Count-1 do begin
      ch:=FRadioMenu and (Strings[i]=FCheckedItem);
      if i<15 then s:=Format('%1x %s', [i+1, Strings[i]])
      else s:=Format('%2x %s', [i+1, Strings[i]]);
      if not FShowHotKeys then s:=StringReplace(s,cHotkeyPrefix,cHotkeyPrefix+cHotkeyPrefix,[rfReplaceAll]);
      mi:=NewItem(s,0,ch, True, DoAutoItemClick, 0, '');
      with mi do begin
        RadioItem:=FRadioMenu;
        GroupIndex:=99;
        if assigned(FOnAutoDrawItem) then OnDrawItem:=DoAutoDrawItem;
        if assigned(FOnAutoMeasureItem) then OnMeasureItem:=DoAutoMeasureItem;
        end;
      FMenu.Add(mi);
      end;
    { so sieht das Menü aus (erste Ziffer unterstrichen):
      ...
      ----------
      1 Eintrag1
      2 Eintrag2
    }
    if Assigned(FMenu2) then begin
      FMenu2.Clear;
      for i:=MenuSizeBefore to FMenu.Count-1 do begin
        mi:=TMenuItem.Create(FMenu2);
        CloneMenuItem(FMenu.Items[i],mi);
        FMenu2.Add(mi);
       end;
      end;
    end;
  end;

procedure THistoryList.DoAutoDrawItem (Sender: TObject; ACanvas: TCanvas; ARect: TRect; Selected: Boolean);
begin
  if Assigned (FOnAutoDrawItem) then FOnAutoDrawItem(Sender,ACanvas,ARect,Selected);
  end;

procedure THistoryList.DoAutoMeasureItem (Sender: TObject; ACanvas: TCanvas;
    var Width, Height: Integer);
begin
  if Assigned (FOnAutoMeasureItem) then FOnAutoMeasureItem(Sender,ACanvas,Width,Height);
  end;

procedure THistoryList.UpdateMenuItems;
begin
  RemoveMenuItems; { Menü in Ursprungszustand versetzen... }
  AddMenuItems; { ...und alle Einträge neu anhängen. }
  end;

procedure THistoryList.SetList(List : TStrings);
begin
  if Assigned(FList) then RemoveListItems;
  FList:=List; { Property-zugehörige Variable setzen }
  ListSizeBefore:=List.Count; { bisherige Menügröße speichern }
  AddListItems; { ab sofort bleibt das Menü aktuell }
end;

procedure THistoryList.RemoveListItems;
begin
  { alle Listeneinträge ab der gespeicherten Position
    ListSizeBefore wieder entfernen: }
  if Assigned(FList) then with FList do
    while Count>ListSizeBefore do Delete(Count-1);
end;

procedure THistoryList.AddListItems;
{ Gegenstück zu RemoveListItems }
var
  i : integer;
begin
  if Assigned(FList) then begin
    for i:=0 to Count-1 do FList.Add(Strings[i]);
  end;
end;

procedure THistoryList.SetMaxLen(AnInt : integer);
begin
  if (AnInt>=1) and (AnInt<=100) then begin
    FMaxLen:=AnInt;
    while Count>FMaxLen do
      Delete(Count-1); { alle überzähligen Einträge löschen }
  end;
end;

procedure THistoryList.AddString(s : string);
var
  OldIndex : integer;
begin
  if length(s)>0 then begin
    { String schon vorhanden? }
    OldIndex:=IndexOf(s);
    RemoveMenuItems; { Menü in Ursprungszustand versetzen... }
//    FCheckedItem:=s;
    if OldIndex<>-1 then Delete(OldIndex); { dann das Duplikat löschen }
    Insert(0, s); { auf alle Fälle an erster Stelle einfügen }
    { Maximallänge überschritten? }
    if Count>FMaxLen then Delete(Count-1); { letzten Eintrag löschen }
    AddMenuItems; { ...und alle Einträge neu anhängen. }
    RemoveListItems; { Liste in Ursprungszustand versetzen... }
    AddListItems; { ...und alle Einträge neu anhängen. }
    end;
  end;

procedure THistoryList.AddStringObject(s : string; AObject: TObject);
var
  OldIndex : integer;
begin
  if length(s)>0 then begin
    { String schon vorhanden? }
    OldIndex:=IndexOf(s);
    RemoveMenuItems; { Menü in Ursprungszustand versetzen... }
//    FCheckedItem:=s;
    if OldIndex<>-1 then Delete(OldIndex); { dann das Duplikat löschen }
    InsertObject(0,s,AObject); { auf alle Fälle an erster Stelle einfügen }
    { Maximallänge überschritten? }
    if Count>FMaxLen then Delete(Count-1); { letzten Eintrag löschen }
    AddMenuItems; { ...und alle Einträge neu anhängen. }
    RemoveListItems; { Liste in Ursprungszustand versetzen... }
    AddListItems; { ...und alle Einträge neu anhängen. }
    end;
  end;

procedure THistoryList.RemString(s : string);
var
  OldIndex : integer;
begin
  { String vorhanden? }
  OldIndex:=IndexOf(s);
  RemoveMenuItems; { Menü in Ursprungszustand versetzen... }
  if OldIndex<>-1 then Delete(OldIndex); { löschen }
  AddMenuItems; { ...und alle Einträge neu anhängen. }
  RemoveListItems; { Liste in Ursprungszustand versetzen... }
  AddListItems; { ...und alle Einträge neu anhängen. }
  end;

procedure THistoryList.ClearAll;
begin
  RemoveMenuItems; { Menü in Ursprungszustand versetzen... }
  RemoveListItems; { Liste in Ursprungszustand versetzen... }
  Clear;
  end;

function THistoryList.SelectMenuItem (s : string) : boolean;
var
  n : integer;
begin
  n:=IndexOf(s);
  if n>=0 then FMenu.Items[n+MenuSizeBefore+SeparatorCount].Checked:=true;
  Result:=n>=0;
  end;

procedure THistoryList.DoAutoItemClick(Sender : TObject);
var
  Text,s : String;
  Index : Integer;
begin
  Text:=(Sender as TMenuItem).Caption;
  (Sender as TMenuItem).Checked:=true;
  { Text sieht so aus:
    &12 MenuText
    das "&" muß übersprungen werden, dann folgt bis
    zum Leerzeichen der Index, der angeklickt wurde }
  s:=Copy(Text,1,Pos(' ',Text)-1);
  system.Delete(s,Pos('&',s),1);
  Index:=StrToInt('$'+s);
  if Assigned (FOnAutoItemClick) then begin
    { Index - 1 ergibt den Index in der internen
      Stringliste: }
    if Index>0 then FOnAutoItemClick(FMenu, Strings[index-1]);
    end
  else if assigned(FOnAutoItemClickIndex) then begin
    if Index>0 then FOnAutoItemClickIndex(FMenu,Index-1);
    end;
  end;

(********** THistoryCombo ***********)

constructor THistoryCombo.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FAutoUpdate:=true;
  FEraseSection:=false;
  FSaveText:=''; FModified:=false;
  FIniFileName:=''; FIniSection:='';
  FHistoryList:=THistoryList.Create;
  end;

destructor THistoryCombo.Destroy;
begin
  { Automatische Speicherung, wenn die notwendigen
    Angaben gemacht sind: }
  if (length(FIniFileName)>0) and (length(FIniSection)>0) then
    FHistoryList.SaveToIni(FIniFileName,FIniSection,FEraseSection);
  { da FHistoryList nicht in der Komponentenliste ist,
    muß sie manuell freigegeben werden: }
  FHistoryList.Free;
  inherited Destroy;
  end;

function THistoryCombo.GetMaxItems : integer;
begin
  Result:=FHistoryList.FMaxLen;
  end;

procedure THistoryCombo.SetMaxItems (n : integer);
begin
  FHistoryList.SetMaxLen(n);
  end;

procedure THistoryCombo.SetReadOnly (Value : boolean);
begin
  if FReadOnly<>Value then begin
    FReadOnly:=Value;
    UpdateList;
    end;
  end;

procedure THistoryCombo.AddItem (s : string);
begin
  FHistoryList.AddString(s);
  UpdateList;
  end;

procedure THistoryCombo.AddItemObject (s : string; AObject: TObject);
begin
  FHistoryList.AddStringObject(s,AObject);
  UpdateList;
  end;

procedure THistoryCombo.DeleteItem (s : string);
begin
  FHistoryList.RemString(s);
  UpdateList;
  end;

function THistoryCombo.FindItem (const AText : string) : integer;
begin
  with HistoryList do for Result:=0 to Count-1 do if AnsiStartsText(AText,Strings[Result]) then Exit;
  Result:=-1;
  end;

procedure THistoryCombo.UpdateList;
begin
  Items:=FHistoryList;
  if (Items.Count=0) or FReadOnly then Style:=csSimple else Style:=csDropDown;
  end;

procedure THistoryCombo.DoEnter;
begin
  if not FModified then FSaveText:=Text;
  end;

procedure THistoryCombo.DoExit;
{ Fokus-Wechsel -> Eintrag speichern. }
begin
  inherited DoExit;
  FModified:=not AnsiSameText(FSavetext,Text);
  if FAutoUpdate then begin    // JR - nur bei AutoUpdate speichern
    FHistoryList.AddString(Text);
    UpdateList;
    end;
  end;

procedure THistoryCombo.Loaded;
begin
  inherited Loaded;
  { Automatisches INI-Datei-Lesen, wenn die notwendigen
    Angaben gemacht sind: }
  if (FIniFileName<>'') and (FIniSection<>'') then begin
    FHistoryList.LoadFromIni(FIniFileName, FIniSection);
    UpdateList;
    end;
  end;

procedure THistoryCombo.LoadFromIni(IniFile : TCustomIniFile; const IniSection : string);
begin
  FHistoryList.LoadFromIni(IniFile,IniSection);
  UpdateList;
  end;

procedure THistoryCombo.LoadFromIni(const IniName,IniSection : string);
begin
  FIniFileName:=IniName; FIniSection:=IniSection;
  if FileExists(FIniFileName) and (FIniSection<>'') then begin
    FHistoryList.LoadFromIni(FIniFileName,FIniSection);
    UpdateList;
    end;
  end;

procedure THistoryCombo.SaveToIni (IniFile : TCustomIniFile; const IniSection : string;
                     Erase : boolean);
begin
  FHistoryList.SaveToIni(IniFile,IniSection,Erase);
  end;

procedure THistoryCombo.AssignList (AList : TStrings);
begin
  FHistoryList.AssignList(AList);
  UpdateList;
  end;

(************** Register ***************)

procedure Register;
begin
  RegisterComponents(CompPalPage, [THistoryCombo]);
end;

end.
