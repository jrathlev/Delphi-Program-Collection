unit VarValDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Grids, PartDlg;

const
  VarMax = 20;                   (* max. Anzahl von variablen Werten *)

type
  TVarArr = array of double;

  TVarValueDialog = class(TForm)
    gbPart: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    edName: TEdit;
    edValue: TEdit;
    lbUnits: TLabel;
    gbValues: TGroupBox;
    lbValues: TListBox;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    btnAdd: TBitBtn;
    btnDelete: TBitBtn;
    btnEdit: TBitBtn;
    btnDelAll: TBitBtn;
    btnAddValue: TBitBtn;
    laAllUnits: TLabel;
    btnEditValue: TBitBtn;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnDeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelAllClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnAddValueClick(Sender: TObject);
    procedure btnEditValueClick(Sender: TObject);
  private
    { Private-Deklarationen }
    PartType : TPartType;
    LPartNames : array [TPartType] of string;
  public
    { Public-Deklarationen }
    function RemoveUnit (const val,units : string) : string;
    function Execute (const APart : TPart; var AValues : TVarArr) : boolean;
  end;

var
  VarValueDialog: TVarValueDialog;

implementation

{$R *.dfm}

uses System.StrUtils, GnuGetText, NumberUtils, WinUtils, InputString, MsgDialogs,
  ValueDlg;

procedure TVarValueDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
  LPartNames[ptR]:=_('Resistor');
  LPartNames[ptL]:=_('Inductor');
  LPartNames[ptC]:=_('Capacitor');
  end;

procedure TVarValueDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  v   : double;
  i,n : integer;
begin
  if Modalresult=mrOk then with lbValues do begin
    n:=-1;
    for i:=0 to Count-1 do if Length(Items[i])>0 then begin
      CanClose:=CanClose or PrefixStrToVal(RemoveUnit(Items[i],lbUnits.Caption),v);
      if not CanClose and (n<0) then n:=i;
      end;
    if not CanClose then begin
      ErrorDialog(rsNumError); ItemIndex:=n;
      end;
    end;
  end;

procedure TVarValueDialog.btnDelAllClick(Sender: TObject);
begin
  lbValues.Clear;
  end;

procedure TVarValueDialog.btnDeleteClick(Sender: TObject);
var
  n : integer;
begin
  with lbValues do if ItemIndex>=0 then begin
    n:=ItemIndex;
    Items.Delete(n);
    if n>Items.Count then ItemIndex:=Items.Count-1 else ItemIndex:=n;
    end;
  end;

function TVarValueDialog.RemoveUnit (const val,units : string) : string;
begin
  Result:=Trim(val);
  if AnsiEndsText(units,Result) then Result:=copy(Result,1,length(Result)-length(units));
  end;

procedure TVarValueDialog.btnEditClick(Sender: TObject);
var
  s  : string;
  v  : double;
begin
  with lbValues do if ItemIndex>=0 then begin
    s:=Items[ItemIndex];
    if InputText(CenterPos,_('Edit value for %s'),edName.Text,lbUnits.Caption,s) then begin
      if PrefixStrToVal(RemoveUnit(s,lbUnits.Caption),v) then
        Items[ItemIndex]:=FloatToPrefixStr(v,4)
      else ErrorDialog(rsNumError);
      end;
    end;
  end;

procedure TVarValueDialog.btnAddClick(Sender: TObject);
var
  s  : string;
  v  : double;
begin
  s:='';
  if InputText(CenterPos,_('Add value for %s'),edName.Text,s) then begin
    if PrefixStrToVal(RemoveUnit(s,lbUnits.Caption),v) then
      with lbValues do ItemIndex:=Items.Add(FloatToPrefixStr(v,4))
    else ErrorDialog(rsNumError);
    end;
  end;

procedure TVarValueDialog.btnEditValueClick(Sender: TObject);
var
  v : double;
begin
  with lbValues do if ItemIndex<0 then btnAddValueClick(Sender)
  else begin
    PrefixStrToVal(Items[ItemIndex],v);
    if ValueDialog.Execute(Format(_('Select standard value for %s'),[edName.Text]),PartType,v) then
      Items[ItemIndex]:=FloatToPrefixStr(v,4);
    end;
  end;

procedure TVarValueDialog.btnAddValueClick(Sender: TObject);
var
  v : double;
begin
  v:=PartDefValue[PartType];
  if ValueDialog.Execute(Format(_('Add standard value for %s'),[edName.Text]),PartType,v) then begin
    with lbValues do
      ItemIndex:=Items.Add(FloatToPrefixStr(v,4))
    end;
  end;

{ ------------------------------------------------------------------- }
function TVarValueDialog.Execute (const APart : TPart; var AValues : TVarArr) : boolean;
var
  i,j,k,n,m : integer;
  v         : double;
begin
  with APart do begin
    PartType:=Typ;
    edName.Text:=PartNames[Typ]+IntToStr(Nr);
    edValue.Text:=FloatToPrefixStr(Value,4);
    lbUnits.Caption:=PartUnits[Typ];
    end;
  Caption:=_('Variable values')+' - '+LPartNames[PartType];
  laAllUnits.Caption:=_('All values in ')+lbUnits.Caption;
  with lbValues do begin
    Clear;
    for i:=Low(AValues) to High(AValues) do Items.Add(FloatToPrefixStr(AValues[i],4));
    end;
  if ShowModal=mrOK then begin
    n:=0;
    with lbValues do if Count>0 then begin
      SetLength(AValues,Count);
      for i:=0 to Count-1 do if (length(Items[i])>0) then begin
        PrefixStrToVal(RemoveUnit(Items[i],lbUnits.Caption),v,FormatSettings.DecimalSeparator);
        if i=0 then AValues[i]:=v
        else begin
          j:=0;
          while (j<i) and (v>AValues[j]) do inc(j);
          for k:=i-1 downto j do AValues[k+1]:=AValues[k];
          AValues[j]:=v;
          end;
        end;
      end
    else AValues:=nil;
    Result:=true;
    end
  else Result:=false;
  end;

end.
