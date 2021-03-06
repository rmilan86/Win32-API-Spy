unit uPreferences;

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
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  ShlObj;

type
  TfrmPreferences = class(TForm)
    tcOptions: TTabControl;
    cmdApply: TButton;
    lblSavePath: TLabel;
    txtSavePath: TEdit;
    Bevel1: TBevel;
    lblSaveLimit: TLabel;
    txtSaveLimit: TEdit;
    udSaveLimit: TUpDown;
    chkSaveLimit: TCheckBox;
    imgBrowse: TImage;
    Bevel2: TBevel;
    chkSaveRecords: TCheckBox;
    chkLoadSavedRecords: TCheckBox;
    lblCodeGen: TLabel;
    lstCGPlugins: TListBox;
    cmdCGAdd: TButton;
    cmdCGRemove: TButton;
    cmdCGClear: TButton;
    procedure imgBrowseMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgBrowseMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgBrowseMouseEnter(Sender: TObject);
    procedure imgBrowseMouseLeave(Sender: TObject);
    procedure imgBrowseClick(Sender: TObject);
    procedure udSaveLimitClick(Sender: TObject; Button: TUDBtnType);
    procedure txtSaveLimitChange(Sender: TObject);
    procedure txtSaveLimitMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure txtSaveLimitContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure chkSaveLimitClick(Sender: TObject);
    procedure txtSavePathChange(Sender: TObject);
    procedure chkLoadSavedRecordsClick(Sender: TObject);
    procedure chkSaveRecordsClick(Sender: TObject);
    procedure cmdCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tcOptionsChange(Sender: TObject);
    procedure cmdCGClearClick(Sender: TObject);
    procedure cmdCGAddClick(Sender: TObject);
  private
    { Private declarations }
    procedure BrowseForFolder();
    function  IsNumeric(s : String) : Boolean;
    procedure SetStartup();
    procedure DisplayTab(Index : Integer; Visible : Boolean);
    procedure GetPlugins();
  public
    { Public declarations }
  end;
  
  procedure FreePIDL(PIDL : PITEMIDLIST); stdcall;

var
  frmPreferences : TfrmPreferences;
  
implementation

uses
	uGlobals;

{$R *.dfm}

{ External Procedure }
procedure FreePIDL; external 'Shell32.dll' index 155;

function BrowseCallback(hWnd : THandle; msg : UINT; Param : DWORD; Param2 : DWORD) : Integer stdcall;
var
	pIIDList : PITEMIDLIST;
	chName   : Array [0..MAX_PATH] of Char;
begin
	pIIDList := Pointer(Param);
   if (Assigned(pIIDList)) then
   begin
   	SHGetPathFromIDList(pIIDList, chName);
   end;

   Result := 0;
end;

procedure TfrmPreferences.BrowseForFolder();
var
	BrowseInfo : TBrowseInfo;
   lpIIDList  : PITEMIDLIST;
   chDispName : Array [0..260] of Char;
begin
	BrowseInfo.hwndOwner := Handle;
   BrowseInfo.pidlRoot := NIL;
   BrowseInfo.pszDisplayName := @chDispName[0];
   BrowseInfo.lpszTitle := 'Select a Directory';
   BrowseInfo.ulFlags := BIF_RETURNONLYFSDIRS;
   BrowseInfo.lpfn := @BrowseCallback;
   BrowseInfo.lParam := 0;
   BrowseInfo.iImage := 0;

   { Create object }
   lpIIDList := SHBrowseForFolder(BrowseInfo);
   try
   	if (SHGetPathFromIDList(lpIIDList, chDispName)) then
      begin
         if (DirectoryExists(chDispName) = true) then
         begin
            txtSavePath.Text := chDispName;
         end;
      end;
   finally
   	FreePIDL(lpIIDList);
   end;
end;

procedure TfrmPreferences.chkLoadSavedRecordsClick(Sender: TObject);
begin
   cmdApply.Enabled := true;
end;

procedure TfrmPreferences.chkSaveLimitClick(Sender: TObject);
begin
	cmdApply.Enabled := true;
	case Integer(chkSaveLimit.Checked) of
   	0: { False }
      begin
      	lblSaveLimit.Enabled := False;
         txtSaveLimit.Enabled := False;
         udSaveLimit.Enabled := False;
      end;

      1: { True }
      begin
      	lblSaveLimit.Enabled := True;
         txtSaveLimit.Enabled := True;
         udSaveLimit.Enabled := True;
      end;
   end;
end;

procedure TfrmPreferences.chkSaveRecordsClick(Sender: TObject);
begin
	cmdApply.Enabled := true;
end;

procedure TfrmPreferences.cmdCancelClick(Sender: TObject);
begin
	Self.Close;
