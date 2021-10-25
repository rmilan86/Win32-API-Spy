unit uMain;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  ImgList,
  StdCtrls,
  Registry,
  uGlobals, { General procedures/functions }
  uApiSpy;  { ApiSpy procedures/functions }

const
	crMyCursor = 1; // Custom Cursor
   szSubkey = 'Software\MTechMedia';

type
  TfrmMain = class(TForm)
    imgIcon: TImage;
    gbParentInfo: TGroupBox;
    Label1: TLabel;
    lblpHandle: TLabel;
    gbWindowInfo: TGroupBox;
    Label2: TLabel;
    lblwHandle: TLabel;
    imgList: TImageList;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape1: TShape;
    imgSpy: TImage;
    Label6: TLabel;
    lblwClass: TLabel;
    Label7: TLabel;
    lblwText: TLabel;
    Label8: TLabel;
    lblpClass: TLabel;
    Label10: TLabel;
    lblpText: TLabel;
    lblReports: TLabel;
    chkAdv: TCheckBox;
    Label9: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure imgIconMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgIconMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgIconMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cmdReportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure chkAdvClick(Sender: TObject);
  private
    { Private declarations }
    procedure SaveSettings();
    procedure LoadSettings();
  public
    { Public declarations }
  end;

var
  frmMain  : TfrmMain;
  bEnabled : Boolean;

implementation

uses uReport, uSplash, uAdvWinInfo;

{$R *.dfm}

procedure TfrmMain.chkAdvClick(Sender: TObject);
begin
   if (chkAdv.Checked = true) then
   begin
      frmAdvWinInfo.Show;
   end else
   begin
      frmAdvWinInfo.Hide;
   end;
end;

procedure TfrmMain.cmdReportClick(Sender: TObject);
begin
	Self.Enabled := false;
   frmReports.Show;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	{ Save general settings }
	SaveSettings();

   { Save api info }
   if (High(AI) <> -1) then
   begin
   	SaveAPIInfo();
   end;

   frmAdvWinInfo.Hide;
   Self.Hide;
   CanClose := false;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
	FHandle    : File;
   dwFileSize : DWORD;
begin	{ Load Cursor }
	Screen.Cursors[crMyCursor] := LoadCursor(HInstance, 'SPYCUR');

   { Were not spying }
   bEnabled := false;

   { Load spy icon }
   imgSpy.Picture.Icon := imgIcon.Picture.Icon;

   { Load saved settings }
   LoadSettings();

   { Load previous api info data }
   if (FileExists(GetCurrentDir() + '\ai.dat') = true) then
   begin
   	{ Open the file for read only }
   	AssignFile(FHandle, GetCurrentDir() + '\ai.dat');
   	Reset(FHandle);

      { Get the file size }
      dwFileSize := GetFileSize(TFileRec(FHandle).Handle, nil);

      { Close the file handle }
      CloseFile(FHandle);

      { Make sure the file contains data }
      if (dwFileSize > 0) then
      begin
      	LoadAPIInfo();
      end;
   end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
   { Show Report }
   if (High(AI) = -1) then
   begin
		lblReports.Caption := 'You currently have [0] api logs reported.';
   end else
   begin
   	lblReports.Caption := 'You currently have [' + IntToStr(High(AI) + 1) + '] api logs reported.';
   end;
end;

procedure TfrmMain.imgIconMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
	Icon : TIcon;
begin
	if (Button <> mbLeft) then exit;

	{ Create a blank icon }
	Icon := TIcon.Create;

	{ Set spy cursor }
	Screen.Cursor := crMyCursor;

   { Remove the icon from the image control }
   imgSpy.Picture.Icon := Icon;

   { Set to true, were spying }
	bEnabled := true;

   { Free object }
   Icon.Free;
end;

procedure TfrmMain.imgIconMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
   szTemp : String;
