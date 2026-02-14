unit LangSettingsMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  Vcl.ComCtrls;

type
  TfrmMain = class(TForm)
    gbNumbers: TGroupBox;
    lvNum: TListView;
    gbDateTime: TGroupBox;
    lvDateTimeSep: TListView;
    lvDateTime: TListView;
    gbLanguages: TGroupBox;
    paButtons: TPanel;
    btRegSys: TSpeedButton;
    btRegUser: TSpeedButton;
    btUiSys: TSpeedButton;
    btUIUser: TSpeedButton;
    gbUserInt: TGroupBox;
    edUISysName: TLabeledEdit;
    edUISysId: TEdit;
    edUIUserId: TEdit;
    edUIUserName: TLabeledEdit;
    gbRegSet: TGroupBox;
    edRegSysName: TLabeledEdit;
    edRegUserName: TLabeledEdit;
    edRegSysId: TEdit;
    edRegUserId: TEdit;
    gbWeeks: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    lbWeekdaysShort: TListBox;
    lbWeekdaysLong: TListBox;
    gbMonths: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    lbMonthsShort1: TListBox;
    lbMonthsLong1: TListBox;
    lbMonthsShort2: TListBox;
    lbMonthsLong2: TListBox;
    btQuit: TBitBtn;
    laCountry: TLabel;
    laCountryEng: TLabel;
    procedure btUiSysClick(Sender: TObject);
    procedure btUIUserClick(Sender: TObject);
    procedure btRegSysClick(Sender: TObject);
    procedure btRegUserClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btQuitClick(Sender: TObject);
  private
    { Private-Deklarationen }
    fs : TFormatsettings;
    procedure ShowFormatSettings (id : TLocaleID);
  public
    { Public-Deklarationen }
  end;

var
  frmMain: TfrmMain;


implementation

{$R *.dfm}

uses System.StrUtils;

const
  CCurrencyFormats: array[0 .. 3] of string = ('%s1.23', '1.23%s', '%s 1.23', '1.23 %s');
  CNegCurrencyFormats: array[0 .. 15] of string =
   ('(%s1.23)', '-%s1.23', '%s-1.23', '%s1.23-',
    '(1.23%s)', '-1.23%s', '1.23-%s', '1.23%s-',
    '-1.23 %s', '-%s 1.23', '1.23 %s-', '%s 1.23-',
    '%s -1.23', '1.23- %s', '(%s 1.23)', '(1.23 %s)');

function GetInfo (LangId : TLocaleID; AType : LCType) : string;
var
  nc : cardinal;
  buf : array of Char;
begin
  Result:=''; nc:=0;
  nc:=GetLocaleInfo(LangId,AType,nil,nc);
  if nc>0 then begin
    SetLength(buf,nc);
    if GetLocaleInfo(LangId,AType,@buf[0],nc)>0 then
      Result:=PChar(@buf[0]);
    buf:=nil;
    end;
  end;

function GetLanguageName (LangId : TLocaleID) : string;
var
  nc : cardinal;
  buf : array of Char;
begin
  Result:=''; nc:=0;
  nc:=GetLocaleInfo(LangId,LOCALE_SNAME,nil,nc);
  if nc>0 then begin
    SetLength(buf,nc);
    if GetLocaleInfo(LangId,LOCALE_SNAME,@buf[0],nc)>0 then
      Result:=PChar(@buf[0]);
    buf:=nil;
    end;
  end;

function UserName : string;
var
  p : pchar;
  size : dword;
begin
  size:=1024;
  p:=StrAlloc(size);
  GetUserName (p,size);
  Result:=p;
  Strdispose(p);
  end;

procedure TfrmMain.FormShow(Sender: TObject);
var
  li  : TLocaleID;
begin
  gbLanguages.Caption:=Format('Languages (%s)',[Username]);
  li:=GetUserDefaultUILanguage;
  edUIUserName.Text:=GetLanguageName(li);
  edUIUserId.Text:=Format('$%.4x',[li]);
  edUIUserId.Tag:=li;
  li:=GetUserDefaultLangID;
  edRegUserName.Text:=GetLanguageName(li);
  edRegUserId.Text:=Format('$%.4x',[li]);
  edRegUserId.Tag:=li;
  li:=GetSystemDefaultUILanguage;
  edUISysName.Text:=GetLanguageName(li);
  edUiSysId.Text:=Format('$%.4x',[li]);
  edUiSysId.Tag:=li;
  li:=GetSystemDefaultLangID;
  edRegSysName.Text:=GetLanguageName(li);
  edRegSysId.Text:=Format('$%.4x',[li]);
  edRegSysId.Tag:=li;
  with btUIUser do begin
    Down:=true; Click;
    end;
  end;

