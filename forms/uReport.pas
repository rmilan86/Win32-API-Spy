unit uReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Menus, Buttons, StrUtils, ActnPopup,
  ImgList;

type
  TfrmReports = class(TForm)
    memLog: TMemo;
    lvReport: TListView;
    Splitter1: TSplitter;
    PopupActionBar1: TPopupActionBar;
    Modify1: TMenuItem;
    Delete1: TMenuItem;
    ImageList1: TImageList;
    PopupActionBar2: TPopupActionBar;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Cut1: TMenuItem;
    procedure lvReportResize(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lvReportAdvancedCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
      var DefaultDraw: Boolean);
    procedure lvReportAdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure FormShow(Sender: TObject);
    procedure lvReportClick(Sender: TObject);
    procedure Edit1AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
      ARect: TRect; State: TOwnerDrawState);
    procedure Cut1Click(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvReportKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure Modify1Click(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    function GetCharFromVirtualKey(Key : Word) : String;
  public
    { Public declarations }
  end;

var
  frmReports : TfrmReports;

implementation

uses
	uApiSpy, uGlobals, uReportLoad, uModifyReport;

{$R *.dfm}

function TfrmReports.GetCharFromVirtualKey(Key : Word) : String;
var
   KeyboardState : TKeyboardState;
   AsciiResult   : Integer;
begin
   GetKeyboardState(KeyboardState);

   SetLength(Result, 2) ;
   AsciiResult := ToAscii(Key, MapVirtualKey(Key, 0), KeyboardState, @Result[1], 0) ;
   case AsciiResult of
     0: Result := EmptyStr;
     1: SetLength(Result, 1) ;
     2: { Do noting };
     else
       Result := EmptyStr;
   end;
end;

procedure TfrmReports.Copy1Click(Sender: TObject);
begin
	memLog.CopyToClipboard;
end;

procedure TfrmReports.Cut1Click(Sender: TObject);
begin
	memLog.SelText := '';
end;

procedure TfrmReports.Delete1Click(Sender: TObject);
var
	n          : Integer;
   dwThreadID : DWORD;
begin
	if (lvReport.ItemIndex = -1) then exit;
   Self.Enabled := false;

   SetLength(AI, 0);

   { Tell the user were going to save the settings they have. }
   bReportLoading := true;

   if (lvReport.Items.Count > 0) then
   begin
      with frmReportsLoad do
      begin
      	{ Show update }
         lblReport.Caption := 'Please wait, your report is being saved.';
         lblReport.Alignment := taCenter;
      	lblReport.Width := 291;
         lblReport.Top := 12;

         PBar.Visible := false;
         lblPercent.Visible := false;

         Shape1.Height := lblReport.Height + 22;
         Bevel1.Height := Shape1.Height;
         Height := Shape1.Height;
         Show;

         { Assure the loading form is displayed correctly }
         Application.ProcessMessages;
         for n := 0 to lvReport.Items.Count - 1 do
         begin
         	if (n <> lvReport.Selected.Index) then
            begin
               SetLength(AI, High(AI) + 2);
               with AI[High(AI)] do
               begin
                  wHandle := StrToInt(lvReport.Items.Item[n].SubItems[0]);
                  wClassN := lvReport.Items.Item[n].SubItems[1];
                  wText := lvReport.Items.Item[n].SubItems[2];
                  pHandle := StrToInt(lvReport.Items.Item[n].SubItems[3]);
                  pClassN := lvReport.Items.Item[n].SubItems[4];
                  pText := lvReport.Items.Item[n].SubItems[5];
               end;
            end;
         end;

         { Just wait to make the save form stay up for a little bit }
         if (lvReport.Items.Count < 100) then Sleep(1000);

         AlphaBlendValue := 255;
         AlphaBlend := true;
         for n := 255 downto 0 do
         begin
            AlphaBlendValue := n;
            Sleep(1);
            Application.ProcessMessages;
         end;

         Hide;
         AlphaBlend := false;
      end;
   end;

   lvReport.Selected.Delete();
   Self.Enabled := True;

   bReportLoading := false;
end;

procedure TfrmReports.Edit1AdvancedDrawItem(Sender: TObject; ACanvas: TCanvas;
  ARect: TRect; State: TOwnerDrawState);
begin
	Canvas.Font.Color := clGreen;
end;

procedure TfrmReports.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
	Self.Hide;
end;

procedure TfrmReports.FormCreate(Sender: TObject);
begin
	Splitter1.MinSize := 50;
end;

procedure TfrmReports.FormHide(Sender: TObject);
var
	n          : Integer;
   dwThreadID : DWORD;
begin

   SetLength(AI, 0);
   { Tell the user were going to save the settings they have. }
   bReportLoading := true;

   ShowWindow(Handle, SW_HIDE);
   if (lvReport.Items.Count > 0) then
   begin
      with frmReportsLoad do
      begin
      	{ Show update }
         lblReport.Caption := 'Please wait, your report is being saved.';
         lblReport.Alignment := taCenter;
      	lblReport.Width := 291;
         lblReport.Top := 12;

         PBar.Visible := false;
         lblPercent.Visible := false;

         Shape1.Height := lblReport.Height + 22;
         Bevel1.Height := Shape1.Height;
         Height := Shape1.Height;
         Show;

         { Assure the loading form is displayed correctly }
         Application.ProcessMessages;
         for n := 0 to lvReport.Items.Count - 1 do
         begin
         	SetLength(AI, High(AI) + 2);
            with AI[High(AI)] do
            begin
            	wHandle := StrToInt(lvReport.Items.Item[n].SubItems[0]);
               wClassN := lvReport.Items.Item[n].SubItems[1];
               wText := lvReport.Items.Item[n].SubItems[2];
               pHandle := StrToInt(lvReport.Items.Item[n].SubItems[3]);
               pClassN := lvReport.Items.Item[n].SubItems[4];
               pText := lvReport.Items.Item[n].SubItems[5];
            end;
         end;

         if (High(AI) <> -1) then
         begin
            SaveAPIInfo();
         end;

         { Clear Listview }
         lvReport.Items.Clear;

         { Just wait to make the save form stay up for a little bit }
         if (lvReport.Items.Count < 100) then Sleep(1000);

         AlphaBlendValue := 255;
         AlphaBlend := true;
         for n := 255 downto 0 do
         begin
            AlphaBlendValue := n;
            Sleep(1);
            Application.ProcessMessages;
         end;

         Hide;
         AlphaBlend := false;
      end;
   end;
   
   bReportLoading := false;
end;

procedure TfrmReports.FormShow(Sender: TObject);
var
	n        : Integer;
   ListItem : TListItem;
begin
   if (High(AI) <> -1) then
   begin
      if (High(AI) > 500) then
      begin
         bReportLoading := true;

         { Reset report loading form }
      	frmReportsLoad.lblReport.Alignment := taLeftJustify;
         frmReportsLoad.lblReport.Width := 265;
         frmReportsLoad.lblReport.Top := 16;

      	frmReportsLoad.PBar.Visible := true;
      	frmReportsLoad.lblPercent.Visible := true;

      	frmReportsLoad.Shape1.Height := 65;
      	frmReportsLoad.Bevel1.Height := frmReportsLoad.Shape1.Height;
      	frmReportsLoad.Height := frmReportsLoad.Shape1.Height;

         frmReportsLoad.lblReport.Caption := 'Please wait, your report is being generated.';
         frmReportsLoad.PBar.Min := Low(AI);
         frmReportsLoad.PBar.Max := High(AI) - 1;
         frmReportsLoad.Show;
      end else
      begin
         Self.Visible := true;
      end;


      for n := Low(AI) to High(AI) do
      begin
         ListItem := lvReport.Items.Add();
         ListItem.Caption := IntToStr(n + 1);

         with AI[n] do
         begin
            { Window Information }
            ListItem.SubItems.Add(IntToStr(wHandle));

            if (TrimNull(wClassN) <> EmptyStr) then
            begin
               ListItem.SubItems.Add(wClassN);
            end else
            begin
               ListItem.SubItems.Add('None');
            end;

            if (TrimNull(wText) <> EmptyStr) then
            begin
               ListItem.SubItems.Add(wText);
            end else
            begin
               ListItem.SubItems.Add('None');
            end;

            { Parent Information }
            ListItem.SubItems.Add(IntToStr(pHandle));

            if (TrimNull(pClassN) <> EmptyStr) then
            begin
               ListItem.SubItems.Add(pClassN);
            end else
            begin
               ListItem.SubItems.Add('None');
            end;

            if (TrimNull(pText) <> EmptyStr) then
            begin
               ListItem.SubItems.Add(pText);
            end else
            begin
               ListItem.SubItems.Add('None');
            end;
         end;

         if (High(AI) > 500) then
         begin
            with frmReportsLoad do
            begin
               PBar.Position := n;
               lblPercent.Caption := GetPercentage(n, PBar.Max);

               if (GetPercentage(n, PBar.Max) = '100%') then
               begin
                  frmReportsLoad.Hide;
                  Self.AlphaBlend := false;
                  break;
               end;
            end;
         end;

         Application.ProcessMessages;
      end;
   end;

   frmReportsLoad.Hide;
   bReportLoading := false;
end;

procedure TfrmReports.lvReportAdvancedCustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; Stage: TCustomDrawStage;
  var DefaultDraw: Boolean);
begin
	lvReport.Canvas.Font.Color := $00D54600;
   //lvReport.Canvas.Font.Style := [fsBold];
end;

procedure TfrmReports.lvReportAdvancedCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
begin
	case SubItem of
      1: lvReport.Canvas.Font.Color := clGreen;
      2: lvReport.Canvas.Font.Color := $00D54600; { Light blue }
      3: lvReport.Canvas.Font.Color := clGreen;
      4: lvReport.Canvas.Font.Color := $00D54600; { Light blue }
      5: lvReport.Canvas.Font.Color := clGreen;
      6: lvReport.Canvas.Font.Color := $00D54600; { Light blue }
   end;
end;

procedure TfrmReports.lvReportClick(Sender: TObject);
var
	szEntryN  : String;

   szWHandle : String;
   szWClassN : String;
   szWText   : String;

   szPHandle : String;
	szPClassN : String;
   szPText   : String;

   nSpacer   : Integer;
begin
	if (lvReport.ItemIndex = -1) then exit;

   szEntryN := lvReport.Selected.Caption;

   szWHandle := lvReport.Selected.SubItems[0];
   szWClassN := lvReport.Selected.SubItems[1];
   szWText := lvReport.Selected.SubItems[2];

   szPHandle := lvReport.Selected.SubItems[3];
   szPClassN := lvReport.Selected.SubItems[4];
   szPText := lvReport.Selected.SubItems[5];

   memLog.Lines.BeginUpdate;
   memLog.Lines.Clear;
   with memLog.Lines do
   begin
   	Add('+------------------------------------------------------------------------------------------+');

      if (Length(szEntryN) = 1) then
      begin
      	Add('|                                API Log Record Entry #' + szEntryN + '                                   |');
      end else
      if (Length(szEntryN) = 2) then
      begin
      	Add('|                                API Log Record Entry #' + szEntryN + '                                  |');
      end else
      if (Length(szEntryN) = 3) then
      begin
      	Add('|                                API Log Record Entry #' + szEntryN + '                                 |');
      end else
      if (Length(szEntryN) = 4) then
      begin
      	Add('|                                API Log Record Entry #' + szEntryN + '                                |');
      end;
      Add('+------------------------------------------------------------------------------------------+');
      Add('| Window Handle : ' + szWHandle + StringOfChar(' ', 73 - Length(szWHandle)) + '|');
      Add('| Window Class  : ' + szWClassN + StringOfChar(' ', 73 - Length(szWClassN)) + '|');
      Add('| Window Text   : ' + szWText + StringOfChar(' ', 73 - Length(szWText)) + '|');
      Add('| Parent Handle : ' + szPHandle + StringOfChar(' ', 73 - Length(szPHandle)) + '|');
      Add('| Parent Class  : ' + szPClassN + StringOfChar(' ', 73 - Length(szPClassN)) + '|');
      Add('| Parent Text   : ' + szPText + StringOfChar(' ', 73 - Length(szPText)) + '|');
      Add('+------------------------------------------------------------------------------------------+');
      Add('|                         Generated by MTechMedia Win32 API Spy                            |');
   	Add('+------------------------------------------------------------------------------------------+');
   end;

   memLog.Lines.EndUpdate;
end;

procedure TfrmReports.lvReportKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
	if ((Key = VK_UP) or (Key = VK_DOWN)) then
   begin
   	lvReportClick(Sender);
   	Sleep(50);
   end;
end;

procedure TfrmReports.lvReportResize(Sender: TObject);
begin

	lvReport.Columns[0].Width := 50;
   lvReport.Columns[1].Width := 70;
	lvReport.Columns[2].Width := 120;
   lvReport.Columns[3].Width := 120;
   lvReport.Columns[4].Width := 70;
   lvReport.Columns[5].Width := 120;
   lvReport.Columns[6].Width := 120;
end;

procedure TfrmReports.Modify1Click(Sender: TObject);
begin
	if (lvReport.ItemIndex <> -1) then
   begin
   	Self.Enabled := False;
      with frmModifyReport do
      begin
      	Tag := lvReport.Selected.Index;
         Caption := 'Modify Report #' + lvReport.Selected.Caption;
         txtWHandle.Text := lvReport.Selected.SubItems[0];
         txtWClassN.Text := lvReport.Selected.SubItems[1];
         txtWText.Text := lvReport.Selected.SubItems[2];
         txtPHandle.Text := lvReport.Selected.SubItems[3];
         txtPClassN.Text := lvReport.Selected.SubItems[4];
         txtPText.Text := lvReport.Selected.SubItems[5];
         Show;
      end;
   end;
end;

procedure TfrmReports.Paste1Click(Sender: TObject);
begin
	memLog.PasteFromClipboard;
end;

procedure TfrmReports.Splitter1Moved(Sender: TObject);
begin
   UpdateWindow(lvReport.Handle);
   UpdateWindow(memLog.Handle);
end;

end.
