(* Delphi Dialog
   Zahleneingabefenster mit UpDown-Tasten und dyn. Inkrement
   =======================================================
   
   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
      
   Vers. 1 - Mrz. 2002 
   last modified: Nov. 2021
   *)

unit NumDlg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.Dialogs,
  WinUtils, NumberEd;

type
  TSwitchMode = (tsNotVis,tsOff,tsOn);
  TIncrMode = (imFixed,imDecAuto,imBinAuto);

  TInputNumber = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Rahmen: TBevel;
    Descriptor1: TLabel;
    Descriptor2: TLabel;
    reNum1: TRangeEdit;
    udNum1: TNumUpDown;
    reNum2: TRangeEdit;
    udNum2: TNumUpDown;
    procedure NumFeld2Change(Sender: TObject);
    procedure NumFeld1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FIncMode1,FIncMode2 : TIncrMode;
{$IFDEF HDPI}   // scale glyphs and images for High DPI
    procedure AfterConstruction; override;
{$EndIf}
  public
    { Public declarations }
    function Execute(APos : TPoint;
                     const Titel,Desc1,Desc2 : string;
                     var AVal,BVal     : longint) : boolean;
  end;

(* Zahl bearbeiten, Ergebnis: "true" bei "ok" *)
function NumDialog (APos         : TPoint;
                    const Titel,Desc   : string;
                    Min,Max,Incr : longint;
                    IncMode      : TIncrMode;
                    var Val      : longint) : boolean; overload;

function NumDialog (const Titel,Desc   : string;
                    Min,Max,Incr : longint;
                    IncMode      : TIncrMode;
                    var Val      : longint) : boolean; overload;

(* Zwei Zahlen bearbeiten, Ergebnis: "true" bei "ok" *)
function DNumDialog (APos                : TPoint;
                     const Titel,Desc1,Desc2   : string;
                     Min1,Max1,Incr1     : integer;
                     IncMode1            : TIncrMode;
                     Min2,Max2,Incr2     : integer;
                     IncMode2            : TIncrMode;
                     var Val1,Val2       : integer) : boolean; overload;

function DNumDialog (const Titel,Desc1,Desc2   : string;
                     Min1,Max1,Incr1     : integer;
                     IncMode1            : TIncrMode;
                     Min2,Max2,Incr2     : integer;
                     IncMode2            : TIncrMode;
                     var Val1,Val2       : integer) : boolean; overload;

var
  InputNumber: TInputNumber;

implementation

{$R *.DFM}

uses GnuGetText;

procedure TInputNumber.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs');
  end;