begin
	if (bEnabled = true) then
   begin
   	GetApiInfo();

      { Format data for display }
   	with ApiInfo do
   	begin
      	{ Window Handle }
      	lblwHandle.Caption := IntToStr(wHandle) + ' ';

         if (wHandle <> 0) then
         begin
            { Check and fix length for window classname }
            if (Length(wClassN) <> 0) then
            begin
               if (Length(wClassN) > 24) then
               begin
                  lblwClass.Caption := #34 + Copy(wClassN, 1, 24) + '...' + #34 + ' ';
               end else
               begin
                  lblwClass.Caption := #34 + wClassN + #34 + ' ';
               end;
            end else
            begin
               lblwClass.Caption := #34 + 'No classname was found.' + #34 + ' ';
            end;

            { Check and fix length for window text }
            if (Length(wText) <> 0) then
            begin
               if (Length(wText) > 24) then
               begin
                  lblwText.Caption := #34 + Copy(wText, 1, 22) + '...' + #34 + ' ';
               end else
               begin
                  lblwText.Caption := #34 + wText + #34 + ' ';
               end;
            end else
            begin
               lblwText.Caption := #34 + 'No text was found.' + #34 + ' ';
            end;
             ///////////////////////////////////////////

            { Parent Handle }
            lblpHandle.Caption := IntToStr(pHandle) + ' ';

            if (pHandle <> 0) then
            begin
               { Check and fix length for parent classname }
               if (Length(pClassN) <> 0) then
               begin
                  if (Length(pClassN) > 24) then
                  begin
                     lblpClass.Caption := #34 + Copy(pClassN, 1, 24) + '...' + #34 + ' ';
                  end else
                  begin
                     lblpClass.Caption := #34 + pClassN + #34 + ' ';
                  end;
               end else
               begin
                  lblpClass.Caption := #34 + 'No classname was found.' + #34 + ' ';
               end;

               { Check and fix length for parent text }
               if (Length(pText) <> 0) then
               begin
                  if (Length(pText) > 24) then
                  begin
                     lblpText.Caption := #34 + Copy(pText, 1, 22) + '...' + #34 + ' ';
                  end else
                  begin
                     lblpText.Caption := #34 + pText + #34 + ' ';
                  end;
               end else
               begin
                  lblpText.Caption := #34 + 'No text was found.' + #34 + ' ';
               end;
            end else
            begin
               lblpHandle.Caption := IntToStr(0) + ' ';
               lblpClass.Caption := #34 + 'No classname was found.' + #34 + ' ';
               lblpText.Caption := #34 + 'No text was found.' + #34 + ' ';
            end;
         end else
         begin
         	lblwHandle.Caption := IntToStr(0) + ' ';
            lblwClass.Caption := #34 + 'No classname was found.' + #34 + ' ';
            lblwText.Caption := #34 + 'No text was found.' + #34 + ' ';

         	lblpHandle.Caption := IntToStr(0) + ' ';
            lblpClass.Caption := #34 + 'No classname was found.' + #34 + ' ';
            lblpText.Caption := #34 + 'No text was found.' + #34 + ' ';
         end;

         //////////////////////////////////////////////////////////////////////
         ///   Get Window Information                                        //
         //////////////////////////////////////////////////////////////////////
         //GetAdvWindowInfo(ApiInfo.wHandle, pWinInfo);

         pWinInfo.cbSize := SizeOf(TWindowInfo);
         if (GetWindowINfo(ApiInfo.wHandle, pWinInfo) <> false) then
         begin
            with frmAdvWinInfo do
            begin

               { Window Rect Information }
               lblWCoords.Caption := '[T: ' + IntToStr(pWinInfo.rcWindow.Top) + ', ' +
                                     'B: '  + IntToStr(pWinInfo.rcWindow.Bottom) + ', ' +
                                     'L: '  + IntToStr(pWinInfo.rcWindow.Left) + ', ' +
                                     'R: '  + IntToStr(pWinInfo.rcWindow.Right) + '] '+
                                     '[TL: x(' + IntToStr(pWinInfo.rcWindow.TopLeft.X) + '), ' +
                                     'y(' + IntToStr(pWinInfo.rcWindow.TopLeft.Y) + ')]' +
                                     ' - [BR: ]';

               { Client rect information }
               lblCCoords.Caption := '[T: ' + IntToStr(pWinInfo.rcClient.Top) + ', ' +
                                     'B: '  + IntToStr(pWinInfo.rcClient.Bottom) + ', ' +
                                     'L: '  + IntToStr(pWinInfo.rcClient.Left) + ', ' +
                                     'R: '  + IntToStr(pWinInfo.rcClient.Right) + '] ';


               { Window Style }
               szTemp := 'None ';
               if ((pWinInfo.dwStyle AND WS_MAXIMIZE) <> 0) then szTemp := 'WS_MAXIMIZE ';
               if ((pWinInfo.dwStyle AND WS_MINIMIZEBOX) <> 0) then szTemp := 'WS_MINIMIZEBOX ';
               if ((pWinInfo.dwStyle AND WS_THICKFRAME) <> 0) then szTemp := 'WS_THICKFRAME ';
               if ((pWinInfo.dwStyle AND WS_TILED) <> 0) then szTemp := 'WS_TILED ';
               if ((pWinInfo.dwStyle AND WS_TILEDWINDOW) <> 0) then szTemp := 'WS_TILEDWINDOW ';
               if ((pWinInfo.dwStyle AND WS_BORDER) <> 0) then szTemp := 'WS_BORDER ';
               if ((pWinInfo.dwStyle AND WS_CAPTION) <> 0) then szTemp := 'WS_CAPTION ';
               if ((pWinInfo.dwStyle AND WS_CHILD) <> 0) then szTemp := 'WS_CHILD ';
               if ((pWinInfo.dwStyle AND WS_CLIPCHILDREN) <> 0) then szTemp := 'WS_CLIPCHILDREN ';
               if ((pWinInfo.dwStyle AND WS_CLIPSIBLINGS) <> 0) then szTemp := 'WS_CLIPSIBLINGS ';
               if ((pWinInfo.dwStyle AND WS_DISABLED) <> 0) then szTemp := 'WS_DISABLED ';
               if ((pWinInfo.dwStyle AND WS_DLGFRAME) <> 0) then szTemp := 'WS_DLGFRAME ';
               if ((pWinInfo.dwStyle AND WS_GROUP) <> 0) then szTemp := 'WS_GROUP ';
               if ((pWinInfo.dwStyle AND WS_HSCROLL) <> 0) then szTemp := 'WS_HSCROLL ';
               if ((pWinInfo.dwStyle AND WS_ICONIC) <> 0) then szTemp := 'WS_ICONIC ';
               if ((pWinInfo.dwStyle AND WS_MAXIMIZEBOX) <> 0) then szTemp := 'WS_MAXIMIZEBOX ';
               if ((pWinInfo.dwStyle AND WS_OVERLAPPED) <> 0) then szTemp := 'WS_OVERLAPPED ';
               if ((pWinInfo.dwStyle AND WS_OVERLAPPEDWINDOW) <> 0) then szTemp := 'WS_OVERLAPPEDWINDOW ';
               if ((pWinInfo.dwStyle AND WS_POPUP) <> 0) then szTemp := 'WS_POPUP ';
               if ((pWinInfo.dwStyle AND WS_POPUPWINDOW) <> 0) then szTemp := 'WS_POPUPWINDOW ';
               if ((pWinInfo.dwStyle AND WS_SIZEBOX) <> 0) then szTemp := 'WS_SIZEBOX ';
               if ((pWinInfo.dwStyle AND WS_VISIBLE) <> 0) then szTemp := 'WS_VISIBLE ';
               if ((pWinInfo.dwStyle AND WS_VSCROLL) <> 0) then szTemp := 'WS_VSCROLL ';

               lblWStyle.Caption := szTemp;
               szTemp := '"None" ';


               { Extended Style }

               lblEWStyle.Caption := IntToHex(pWinInfo.dwExStyle, 8) + ' ';

               { Window Status }
               lblWStatus.Caption := IntToHex(pWinInfo.dwOtherStuff, 8) + ' ';

               { Window borders information }
               lblWBorders.Caption := ' ';

               { Atom Window Type }
               lblWType.Caption := IntToStr(pWinInfo.atomWindowType) + ' ';

               { Creator Version }
               lblCVersion.Caption := IntToStr(pWinINfo.wCreatorVersion) + ' ';
            end;
         end;

      	Application.ProcessMessages;
 		end;
   end;
