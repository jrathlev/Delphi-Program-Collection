(* Delphi dialog
   Edit password with confirmation

   © Dr. J. Rathlev, D-24222 Schwentinental (kontakt(a)rathlev-home.de)

   The contents of this file may be used under the terms of the
   Mozilla Public License ("MPL") or
   GNU Lesser General Public License Version 2 or later (the "LGPL")

   Software distributed under this License is distributed on an "AS IS" basis,
   WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
   the specific language governing rights and limitations under the License.
    
   Vers. 1 - June 2005
   Vers. 2 - July 2022: define compiler switch "ACCESSIBLE" to make dialog
                        messages accessible to screenreaders
   Vers. 2 - Feb. 2025: SVG glyphs
   last modified: July 2025
   *)
   
unit NewPwdDlg;

interface

uses Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Forms,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, SVGIconImageListBase, SVGIconImageList, JrButtons;

const
  defMinPwdLength = 8;

type
  TNewPwdDialog = class(TForm)
    paPwd: TPanel;
    paBottom: TPanel;
    paConfirm: TPanel;
    edtPwd: TLabeledEdit;
    edtRepPwd: TLabeledEdit;
    imgBar: TImage;
    Label1: TLabel;
    imlGlyphs: TSVGIconImageList;
    CancelBtn: TJrButton;
    OKBtn: TJrButton;
    btnShow: TJrSpeedButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnShowClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtPwdExit(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FConf   : boolean;
    hgt,
    FMinLen : integer;
    procedure DrawHorGradientBar (const Canvas : TCanvas;
                BorderCol,BakCol,Color1,Color2,Color3 : TColor; ARect : TRect; Value : integer);
    procedure ShowBar (const Password : string);
  public
    { Public declarations }
    function Execute (const Title : string; var Pwd : String;
                      Confirm : boolean; Show : boolean = false;
                      MinLen : integer = defMinPwdLength) : boolean; overload;
    function Execute (const Title : string; var Pwd : AnsiString;
                      Confirm : boolean; Show : boolean = false;
                      MinLen : integer = defMinPwdLength) : boolean; overload;
    function Execute (const APos : TPoint; const Title : string; var Pwd : String;
                      Confirm : boolean; Show : boolean = false;
                      MinLen : integer = defMinPwdLength) : boolean; overload;
    function Execute (const APos : TPoint; const Title : string; var Pwd : AnsiString;
                      Confirm : boolean; Show : boolean = false;
                      MinLen : integer = defMinPwdLength) : boolean; overload;
  end;

// Ansi password (no unicode)
function InputNewPassword (const APos : TPoint; const Title : string; var Pwd : AnsiString;
                           Confirm : boolean; Show : boolean = false;
                           MinLen : integer = defMinPwdLength) : boolean; overload;

function InputNewPassword (const Title : string; var Pwd : AnsiString;
                           Confirm : boolean; Show : boolean = false;
                           MinLen : integer = defMinPwdLength) : boolean; overload;

// Unicode password
function InputNewPassword (const APos : TPoint; const Title : string; var Pwd : String;
                           Confirm : boolean; Show : boolean = false;
                           MinLen : integer = defMinPwdLength) : boolean; overload;

function InputNewPassword (const Title : string; var Pwd : String;
                           Confirm : boolean; Show : boolean = false;
                           MinLen : integer = defMinPwdLength) : boolean; overload;

function GetPassword (const APos : TPoint; const Title : string; var Pwd : string) : boolean; overload;
function GetPassword (const APos : TPoint; const Title : string; var Pwd : AnsiString) : boolean; overload;

function GetPassword (const Title : string; var Pwd : String) : boolean; overload;
function GetPassword (const Title : string; var Pwd : AnsiString) : boolean; overload;

var
  NewPwdDialog: TNewPwdDialog;

implementation

{$R *.DFM}

uses GnuGetText, ExtSysUtils, WinUtils, PasswordStrength, ShowMessageDlg, ImageLoader;

{ ------------------------------------------------------------------- }
procedure TNewPwdDialog.FormCreate(Sender: TObject);
begin
  TranslateComponent (self,'dialogs-svg');
  ImageLoader.LoadImages('dialogs',[imlGlyphs.SVGIconItems]);
  hgt:=paConfirm.Height;
  imlGlyphs.DPIChanged(self,PixelsPerInchOnDesign,Monitor.PixelsPerInch);
  end;

procedure TNewPwdDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{$IFDEF ACCESSIBLE}
  if (Key=VK_F11) then begin
    if ActiveControl is TCustomEdit then begin
      with (ActiveControl as TCustomEdit) do if length(TextHint)>0 then ShowHintInfo(TextHint)
      else if length(Hint)>0 then ShowHintInfo(Hint);
      end
    else with ActiveControl do if length(Hint)>0 then ShowHintInfo(Hint);
    end;
{$ENDIF}
  end;

procedure TNewPwdDialog.FormShow(Sender: TObject);
begin
  FitToScreen(Screen,self);
  end;

procedure TNewPwdDialog.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  imlGlyphs.DPIChanged(Sender,OldDPI,NewDPI);
  end;

procedure TNewPwdDialog.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult=mrOK) and FConf then
    CanClose:=(edtPwd.Text=edtRepPwd.Text)
               and ((length(edtPwd.Text)>=FMinLen) or (length(edtPwd.Text)=0));
  if not CanClose then begin
    if length(edtPwd.Text)<FMinLen then begin
      ErrorDialog(TryFormat(dgettext('dialogs-svg','Minimum length of password is %u characters'),[FMinLen]));
      edtPwd.SetFocus;
      end
    else begin
      ErrorDialog(dgettext('dialogs-svg','Passwords do not match!'));
      edtRepPwd.SetFocus;
      end;
    end;
  end;