end;

procedure TfrmPreferences.cmdCGAddClick(Sender: TObject);
var
   szTemp  : String;
	ODialog : TOpenDialog;
begin
	ODialog := TOpenDialog.Create(Self);
   ODialog.Filter := 'Code Generator Plugin (.CG)|*.cg';
   ODialog.Title := 'Select A Plugin';
   ODialog.Execute(0);

   if (Length(ODialog.FileName) = 0) then
   begin
   	MessageBox(0,
                 PAnsiChar('No plugin was added.'),
                 PAnsiChar(Application.Title),
                 $00000040);
      ODialog.Destroy;
      exit;
   end;

   { Check if file is a valid code generator. plugin }
   szTemp := LowerCase(ODialog.FileName);
   if (ExtractFileExt(szTemp) = '.cg') then
   begin
      szTemp := ExtractFileName(ODialog.FileName);
      szTemp := Copy(szTemp, 1, Length(szTemp) - 3);
      lstCGPlugins.Items.Add(szTemp);
   end;
end;

procedure TfrmPreferences.cmdCGClearClick(Sender: TObject);
var
	n   : Integer;
   Dir : String;
begin
	Dir := GetCurrentDir() + '\PLUGINS_BETA';
	if (MessageBox(0,
               	PAnsiChar('This will phsyically delete all code generator plugins.' + #13#10 +
                            'Would you like to proceed?'),
                  PAnsiChar('Clear Plugins?'),
                  $00000034) = ID_YES) then
   begin
   	if (DirectoryExists(Dir) = True) then
      begin

      	if (DirectoryExists(Dir + '\CG') = True) then
         begin

            for n := 0 to lstCGPlugins.Items.Count - 1 do
            begin
            	if (FileExists(Dir + '\CG\' + lstCGPlugins.Items.Strings[n]) = True) then
               begin
               	DeleteFile(Dir + '\CG\' + lstCGPlugins.Items.Strings[n]);
               end;
            end;

         end;

      end;

      lstCGPlugins.Items.Clear;

      { Refresh plugins list }
      GetPlugins();
   end;
end;

procedure TfrmPreferences.DisplayTab(Index : Integer; Visible : Boolean);
begin
	case Index of
   	0: { General }
      begin
      	lblSavePath.Visible := Visible;
         txtSavePath.Visible := Visible;
         Bevel1.Visible := Visible;
         imgBrowse.Visible := Visible;
         lblSaveLimit.Visible := Visible;
         txtSaveLimit.Visible := Visible;
         udSaveLimit.Visible := Visible;
         chkSaveLimit.Visible := Visible;
         chkSaveRecords.Visible := Visible;
         chkLoadSavedRecords.Visible := Visible;
         Bevel2.Visible := Visible;
      end;

      1: { Code Generator }
      begin
      	lblCodeGen.Visible := Visible;
         lstCGPlugins.Visible := Visible;
         cmdCGAdd.Visible := Visible;
         cmdCGRemove.Visible := Visible;
         cmdCGClear.Visible := Visible;
      end;

      2: { Plugins }
      begin
       ////////////////
      end;
   end;
end;

procedure TfrmPreferences.FormCreate(Sender: TObject);
begin
	SetStartup();
   GetPlugins();

   DisplayTab(0, True);
   DisplayTab(1, False);
   DisplayTab(2, False);
end;

procedure TfrmPreferences.FormShow(Sender: TObject);
begin
	LoadPrefSettings();
end;

procedure TfrmPreferences.GetPlugins;
var
   F   : TSearchRec;

	n   : Integer;
   Dir : String;
begin
   
	Dir := GetCurrentDir() + '\PLUGINS_BETA';
   if (DirectoryExists(Dir) = True) then
   begin
      if (DirectoryExists(Dir + '\CG') = True) then
      begin
         Dir := Dir + '\CG\';

         //////////////////////////////////////////////////////////////////////////////
         ///// DIRECTORY SEARCH ///////////////////////////////////////////////////////
         //////////////////////////////////////////////////////////////////////////////
         if (FindFirst(Dir + '*', faAnyFile, F) = 0) then
         begin
            repeat
               if ((F.Name <> '.') and (F.Name <> '..')) then lstCGPlugins.Items.Add(F.Name);
            until (FindNext(F) <> 0);
         end;

         FindClose(F);
         //////////////////////////////////////////////////////////////////////////////
      end;
   end else
   begin
      MessageBox(Self.Handle,
                 PAnsiChar('The directory "PLUGINS_BETA" is missing!'),
                 PAnsiChar('ERROR!'),
                 $00000010);
   end;
end;

procedure TfrmPreferences.imgBrowseClick(Sender: TObject);
begin
	BrowseForFolder();
   cmdApply.Enabled := True;
end;

procedure TfrmPreferences.imgBrowseMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	Bevel1.Style := bsLowered;
end;

procedure TfrmPreferences.imgBrowseMouseEnter(Sender: TObject);
begin
	Bevel1.Shape := bsBox;
end;

procedure TfrmPreferences.imgBrowseMouseLeave(Sender: TObject);
begin
	Bevel1.Shape := bsSpacer;
end;

procedure TfrmPreferences.imgBrowseMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	Bevel1.Style := bsRaised;
end;

function TfrmPreferences.IsNumeric(s: String): Boolean;
var
	n : Integer;
begin
	Result := True;
	for n := 1 to Length(s) do
   begin
      if not (s[n] in [#48..#57]) then
      begin
         Result := False;
         break;
      end;
   end;
end;

procedure TfrmPreferences.SetStartup;
begin
	{ General Tab Settings }
   { -------------------- }
	with lblSavePath do
   begin
   	Left := 11;
     	Top := 39;
	end;

   with txtSavePath do
   begin
      Left := 66;
      Top := 36;
   end;

   with Bevel1 do
   begin
      Left := 439;
      Top := 36;
   end;

   with imgBrowse do
   begin
      Left := 443;
      Top := 38;
      Visible := True;
   end;

   with lblSaveLimit do
   begin
     	Left := 66;
     	Top := 66;
   end;

   with txtSaveLimit do
   begin
      Left := 168;
      Top := 63;
   end;

   with udSaveLimit do
   begin
      Left := 201;
      Top := 62;
   end;

   with chkSaveLimit do
   begin
      Left := 272;
      Top := 68;
   end;

   with chkSaveRecords do
   begin
      Left := 65;
      Top := 100;
   end;

   with chkLoadSavedRecords do
   begin
     Left := 272;
     Top := 100;
   end;

	with Bevel2 do
   begin
  		Left := 66;
  		Top := 91;
	end;

   { Code Generator }
   with lblCodeGen do
   begin
      Left := 10;
      Top := 40;
   end;

   with lstCGPlugins do
   begin
     Left := 10;
     Top := 59;
   end;

   with cmdCGClear do
   begin
     Left := 227;
     Top := 159;
   end;

   with cmdCGRemove do
   begin
     Left := 308;
     Top := 159;
   end;

   with cmdCGAdd do
   begin
     Left := 389;
     Top := 159;
   end;


   { Plugins }
end;

procedure TfrmPreferences.tcOptionsChange(Sender: TObject);
begin
	case tcOptions.TabIndex of
   	0:
      begin
      	cmdApply.Visible := True;
      	DisplayTab(0, True);
         DisplayTab(1, False);
         DisplayTab(2, False);
      end;
      1:
      begin
      	cmdApply.Visible := False;
      	DisplayTab(0, False);
         DisplayTab(1, True);
         DisplayTab(2, False);
      end;
      2:
      begin
      	cmdApply.Visible := False;
      	DisplayTab(0, False);
         DisplayTab(1, False);
         DisplayTab(2, True);
      end;
   end;
end;

procedure TfrmPreferences.txtSaveLimitChange(Sender: TObject);
begin
	if (IsNumeric(txtSaveLimit.Text) = false) then txtSaveLimit.Text := IntToStr(udSaveLimit.Position);
	if (StrToInt(txtSaveLimit.Text) > 9999) then txtSaveLimit.Text := '9999';
   if (StrToInt(txtSaveLimit.Text) < 100) then txtSaveLimit.Text := '100';
	udSaveLimit.Position := StrToInt(txtSaveLimit.Text);
   cmdApply.Enabled := true;
end;

procedure TfrmPreferences.txtSaveLimitContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
	Handled := True;
end;

procedure TfrmPreferences.txtSaveLimitMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	s : String;
begin
	if (Button = mbRight) then
   begin
      s := InputBox('Set Save Limit', 'Enter a limit from 100 to 9999', IntToStr(udSaveLimit.Position));
      if ((Length(s) > 0) and (IsNumeric(s) = true)) then
      begin
         if ((StrToInt(s) >= 100) and (StrToInt(s) <= 9999)) then
         begin
            txtSaveLimit.Text := s;
         end;
      end;
   end;
end;
procedure TfrmPreferences.txtSavePathChange(Sender: TObject);
begin
	cmdApply.Enabled := true;
end;

procedure TfrmPreferences.udSaveLimitClick(Sender: TObject; Button: TUDBtnType);
begin
	txtSaveLimit.Text := IntToStr(udSaveLimit.Position);
end;

end.
