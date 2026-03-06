program ShowFormatSettings;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, WinApi.Windows, ExtSysUtils;


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

function GetLanguageID (const LangName : string) : TLocaleID;
var
  nc : cardinal;
begin
  Result:=0; nc:=0;
  if GetLocaleInfoEx(pchar(LangName),LOCALE_RETURN_NUMBER or LOCALE_ILANGUAGE,@nc,4)>0 then begin
    Result:=nc;
    end;
  end;

const
  CCurrencyFormats: array[0 .. 3] of string = ('%s1.23', '1.23%s', '%s 1.23', '1.23 %s');
  CNegCurrencyFormats: array[0 .. 15] of string =
   ('(%s1.23)', '-%s1.23', '%s-1.23', '%s1.23-',
    '(1.23%s)', '-1.23%s', '1.23-%s', '1.23%s-',
    '-1.23 %s', '-%s 1.23', '1.23 %s-', '%s 1.23-',
    '%s -1.23', '1.23- %s', '(%s 1.23)', '(1.23 %s)');

var
  i,j : integer;
  li  : TLocaleID;
begin
  SetConsoleOutputCP(CP_UTF8);
  if ParamCount>0 then if TryStrToInt(ParamStr(1),i) then li:=i else li:=0;
//  li:=GetLanguageID('de');
//  writeln('User interface (UI) Languages');
//  li:=GetUserDefaultUILanguage;
//  writeln(Format('  User:         %s ($%.4x)',[GetLanguageName(li),li]));
//  li:=GetSystemDefaultUILanguage;
//  writeln(Format('  System:       %s ($%.4x)',[GetLanguageName(li),li]));
//  writeln;
//  writeln('Languages from regional settings');
//  li:=GetUserDefaultLangID;
//  writeln(Format('  User:         %s ($%.4x)',[GetLanguageName(li),li]));
//  li:=GetSystemDefaultLangID;
//  writeln(Format('  System:       %s ($%.4x)',[GetLanguageName(li),li]));
//  writeln;

  if not IsValidLocale(li, LCID_INSTALLED) then
    li:=GetThreadLocale;
    writeln(Format('Formatsettings (Language ID = $%.4x)',[li]));

//  writeln(Format('Formatsettings (Language ID = $%.4x)',[SysLocale.DefaultLCID]));
  with TFormatSettings.Create(li) do begin
    writeln('  CurrencyString:    ',CurrencyString);
    writeln('  CurrencyDecimals:  ',CurrencyDecimals);
    writeln('  CurrencyFormat:    ',Format(CCurrencyFormats[CurrencyFormat],[CurrencyString]));
    writeln('  NegCurrFormat:     ',Format(CNegCurrencyFormats[NegCurrFormat],[CurrencyString]));
    writeln;
    writeln('  DecimalSeparator:  ',DecimalSeparator);
    writeln('  ThousandSeparator: ',ThousandSeparator);
    writeln('  ListSeparator:     ',ListSeparator);
    writeln;
    writeln('  DateSeparator:     ',DateSeparator);
    writeln('  TimeSeparator:     ',TimeSeparator);
    writeln('  ShortDateFormat:   ',ShortDateFormat);
    writeln('  LongDateFormat:    ',LongDateFormat);
    writeln('  TimeAMString:      ',TimeAMString);
    writeln('  TimePMString:      ',TimePMString);
    writeln('  ShortTimeFormat:   ',ShortTimeFormat);
    writeln('  LongTimeFormat:    ',LongTimeFormat);
    writeln('  ShortMonthNames:');
      for i:=0 to 2 do begin
        for j:=1 to 4 do write('    ',ShortMonthNames[4*i+j]);
        writeln;
        end;
    writeln('  LongMonthNames:');
      for i:=0 to 2 do begin
        for j:=1 to 4 do write('    ',Format('%-15s',[LongMonthNames[4*i+j]]));
        writeln;
        end;
    writeln('  ShortDayNames:');
      for i:=1 to 7 do write('    ',ShortDayNames[i]);
      writeln;
    writeln('  LongDayNames:');
      for i:=1 to 7 do write('    ',LongDayNames[i]);
    writeln;
//    writeln('  ',EraInfo: array of TEraInfo;
    writeln('  TwoDigitYearCenturyWindow: ',TwoDigitYearCenturyWindow);
    writeln;
    writeln(FormatDateTime(LongDateFormat,Now));
  end;

{$ifdef DEBUG}
  WaitForAnyKey;
{$endif}
end.
