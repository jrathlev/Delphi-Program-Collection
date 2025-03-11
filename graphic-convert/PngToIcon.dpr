program PngToIcon;

uses
  GnuGetText in '..\Units\GnuGetText.pas',
  LangUtils in '..\Units\LangUtils.pas',
  Vcl.Graphics,
  Vcl.Forms,
  PngToIconMain in 'PngToIconMain.pas' {MainForm},
  ShellDirDlg in '..\dialogs\ShellDirDlg.pas' {ShellDirDialog};

{$R *.res}

begin
  TP_GlobalIgnoreClass(TFont);
  // Subdirectory in AppData for user configuration files and supported languages
  InitTranslation('JR-WeicheWare','',['delphi10','units']);

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TShellDirDialog, ShellDirDialog);
  Application.Run;
end.

