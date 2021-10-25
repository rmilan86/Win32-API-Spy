program Win32_API_Spy;

uses
  Forms,
  uMain in 'forms\uMain.pas' {frmMain},
  uSplash in 'forms\uSplash.pas' {frmSplash},
  uGlobals in 'includes\uGlobals.pas',
  uReport in 'forms\uReport.pas' {frmReports},
  uApiSpy in 'includes\uApiSpy.pas',
  uReportLoad in 'forms\uReportLoad.pas' {frmReportsLoad},
  uPreferences in 'forms\uPreferences.pas' {frmPreferences},
  uModifyReport in 'forms\uModifyReport.pas' {frmModifyReport},
  uCodeGen in 'forms\uCodeGen.pas' {frmCodeGen},
  uColorSpy in 'forms\uColorSpy.pas' {frmColorSpy},
  uAdvWinInfo in 'forms\uAdvWinInfo.pas' {frmAdvWinInfo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.Title := 'Win32 API Spy';
  Application.CreateForm(TfrmSplash, frmSplash);
  Application.CreateForm(TfrmColorSpy, frmColorSpy);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmReports, frmReports);
  Application.CreateForm(TfrmReportsLoad, frmReportsLoad);
  Application.CreateForm(TfrmModifyReport, frmModifyReport);
  Application.CreateForm(TfrmCodeGen, frmCodeGen);
  Application.CreateForm(TfrmAdvWinInfo, frmAdvWinInfo);
  Application.Run;
end.
