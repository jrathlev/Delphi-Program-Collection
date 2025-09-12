(* Delphi Dialog
   Dialog to enter a string
   ========================

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.

   Vers. 1 - Sep. 2002 
   Vers. 2 - Feb. 2025: SVG glyphs
   last modified: July 2025
   *)

unit InputString;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, JrButtons,
  System.ImageList, Vcl.ImgList, SVGIconImageListBase, SVGIconImageList;

type
  TInputStringDialog = class(TForm)
    Descriptor: TStaticText;
    TextFeld: TEdit;
    imlGlyphs: TSVGIconImageList;
    OKBtn: TJrButton;
    CancelBtn: TJrButton;
    procedure FormCreate(Sender: TObject);
    procedure TextFeldKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    defWidth : integer;
  public
    { Public declarations }
    function Execute (const APos       : TPoint;
                      const Titel,Desc : string;
                      var AText  : string) : boolean;
  end;

(* Text eingeben, Ergebnis: "true" bei "ok" *)
function InputText(const APos       : TPoint;
                   const Titel,Desc : string;
                   var AText  : string) : boolean;

var
  InputStringDialog: TInputStringDialog;

implementation

{$R *.DFM}

uses System.IniFiles, GnuGetText, WinUtils, ShowMessageDlg, ImageLoader;

{ ------------------------------------------------------------------- }
procedure TInputStringDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs-svg');
  ImageLoader.LoadImages('dialogs',[imlGlyphs.SVGIconItems]);
  defWidth:=ClientWidth;
  imlGlyphs.DPIChanged(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;

procedure TInputStringDialog.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  imlGlyphs.DPIChanged(Sender,OldDPI,NewDPI);
  end;

procedure TInputStringDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{$IFDEF ACCESSIBLE}
  if (Key=VK_F11) then begin
    with ActiveControl do if length(Hint)>0 then ShowHintInfo(Hint);
    end;
{$ENDIF}
  end;

procedure TInputStringDialog.FormShow(Sender: TObject);
begin
  FitToScreen(Screen,self);
  end;

{ ------------------------------------------------------------------- }
procedure TInputStringDialog.TextFeldKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=#$1B then Modalresult:=mrCancel
  else if Key=#$D then Modalresult:=mrOK;
  end;

{ ------------------------------------------------------------------- }
function TInputStringDialog.Execute (const APos       : TPoint;
                                     const Titel,Desc : string;
                                     var AText  : string) : boolean;
var
  w : integer;
begin
  AdjustFormPosition(Screen,self,APos);
  if length(Titel)>0 then Caption:=Titel;
  Descriptor.Caption:=Desc;
  ActiveControl:=TextFeld;
  with TextFeld do begin
    Text:=AText;
    Hint:=Desc;
    end;
  w:=GetTextWidth(AText,TextFeld.Font)+PixelScale(20,self);
  if w>defWidth then ClientWidth:=w else ClientWidth:=defWidth;
  if ShowModal=mrOK then begin
    AText:=TextFeld.Text;
    Result:=true;
    end
  else Result:=false;
  end;

{ ------------------------------------------------------------------- }
(* Txt eingeben, Ergebnis: "true" bei "ok" *)
function InputText (const APos       : TPoint;
                    const Titel,Desc : string;
                    var AText  : string) : boolean;
begin
  if not assigned(InputStringDialog) then InputStringDialog:=TInputStringDialog.Create(Application);
  Result:=InputStringDialog.Execute(APos,Titel,Desc,AText);
  FreeAndNil(InputStringDialog);
  end;

end.
