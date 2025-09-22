unit PartDlg;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, NumberEd, ComCtrls, Spin;

resourcestring
  rsNumError = 'Error in value specification!'; // 'Fehler bei Werteangabe!';
  rsNodeError = 'Multiple use of nodes!'; //'Mehrfachverwendung von Knoten!';

const
  PartMax = 50;                  (* max. Anzahl Bauelemente *)
  KnMax = 25;                    (* max. Anzahl Knoten *)

type
  TPartType = (ptR,ptL,ptC,ptOP);

  TPart = record
    Typ          : TPartType;
    Nr,
    KnP,KnN,KnO  : integer;
    Desc         : string;
    Value,Freq   : double;
    end;

const
  PartNames : array [TPartType] of string = ('R','L','C','OP');
  PartUnits : array [TPartType] of string = ('Ohm','H','F','');
  PartDefValue : array [TPartType] of double = (1000,1E-2,1E-8,1);

type
  TPartDialog = class(TForm)
    rgTyp: TRadioGroup;
    gbValues: TGroupBox;
    lbValue: TLabel;
    edValue: TEdit;
    lbUnits: TLabel;
    lbFreq: TLabel;
    edFreq: TEdit;
    lbFreqUn: TLabel;
    gbKnoten: TGroupBox;
    lbKnP: TLabel;
    lbKnN: TLabel;
    lbKnO: TLabel;
    edKnP: TEdit;
    udKnP: TUpDown;
    edKnN: TEdit;
    udKnN: TUpDown;
    edKnO: TEdit;
    udKnO: TUpDown;
    edDesc: TEdit;
    gbName: TGroupBox;
    edTyp: TEdit;
    edNumber: TEdit;
    udNumber: TUpDown;
    Label1: TLabel;
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    btnValue: TBitBtn;
    procedure rgTypClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure btnValueClick(Sender: TObject);
  private
    { Private-Deklarationen }
    procedure ChangeView;
    function GetPartNr(PartName : string) : integer;
  public
    { Public-Deklarationen }
    function NewPart : TPart;
    function Execute (var APart : TPart) : boolean;
  end;

var
  PartDialog: TPartDialog;

implementation

{$R *.dfm}

uses GnuGetText, NumberUtils, StringUtils, WinUtils, MsgDialogs, ValueDlg;

procedure TPartDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
  end;

procedure TPartDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  v : double;
begin
  if Modalresult=mrOk then begin
    if not PrefixStrToVal(edValue.Text,v) then begin
      ErrorDialog(rsNumError);
      edValue.SetFocus;
      CanClose:=false;
      end
    else if (TPartType(rgTyp.ItemIndex)=ptOP)
        and not PrefixStrToVal(edFreq.Text,v) then begin
      ErrorDialog(rsNumError);
      edFreq.SetFocus;
      CanClose:=false;
      end
    else if (udKnP.Position=udKnN.Position) then begin
      ErrorDialog(rsNodeError);
      CanClose:=false;
      end;
    end;
  end;

{ ------------------------------------------------------------------- }
function TPartDialog.NewPart : TPart;
begin
  with Result do begin
    Typ:=ptR;
    Nr:=0;
    KnP:=0; KnN:=1; KnO:=2;
    Desc:='';
    Value:=PartDefValue[Typ];
    Freq:=20;
    end;
  end;

procedure TPartDialog.ChangeView;
begin
  edTyp.Text:=PartNames[TPartType(rgTyp.ItemIndex)];
  if TPartType(rgTyp.ItemIndex)=ptOP then begin
    lbUnits.Caption:='';
    lbValue.Caption:=_('Gain:');
    lbKnP.Caption:=_('Input (+):');
    lbKnN.Caption:=_('Input (-):');
    lbFreq.Show; edFreq.Show; lbFreqUn.Show;
    lbKnO.Show; edKnO.Show; udKnO.Show;
    edValue.Text:='10M';
    edFreq.Text:='20';
    btnValue.Visible:=false;
    end
  else begin
    lbUnits.Caption:=PartUnits[TPartType(rgTyp.ItemIndex)];
    if TPartType(rgTyp.ItemIndex)=ptC then begin
      edValue.Text:=FloatToPrefixStr(PartDefValue[ptC],4,''); //'10n';
      end
    else if TPartType(rgTyp.ItemIndex)=ptL then begin
      edValue.Text:=FloatToPrefixStr(PartDefValue[ptL],4,''); //'10n';
      end
    else begin
      edValue.Text:=FloatToPrefixStr(PartDefValue[ptR],4,''); //'10n';
      end;
    lbValue.Caption:=_('Value:');
    lbKnP.Caption:=_('Pin 1:');
    lbKnN.Caption:=_('Pin 2:');
    lbFreq.Hide; edFreq.Hide; lbFreqUn.Hide;
    lbKnO.Hide; edKnO.Hide; udKnO.Hide;
    udKnO.Position:=0;
    btnValue.Visible:=true;
    end;
  end;

function TPartDialog.GetPartNr(PartName : string) : integer;
var
  i : integer;
begin
  if length(PartName)>0 then begin
    i:=1;
    while (PartName[i]<'0') or (PartName[i]>'9') do inc(i);
    Delete(PartName,1,i-1);
    Result:=ReadNxtInt(PartName,' ',0);
    end
  else Result:=0;
  end;

procedure TPartDialog.rgTypClick(Sender: TObject);
begin
  ChangeView;
  end;

procedure TPartDialog.btnValueClick(Sender: TObject);
var
  v : double;
begin
  PrefixStrToVal(edValue.Text,v);
  if ValueDialog.Execute(Format(_('Select standard value for %s'),[edTyp.Text+IntToStr(udNumber.Position)]),
      TPartType(rgTyp.ItemIndex),v) then
    edValue.Text:=FloatToPrefixStr(v,4);
  end;

{ ------------------------------------------------------------------- }
function TPartDialog.Execute (var APart : TPart) : boolean;
begin
  with APart do begin
    rgTyp.ItemIndex:=integer(Typ);
    ChangeView;
    with udKnP do begin
      Min:=0; Max:=KnMax; Position:=KnP;
      end;
    with udKnN do begin
      Min:=0; Max:=KnMax; Position:=KnN;
      end;
    with udKnO do begin
      Min:=0; Max:=KnMax; Position:=KnO;
      end;
    edTyp.Text:=PartNames[Typ];
    udNumber.Position:=Nr;
    edDesc.Text:=Desc;
    edValue.Text:=FloatToPrefixStr(Value,4);
    edFreq.Text:=FloatToPrefixStr(Freq,4);
    end;
  if ShowModal=mrOK then begin
    with APart do begin
      Typ:=TPartType(rgTyp.ItemIndex);
      KnP:=udKnP.Position;
      KnN:=udKnN.Position;
      KnO:=udKnO.Position;
      Nr:=udNumber.Position;
      Desc:=edDesc.Text;
      PrefixStrToVal(edValue.Text,Value);
      if Typ=ptOP then PrefixStrToVal(edFreq.Text,Freq);
      end;
    Result:=true;
    end
  else Result:=false;
  end;

end.
