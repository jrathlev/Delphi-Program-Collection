program ShowLangSettings;

uses
  Vcl.Forms,
  LangSettingsMain in 'LangSettingsMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
