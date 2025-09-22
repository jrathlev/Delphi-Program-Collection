unit ValueDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  PartDlg;

type
  TSeries = (csE6,csE12,csE24,csE48m);
  TSeriesList = array [TPartType] of TSeries;

  TValueDialog = class(TForm)
    CancelBtn: TBitBtn;
    OKBtn: TBitBtn;
    rgSeries: TRadioGroup;
    lbSeries: TListBox;
    Label1: TLabel;
    rgPrefix: TRadioGroup;
    rgFactor: TRadioGroup;
    lbUnits: TLabel;
    edValue: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure ChangeValue(Sender: TObject);
    procedure rgSeriesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private-Deklarationen }
    SelSeries : TSeriesList;
    FTyp : TPartType;
    LastFactor : integer;
    function FindNearestValue(val : double) : integer;
    procedure ShowSeries;
    procedure UpdateValue;
    procedure ShowValue(Value : double);
  public
    { Public-Deklarationen }
    function Execute (const ACaption : string; Typ : TPartType; var Value : double) : boolean;
  end;

var
  ValueDialog: TValueDialog;

implementation

{$R *.dfm}

uses System.Math, GnuGettext, MsgDialogs, NumberUtils;

type
  TPartValues = record  // E series values for electronic components (IEC 60063)
    Cnt,Dec : integer;
    Values :  array [1..24] of double;
    end;

 TPrefixes  = record
   Default  : integer;
   FirstPfx : integer;
   Prefixes : string;
   end;

const
  PartValues : array [TSeries] of TPartValues = (
    (Cnt  : 6; Dec : 1;
     Values : (1.0,1.5,2.2,3.3,4.7,6.8,0.0,0,0.0,0.0,0.0,0.0,
            0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)),
    (Cnt  : 12; Dec : 1;
     Values : (1.0,1.2,1.5,1.8,2.2,2.7,3.3,3.9,4.7,5.6,6.8,8.2,
            0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)),
    (Cnt  : 24; Dec : 1;
     Values : (1.0,1.1,1.2,1.3,1.5,1.6,1.8,2.0,2.2,2.4,2.7,3.0,
            3.3,3.6,3.9,4.3,4.7,5.1,5.6,6.2,6.8,7.5,8.2,9.1)),
    (Cnt  : 24; Dec : 2;
     Values : (1.00,1.10,1.21,1.30,1.50,1.62,1.82,2.00,2.21,2.43,2.74,3.01,
               3.32,3.65,3.92,4.32,4.75,5.11,5.62,6.19,6.81,7.50,8.25,9.09)));

   Factors : array [0..3] of double = (1.0,10.0,100.0,1000.0);

   Prefixes : array [TPartType] of TPrefixes = (
     (Default  : 2; FirstPfx : 5; Prefixes : 'm kMG'),     // resistors
     (Default  : 0; FirstPfx : 4; Prefixes : 'µm '),       // inductors
     (Default  : 1; FirstPfx : 2; Prefixes : 'pnµm '),     // capacitors
     (Default  : 0; FirstPfx : 0; Prefixes : ''));         // operational ampl.

   DefaultSeries : TSeriesList = (csE12,csE6,csE6,csE6);

procedure TValueDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent(self);
  SelSeries:=DefaultSeries;
  LastFactor:=0;
  end;

procedure TValueDialog.FormShow(Sender: TObject);
begin
//  ChangeValue(Sender);
  end;

procedure TValueDialog.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  v : double;
begin
  if Modalresult=mrOk then begin
    if not PrefixStrToVal(edValue.Text,v) then begin
      ErrorDialog(rsNumError);
      edValue.SetFocus;
      CanClose:=false;
      end
    end;
  end;

procedure TValueDialog.rgSeriesClick(Sender: TObject);
begin
  SelSeries[FTyp]:=TSeries(rgSeries.ItemIndex);
  ShowSeries;
  ChangeValue(Sender);
  end;