{ ------------------------------------------------------------------- }
type
  TPixelRec = packed record
    case Boolean of
      true:  (Color: TColor);
      false: (r, g, b, Reserved: Byte);
    end;

procedure TNewPwdDialog.DrawHorGradientBar (const Canvas : TCanvas; BorderCol,BakCol,Color1,Color2,Color3 : TColor;
                       ARect : TRect; Value : integer);
var
  c1,c2,c3,c : TPixelRec;  //for easy access to RGB values as well as TColor value
  x,w : integer;
  OldPenWidth: Integer;    //Save old settings to restore them properly
  OldPenStyle: TPenStyle;  //see above
  s : string;
  sz : TSize;
begin
  c1.Color:=ColorToRGB(Color1);  //convert system colors to RGB values
  c2.Color:=ColorToRGB(Color2);  //if neccessary
  c3.Color:=ColorToRGB(Color3);  //if neccessary
  w:=(ARect.Right-ARect.Left) div 2;
  with Canvas do begin
    OldPenWidth:=Pen.Width;   //save old settings
    OldPenStyle:=Pen.Style;
    Pen.Width:=1;             //ensure correct pen settings
    Pen.Style:=psInsideFrame;
    for x:=0 to w do begin   //current pixel position to be set
      c.r:=Round(c1.r+(c2.r-c1.r)*x/w);
      c.g:=Round(c1.g+(c2.g-c1.g)*x/w);
      c.b:=Round(c1.b+(c2.b-c1.b)*x/w);
      Brush.Color:=c.Color;
      FillRect(Rect(ARect.Left+x,ARect.Top,ARect.Left+x+1,ARect.Bottom));
      end;
    for x:=w to ARect.Right-ARect.Left do begin   //current pixel position to be set
      c.r:=Round(c2.r+(c3.r-c2.r)*(x-w)/w);
      c.g:=Round(c2.g+(c3.g-c2.g)*(x-w)/w);
      c.b:=Round(c2.b+(c3.b-c2.b)*(x-w)/w);
      Brush.Color:=c.Color;
      FillRect(Rect(ARect.Left+x,ARect.Top,ARect.Left+x+1,ARect.Bottom));
      end;
    Brush.Color:=BakCol;
    x:=MulDiv(ARect.Right-ARect.Left,Value,100);
    FillRect(Rect(ARect.Left+x, ARect.Top,ARect.Right, ARect.Bottom));
    Brush.Color:=clBlack;
    FrameRect(ARect);
    s:=IntToStr(Value)+'%';
    sz:=TextExtent(s);
    SetBkMode(Handle,TRANSPARENT);
    TextOut(w-sz.Width div 2,(ARect.Bottom-ARect.Top-sz.Height) div 2,s);
    Pen.Width:=OldPenWidth; //restore old settings
    Pen.Style:=OldPenStyle;
    end;
  end;

procedure TNewPwdDialog.edtPwdExit(Sender: TObject);
begin
  ShowBar(edtPwd.Text);
  end;

procedure TNewPwdDialog.ShowBar (const Password : string);
var
  val : integer;
begin
  val:=PassphraseScore(Password);
  if length(Password)<FMinLen then val:=0;
  with imgBar do DrawHorGradientBar(Canvas,clBtnText,NewPwdDialog.Color,clRed,clYellow,clGreen,ClientRect,val);
  end;

{ ------------------------------------------------------------------- }
procedure TNewPwdDialog.btnShowClick(Sender: TObject);
var
  c : char;
begin
  if btnShow.Down then c:=#0 else c:='*';
  edtPwd.PasswordChar:=c;
  edtRepPwd.PasswordChar:=c;
  end;

{ ------------------------------------------------------------------- }
(* Passworteingabe, Ergebnis: "true" bei "ok" *)
function TNewPwdDialog.Execute (const APos : TPoint; const Title : string; var Pwd : String;
                                Confirm,Show : boolean; MinLen : integer) : boolean;