procedure TfrmMain.btQuitClick(Sender: TObject);
begin
  Close;
  end;

procedure TfrmMain.btRegSysClick(Sender: TObject);
begin
  ShowFormatSettings(edRegSysId.Tag);
  end;

procedure TfrmMain.btRegUserClick(Sender: TObject);
begin
  ShowFormatSettings(edRegUserId.Tag);
  end;

procedure TfrmMain.btUIUserClick(Sender: TObject);
begin
  ShowFormatSettings(edUIUserId.Tag);
  end;

procedure TfrmMain.btUiSysClick(Sender: TObject);
begin
  ShowFormatSettings(edUISysId.Tag);
  end;

procedure TfrmMain.ShowFormatSettings (id : TLocaleID);

  procedure LvAdd (lv : TListView; const sn,sv : string);
  begin
    with lv.Items.Add do begin
      Caption:=sn;
      SubItems.Add(sv);
      end;
    end;

  procedure LvAddSample (lv : TListView; const sn,sv,ss : string);
  begin
    with lv.Items.Add do begin
      Caption:=sn;
      SubItems.Add(sv);
      SubItems.Add(ss);
      end;
    end;

var
  i : integer;
  fs : TFormatsettings;
begin
  laCountryEng.Caption:=GetInfo(id,LOCALE_SENGLISHDISPLAYNAME);
  laCountry.Caption:=GetInfo(id,LOCALE_SLOCALIZEDDISPLAYNAME);
  fs:=TFormatsettings.Create(id);
  with fs do begin
    lvNum.Clear;
    LvAdd(lvNum,'ThousandSeparator: ',ThousandSeparator);
    LvAdd(lvNum,'DecimalSeparator:  ',DecimalSeparator);
    LvAdd(lvNum,'ListSeparator:     ',ListSeparator);
    LvAdd(lvNum,'CurrencyString:    ',CurrencyString);
    LvAdd(lvNum,'CurrencyDecimals:  ',IntToStr(CurrencyDecimals));
    LvAdd(lvNum,'CurrencyFormat:    ',Format(CCurrencyFormats[CurrencyFormat],[CurrencyString]));
    LvAdd(lvNum,'NegCurrFormat:     ',Format(CNegCurrencyFormats[NegCurrFormat],[CurrencyString]));

    lvDateTimeSep.Clear;
    LvAdd(lvDateTimeSep,'DateSeparator:     ',DateSeparator);
    LvAdd(lvDateTimeSep,'TimeSeparator:     ',TimeSeparator);
    LvAdd(lvDateTimeSep,'TimeAMString:      ',TimeAMString);
    LvAdd(lvDateTimesep,'TimePMString:      ',TimePMString);
    LvAdd(lvDateTimeSep,'TwoDigitYearCenturyWindow: ',IntToStr(TwoDigitYearCenturyWindow));
    lvDateTime.Clear;
    LvAddSample(lvDateTime,'ShortDateFormat:   ',ShortDateFormat,FormatDateTime(ShortDateFormat,Now,fs));
    LvAddSample(lvDateTime,'LongDateFormat:    ',LongDateFormat,FormatDateTime(LongDateFormat,Now,fs));
    LvAddSample(lvDateTime,'ShortTimeFormat:   ',ShortTimeFormat,FormatDateTime(ShortTimeFormat,Now,fs));
    LvAddSample(lvDateTime,'LongTimeFormat:    ',LongTimeFormat,FormatDateTime(LongTimeFormat,Now,fs));

    lbWeekdaysShort.Clear;
    for i:=1 to 7 do lbWeekdaysShort.AddItem(ShortDayNames[i],nil);
    lbWeekdaysLong.Clear;
    for i:=1 to 7 do lbWeekdaysLong.AddItem(LongDayNames[i],nil);
    lbMonthsShort1.Clear;
    for i:=1 to 6 do lbMonthsShort1.AddItem(ShortMonthNames[i],nil);
    lbMonthsShort2.Clear;
    for i:=7 to 12 do lbMonthsShort2.AddItem(ShortMonthNames[i],nil);
    lbMonthsLong1.Clear;
    for i:=1 to 6 do lbMonthsLong1.AddItem(LongMonthNames[i],nil);
    lbMonthsLong2.Clear;
    for i:=7 to 12 do lbMonthsLong2.AddItem(LongMonthNames[i],nil);
    end;
  end;

end.
