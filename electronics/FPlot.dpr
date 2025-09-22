program FPlot;

{$R 'languages.res' 'languages.rc'}

uses
  GnuGetText in '..\units\GnuGetText.pas',
  LangUtils in '..\units\LangUtils.pas',
  Forms,
  Graphics,
  FqMain in 'FqMain.pas' {MainForm},
  PartDlg in 'PartDlg.pas' {PartDialog},
  VarValDlg in 'VarValDlg.pas' {VarValueDialog},
  ValueDlg in 'ValueDlg.pas' {ValueDialog},
  ShellDirDlg in '..\dialogs\ShellDirDlg.pas' {ShellDirDialog};

{$R *.res}

begin
  TP_GlobalIgnoreClass(TFont);
  // init language support
  InitTranslation(['delphi10','units']);

  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TPartDialog, PartDialog);
  Application.CreateForm(TVarValueDialog, VarValueDialog);
  Application.CreateForm(TValueDialog, ValueDialog);
  Application.CreateForm(TShellDirDialog, ShellDirDialog);
  Application.Run;
end.