var
  h : integer;
begin
  AdjustFormPosition(Screen,self,APos);
  Caption:=Title;
  if Show then begin
    edtPwd.Text:=Pwd;
    edtRepPwd.Text:=Pwd;
    edtPwd.Width:=edtRepPwd.Width-MulDiv(btnShow.Width,12,10);
    end
  else begin
    edtPwd.Text:='';
    edtRepPwd.Text:='';
    edtPwd.Width:=edtRepPwd.Width;
    end;
  ShowBar(Pwd);
  FConf:=Confirm;
  FMinLen:=MinLen;
  btnShow.Visible:=Show;
  h:=paPwd.Height+paBottom.Height;
//  paConfirm.Visible:=FConf;
  if FConf then ClientHeight:=h+hgt else ClientHeight:=h;
  edtRepPwd.TabStop:=FConf;
  ActiveControl:=edtPwd;
  if ShowModal=mrOK then begin
    Pwd:=edtPwd.Text;
    Result:=true;
    end
  else Result:=false;
  end;

function TNewPwdDialog.Execute (const APos : TPoint; const Title : string; var Pwd : AnsiString;
                      Confirm,Show : boolean; MinLen : integer) : boolean;
var
  s : string;
begin
  Result:=Execute (APos,Title,s,Confirm,Show,MinLen);
  if Result then Pwd:=s;
  end;

function TNewPwdDialog.Execute (const Title  : string; var Pwd : String;
                                Confirm,Show : boolean; MinLen : integer) : boolean;
begin
  Result:=Execute(CenterPos,Title,Pwd,Confirm,Show,MinLen);
  end;

function TNewPwdDialog.Execute (const Title  : string; var Pwd : AnsiString;
                                Confirm,Show : boolean; MinLen : integer) : boolean;
begin
  Result:=Execute(CenterPos,Title,Pwd,Confirm,Show,MinLen);
  end;

{ ------------------------------------------------------------------- }
function InputNewPassword (const APos : TPoint; const Title : string; var Pwd : AnsiString;
                           Confirm,Show : boolean; MinLen : integer) : boolean;
begin
  if not assigned(NewPwdDialog) then NewPwdDialog:=TNewPwdDialog.Create(Application);
  Result:=NewPwdDialog.Execute(APos,Title,Pwd,Confirm,Show,MinLen);
  FreeAndNil(NewPwdDialog);
  end;

function InputNewPassword (const Title : string; var Pwd : AnsiString;
                           Confirm,Show : boolean; MinLen : integer) : boolean;
begin
  Result:=InputNewPassword(CenterPos,Title,Pwd,Confirm,Show,MinLen);
  end;

function InputNewPassword (const APos : TPoint; const Title : string; var Pwd : String;
                           Confirm,Show : boolean; MinLen : integer) : boolean;
begin
  if not assigned(NewPwdDialog) then NewPwdDialog:=TNewPwdDialog.Create(Application);
  Result:=NewPwdDialog.Execute(APos,Title,Pwd,Confirm,Show,MinLen);
  FreeAndNil(NewPwdDialog);
  end;

function InputNewPassword (const Title : string; var Pwd : String;
                           Confirm,Show : boolean; MinLen : integer) : boolean;
begin
  Result:=InputNewPassword(CenterPos,Title,Pwd,Confirm,Show,MinLen);
  end;

function GetPassword (const APos : TPoint; const Title : string; var Pwd : String) : boolean;
begin
  if not assigned(NewPwdDialog) then NewPwdDialog:=TNewPwdDialog.create(Application);
  Result:=NewPwdDialog.Execute(APos,Title,Pwd,false);
  FreeAndNil(NewPwdDialog);
  end;

function GetPassword (const APos : TPoint; const Title : string; var Pwd : AnsiString) : boolean;
begin
  if not assigned(NewPwdDialog) then NewPwdDialog:=TNewPwdDialog.create(Application);
  Result:=NewPwdDialog.Execute(APos,Title,Pwd,false);
  FreeAndNil(NewPwdDialog);
  end;

function GetPassword (const Title : string; var Pwd : String) : boolean;
begin
  if not assigned(NewPwdDialog) then NewPwdDialog:=TNewPwdDialog.create(Application);
  Result:=NewPwdDialog.Execute(Title,Pwd,false);
  FreeAndNil(NewPwdDialog);
  end;

function GetPassword (const Title : string; var Pwd : AnsiString) : boolean;
begin
  if not assigned(NewPwdDialog) then NewPwdDialog:=TNewPwdDialog.create(Application);
  Result:=NewPwdDialog.Execute(Title,Pwd,false);
  FreeAndNil(NewPwdDialog);
  end;

end.