procedure TValueDialog.ChangeValue(Sender: TObject);
begin
  UpdateValue;
  end;

procedure TValueDialog.ShowValue(Value : double);
var
  k,n,m : integer;
  s : string;
begin
  if (Value>=MinDouble) then begin
    k:=Floor(Log10(Value));
    m:=0;
    while (k<0) do begin
      inc(k,3); Value:=1000*Value; inc(m);
      end;
    LastFactor:=k mod 3;
    rgFactor.ItemIndex:=LastFactor;
    n:=(k+18) div 3;
    rgPrefix.ItemIndex:=n-m-Prefixes[FTyp].FirstPfx;
    ShowSeries;
    lbSeries.ItemIndex:=FindNearestValue(Value/Power(10,k));
    with lbSeries do s:=Items[ItemIndex];
    with rgPrefix do s:=s+Trim(Items[ItemIndex]);
    edValue.Text:=s;
//    FloatToStrX(Value,5,PartValues[SelSeries[FTyp]].Dec)+s;
    end;
  end;

procedure TValueDialog.UpdateValue;
var
  v : double;
  s : string;
begin
  if Visible then begin
    ShowSeries;
    LastFactor:=rgFactor.ItemIndex;
    with lbSeries do v:=StrToFloat(Items[ItemIndex]);
//    v:=v*Factors[rgFactor.ItemIndex];
    with rgPrefix do s:=Trim(Items[ItemIndex]);
    edValue.Text:=FloatToStrX(v,5,PartValues[SelSeries[FTyp]].Dec)+s;
    end;
  end;

procedure TValueDialog.ShowSeries;
var
  i,d  : integer;
  v: double;
begin
  with lbSeries do begin
    if ItemIndex>=0 then v:=StrToFloat(Items[ItemIndex])/Factors[LastFactor]
    else v:=0;
    Clear;
    case SelSeries[FTyp] of
      csE6 : Columns:=1;
      csE12 : Columns:=2;
      else Columns:=3;
      end;
    end;
  with PartValues[SelSeries[FTyp]] do begin
    d:=Dec-rgFactor.ItemIndex;
    if d<0 then d:=0;
    for i:=1 to Cnt do
      lbSeries.Items.Add(FloatToStrX(Values[i]*Factors[rgFactor.ItemIndex],5,d));
    end;
  lbSeries.ItemIndex:=FindNearestValue(v);
  end;

function TValueDialog.FindNearestValue(val : double) : integer;
var
  i,n : integer;
  v : double;
begin
  with PartValues[SelSeries[FTyp]] do begin
    n:=0;
    if val>=0.5 then begin
      for i:=1 to Cnt do begin
//        v:=StrToFloat(Items[i],FormatSettings);
        v:=Values[i];
//        if i<Count-1 then v:=(v+StrToFloat(Items[i+1],FormatSettings))/2
        if i<Cnt then v:=(v+Values[i+1])/2
        else v:=(v+10.0)/2;
        if val<v then begin
          n:=i; Break;
          end;
        end;
      end;
    if n>Cnt then Result:=0 else Result:=n-1;
    end;
  end;

function TValueDialog.Execute (const ACaption : string; Typ : TPartType; var Value : double) : boolean;

  procedure ShowPrefixes (ATyp : TPartType);
  var
    i : integer;
    s : string;
  begin
    with rgPrefix do begin
      Items.Clear;
      s:=Prefixes[ATyp].Prefixes;
      for i:=1 to length(s) do Items.Add(s[i]);
      ItemIndex:=Prefixes[ATyp].Default;
      end;
    end;

begin
  if length(ACaption)>0 then Caption:=ACaption;
  lbUnits.Caption:=PartUnits[TPartType(Typ)];
  FTyp:=Typ;
  ShowPrefixes(Typ);
  ShowValue(Value);
  Result:=ShowModal=mrOk;
  if Result then PrefixStrToVal(edValue.Text,Value,FormatSettings.DecimalSeparator);
  end;

end.