{$IFDEF HDPI}   // scale glyphs and images for High DPI
procedure TInputNumber.AfterConstruction;
begin
  inherited;
  if Application.Tag=0 then
    ScaleButtonGlyphs(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;
{$EndIf}

{ ------------------------------------------------------------------- }
(* Text-Dialog mit 1 oder 2 Feldern anzeigen *)
function TInputNumber.Execute(APos : TPoint;
                              const Titel,Desc1,Desc2 : string;
                              var AVal,BVal     : longint) : boolean;

var
  ok : boolean;
begin
  AdjustFormPosition(Screen,self,APos);
  Caption:=Titel;
  with reNum1 do begin
    Value:=AVal; AutoSelect:=true;
    end;
  if Desc2<>'' then begin
    reNum2.Visible:=true; Descriptor2.Visible:=true;
    Descriptor2.Caption:=Desc2;
    with reNum2 do begin
      Value:=BVal; AutoSelect:=true;
      end;
    end
  else begin
    reNum2.Visible:=false; Descriptor2.Visible:=false;
    end;
  udNum2.Visible:=reNum2.Visible;
  Descriptor1.Caption:=Desc1;
  ActiveControl:=reNum1;
  ok:=ShowModal=mrOK;
  if ok then begin
    AVal:=reNum1.Value;
    if Desc2<>'' then BVal:=reNum2.Value;
    end;
  Result:=ok;
end;

procedure TInputNumber.NumFeld1Change(Sender: TObject);
begin
  with reNum1 do begin
    case FincMode1 of
    imDecAuto : begin
        if Value<10 then udNum1.Increment:=1
        else if Value<100 then udNum1.Increment:=5
        else if Value<1000 then udNum1.Increment:=50
        else if Value<10000 then udNum1.Increment:=500
        else udNum1.Increment:=5000;
        end;
    imBinAuto: begin
        if Value<8 then udNum1.Increment:=1
        else if Value<64 then udNum1.Increment:=8
        else if Value<512 then udNum1.Increment:=64
        else if Value<4096 then udNum1.Increment:=512
        else udNum1.Increment:=4096;
        end;
      end;
    end;
  end;

procedure TInputNumber.NumFeld2Change(Sender: TObject);
begin
  with reNum2 do begin
    case FincMode2 of
    imDecAuto : begin
        if Value<10 then udNum2.Increment:=1
        else if Value<100 then udNum2.Increment:=5
        else if Value<1000 then udNum2.Increment:=50
        else if Value<10000 then udNum2.Increment:=500
        else udNum2.Increment:=5000;
        end;
    imBinAuto: begin
        if Value<8 then udNum2.Increment:=1
        else if Value<64 then udNum2.Increment:=8
        else if Value<512 then udNum2.Increment:=64
        else if Value<4096 then udNum2.Increment:=512
        else udNum2.Increment:=4096;
        end;
      end;
    end;  
  end;

{ ------------------------------------------------------------------- }
(* Zahl bearbeiten, Ergebnis: "true" bei "ok" *)
function NumDialog (APos : TPoint;
                    const Titel,Desc   : string;
                    Min,Max,Incr : longint;
                    IncMode      : TIncrMode;
                    var Val      : longint) : boolean;
begin
  if not assigned(InputNumber) then InputNumber:=TInputNumber.Create(Application);
  with InputNumber do begin
    with reNum1 do begin
      MinValue:=Min; MaxValue:=Max; udNum1.Increment:=Incr;
      end;
    FIncMode1:=IncMode;
    Result:=Execute (APos,Titel,Desc,'',Val,Val);
    Release;
    end;
  InputNumber:=nil;
  end;

function NumDialog (const Titel,Desc   : string;
                    Min,Max,Incr : longint;
                    IncMode      : TIncrMode;
                    var Val      : longint) : boolean;
begin
  Result:=NumDialog (CenterPos,Titel,Desc,Min,Max,Incr,IncMode,Val);
  end;

{ ------------------------------------------------------------------- }
(* Zwei Zahlen bearbeiten, Ergebnis: "true" bei "ok" *)
function DNumDialog (APos : TPoint;
                     const Titel,Desc1,Desc2   : string;
                     Min1,Max1,Incr1     : integer;
                     IncMode1            : TIncrMode;
                     Min2,Max2,Incr2     : integer;
                     IncMode2            : TIncrMode;
                     var Val1,Val2       : integer) : boolean; overload;
begin
  if not assigned(InputNumber) then InputNumber:=TInputNumber.Create(Application);
  with InputNumber do begin
    with reNum1 do begin
      MinValue:=Min1; MaxValue:=Max1; udNum1.Increment:=Incr1;
      end;
    with reNum2 do begin
      MinValue:=Min2; MaxValue:=Max2; udNum2.Increment:=Incr2;
      end;
    FIncMode1:=IncMode1; FIncMode2:=IncMode2;
    Result:=Execute (APos,Titel,Desc1,Desc2,Val1,Val2);
    Release;
    end;
  InputNumber:=nil;
  end;

function DNumDialog (const Titel,Desc1,Desc2   : string;
                     Min1,Max1,Incr1     : integer;
                     IncMode1            : TIncrMode;
                     Min2,Max2,Incr2     : integer;
                     IncMode2            : TIncrMode;
                     var Val1,Val2       : integer) : boolean;
begin
  Result:=DNumDialog (CenterPos,Titel,Desc1,Desc2,Min1,Max1,Incr1,IncMode1,Min2,Max2,Incr2,IncMode2,Val1,Val2);
  end;

end.
