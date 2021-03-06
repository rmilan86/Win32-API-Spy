unit uSplash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, jpeg, ActnList, XPStyleActnCtrls, ActnMan,
  ActnColorMaps, ActnPopup, ImgList;

type
  TfrmSplash = class(TForm)
    TrayIcon: TTrayIcon;
    Image1: TImage;
    tmr: TTimer;
    PopupActionBar1: TPopupActionBar;
    ActionManager1: TActionManager;
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Action5: TAction;
    ApiSpy1: TMenuItem;
    ViewReport1: TMenuItem;
    ColorSpy1: TMenuItem;
    CodeGenerator1: TMenuItem;
    ImageList1: TImageList;
    N2: TMenuItem;
    Exit1: TMenuItem;
    About1: TMenuItem;
    Exit2: TMenuItem;
    N3: TMenuItem;
    Preferences1: TMenuItem;
    N1: TMenuItem;
    lblInfo: TLabel;
    procedure tmrTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ViewApiSpy1Click(Sender: TObject);
    procedure ViewReport1Click(Sender: TObject);
    procedure ColorSpy1Click(Sender: TObject);
    procedure CodeGenerator1Click(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action5Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure ApiSpy1Click(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Win32APISpyOptions1Click(Sender: TObject);
    procedure Exit2Click(Sender: TObject);
    procedure Preferences1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSplash: TfrmSplash;

implementation

uses
	uGlobals, uMain, uPreferences, uReport, uReportLoad, uCodeGen, uColorSpy;

{$R *.dfm}
{$R Cursor.res}

procedure TfrmSplash.Action1Execute(Sender: TObject);
begin
	{ Comment to enable action. }
end;

procedure TfrmSplash.Action2Execute(Sender: TObject);
begin
	{ Comment to enable action. }
end;

procedure TfrmSplash.Action3Execute(Sender: TObject);
begin
	{ Comment to enable action. }
end;

procedure TfrmSplash.Action4Execute(Sender: TObject);
begin
	{ Comment to enable action. }
end;

procedure TfrmSplash.Action5Execute(Sender: TObject);
begin
	{ Comment to enable action. }
end;

procedure TfrmSplash.ApiSpy1Click(Sender: TObject);
begin
	if (bReportLoading = true) then exit;
   
   { Check and close forms }
   frmPreferences.Close;
   frmReports.Close;

	frmMain.Show;
end;

procedure TfrmSplash.CodeGenerator1Click(Sender: TObject);
begin
   frmCodeGen.Show;
end;

procedure TfrmSplash.ColorSpy1Click(Sender: TObject);
begin
   frmColorSpy.Show;
end;

procedure TfrmSplash.Exit2Click(Sender: TObject);
begin
	if (bReportLoading = true) then exit;

	if (MessageBox(Handle,
               	PAnsiChar('Are you sure you want to exit?'),
                  PAnsiChar(Application.Title),
                  $00000044) = IDYES) then
   begin
		Application.Terminate;
   end;
end;

procedure TfrmSplash.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	TrayIcon.Visible := false;
end;

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
	Self.Width := Image1.Width;
	Self.Height := Image1.Height;
   tmr.Enabled := true;
end;

procedure TfrmSplash.Preferences1Click(Sender: TObject);
begin
	{ Reports loading, don't go any further! }
	if (bReportLoading = true) then exit;

   { Close all forms }
   frmMain.Close;
   frmReports.Close;
   frmPreferences.Close;

	{ Display Preferences }
	frmPreferences.Show;
end;

procedure TfrmSplash.tmrTimer(Sender: TObject);
var
	n : Integer;
begin
   with Self do
   begin
      AlphaBlendValue := 255;
      AlphaBlend := true;

      for n := 255 downto 0 do
      begin
      	AlphaBlendValue := n;
         Sleep(7);
      end;

      { Hide form and remove taskbar button }
		  HideFromTaskBar(Handle, True);
   	  ShowWindow(Handle, SW_HIDE);
		  Self.Hide;
      AlphaBlend := false;
   end;

   { Activate tray icon }
   TrayIcon.Visible := true;

   { Display a balloon explaining to the user how to access the program }
   TrayIcon.BalloonTitle := Application.Title;
   TrayIcon.BalloonHint := 'Right-click on the "Tray Icon" below for options.';
   TrayIcon.BalloonTimeout := 1;
   TrayIcon.ShowBalloonHint;


	{ Disable the timer }
   tmr.Enabled := false;
end;

procedure TfrmSplash.ViewApiSpy1Click(Sender: TObject);
begin
	if (bReportLoading = true) then exit;

   frmMain.Close;
   frmReports.Close;
   frmPreferences.Close;

   { Show Form }
	frmMain.Show;
end;

procedure TfrmSplash.ViewReport1Click(Sender: TObject);
begin
	if (bReportLoading = true) then exit;

	{ Close all forms }
   frmMain.Close;
   frmReports.Close;
   frmPreferences.Close;

   { Faster method for cleaning listview }
   frmReports.lvReport.Items.BeginUpdate;
   frmReports.lvReport.Items.Clear;
   frmReports.lvReport.Items.EndUpdate;

   { Show Reports }
	frmReports.Show;
end;

procedure TfrmSplash.Win32APISpyOptions1Click(Sender: TObject);
begin
	frmReports.Show;
end;

end.