end;

procedure TfrmMain.imgIconMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if (Button <> mbLeft) then exit;

	{ Set to false, were no longer spying }
	bEnabled := false;

   { Set the cursor back to normal }
	Screen.Cursor := crDefault;

   { Load spy icon }
   imgSpy.Picture.Icon := imgIcon.Picture.Icon;

   { Add array index }
   SetLength(AI, High(AI) + 2);

   { First attempt to spy on a window }
   if (High(AI) = 0) then
   begin
      { Set api info that was just scanned }
      with AI[0] do
      begin
         wHandle := ApiInfo.wHandle;

         if (Length(ApiInfo.wClassN) = 0) then
         begin
         	wClassN := ApiInfo.wClassN;
         end else
         begin
            wClassN := EmptyStr;
         end;

         if (Length(ApiInfo.wText) = 0) then
         begin
         	wText := ApiInfo.wText;
         end else
         begin
         	wText := EmptyStr;
         end;

         pHandle := ApiInfo.pHandle;

         if (Length(ApiInfo.pClassN) = 0) then
         begin
         	pClassN := ApiInfo.pClassN;
         end else
         begin
         	pClassN := EmptyStr;
         end;

         if (Length(ApiInfo.pText) = 0) then
         begin
         	pText := ApiInfo.pText;
         end else
         begin
            pText := EmptyStr;
         end;
      end;
   end else
   begin
   	with AI[High(AI)] do
      begin
         { New scan, set api info that was just scanned }
         wHandle := ApiInfo.wHandle;
         wClassN := ApiInfo.wClassN;
         wText := ApiInfo.wText;
         pHandle := ApiInfo.pHandle;
         pClassN := ApiInfo.pClassN;
         pText := ApiInfo.pText;
      end;
   end;

   lblReports.Caption := 'You currently have [' + IntToStr(High(AI) + 1) + '] api logs reported.';
end;

procedure TfrmMain.LoadSettings();
Label
	ExitFunc;
var
	Reg    : TRegistry;
   szPath : String;
begin
	Reg := TRegistry.Create;

   { Save data under the current user }
   Reg.RootKey := HKEY_CURRENT_USER;

   { if they key doesn't exist, exit }
	szPath := szSubkey + '\Api Spy';

   { Open the key if it exists }
   if (Reg.OpenKey(szPath, false) = true) then
   begin
      { We made it this far, so let's read all the values }
      lblwHandle.Caption := Reg.ReadString('wHandle');
      lblwClass.Caption := Reg.ReadString('wClass');
      lblwText.Caption := Reg.ReadString('wText');
      lblpHandle.Caption := Reg.ReadString('pHandle');
      lblpClass.Caption := Reg.ReadString('pClass');
      lblpText.Caption := Reg.ReadString('pText');
   end;

ExitFunc:

	{ Close key }
	Reg.CloseKey;

   { Free object }
   Reg.Free;
end;

procedure TfrmMain.SaveSettings();
var
	Reg    : TRegistry;
   szPath : String;
begin
	{ Create object }
	Reg := TRegistry.Create;

   { Save data under the current user }
   Reg.RootKey := HKEY_CURRENT_USER;

   try
      { Check to see if the sub key exists }
      if (Reg.OpenKey(szSubkey, false) = false) then
      begin
         { Key doesn't exist, create it }
         Reg.CreateKey(szSubkey);

         { Set api path, create it }
         szPath := szSubkey + '\Api Spy';
         Reg.CreateKey(szPath);
      end else
      begin
         szPath := szSubkey + '\Api Spy';
      end;
   finally
   	{ Close the current key }
   	Reg.CloseKey;
   end;

   { Attempt to open the new path }
   if (Reg.OpenKey(szPath, false) = true) then
   begin
      { Setup default entries }
      Reg.WriteString('wHandle', lblwHandle.Caption);
      Reg.WriteString('wClass', lblwClass.Caption);
      Reg.WriteString('wText', lblwText.Caption);
      Reg.WriteString('pHandle', lblpHandle.Caption);
      Reg.WriteString('pText', lblpText.Caption);
      Reg.WriteString('pClass', lblpClass.Caption);
   end else
   begin
      {
      	Error occurred, someone deleted the
         new path while this code was executing.
      }
      Reg.Free;
      exit;
   end;

   { Destroy object }
   Reg.Free;
end;

end.
