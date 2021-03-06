unit uGlobals;

interface

uses
	Windows,
   Messages,
   SysUtils,
   Forms,
   Registry,
   uApiSpy;

type
	PSavedSettings = ^TSavedSettings;
	TSavedSettings = record
      SavePath    : String;
      SaveLimit   : Integer;
      EnableLimit : Boolean;

      SaveRecords : Boolean;
      LoadRecords : Boolean;
   end;

  	procedure LoadAPIInfo();
  	procedure SaveAPIInfo();
   procedure LoadPrefSettings();
   procedure SavePrefSettings();

   function  TrimNull(s : String) : String;
   procedure HideFromTaskbar(Handle : HWND; Value: Boolean);
   function  GetPercentage(Val1 : Integer; Val2 : Integer) : String;

var
	bReportLoading : Boolean;
   SavedSettings  : TSavedSettings;
implementation

procedure LoadAPIInfo();
var
	F        : File of TAPIINFO;
   AIRecord : TAPIINFO;
begin
   FileMode := fmOpenRead;
	AssignFile(F, GetCurrentDir() + '\AI.dat');
   Reset(F);

   try
   	while not (EOF(F)) do
      begin
         Read(F, AIRecord);
         SetLength(AI, High(AI) + 2);
         AI[High(AI)] := AIRecord;
      end;
   finally
   	CloseFile(F);
   end;
end;

procedure SaveAPIInfo();
var
	n : Integer;
	F : File of TAPIINFO;
begin
	AssignFile(F, GetCurrentDir() + '\AI.dat');
   ReWrite(F);

   try
   	for n := Low(AI) to High(AI) do
      begin
         Write(F, AI[n]);
      end;
   finally
   	CloseFile(F);
   end;
end;

procedure LoadPrefSettings();
const
	szSubkey = 'Software\MTechMedia';
var
	Reg : TRegistry;
begin
	Reg := TRegistry.Create();
   Reg.RootKey := HKEY_CURRENT_USER;

	try
 		if (Reg.OpenKey(szSubkey, False) = True) then
      begin
         Reg.CloseKey;
         if (Reg.OpenKey(szSubkey + '\Api Spy', False) = True) then
         begin
         	{ Read saved path }
         	if (Reg.ValueExists('Save Path') = True) then
            begin
            	SavedSettings.SavePath := Reg.ReadString('Save Path');
            end else
            begin
            	SavedSettings.SavePath := GetCurrentDir();
            end;

            { Read save limit }
         	if (Reg.ValueExists('Save Limit') = True) then
            begin
            	SavedSettings.SaveLimit := Reg.ReadInteger('Save Limit');
            end else
            begin
            	SavedSettings.SaveLimit := 1000;
            end;

         	if (Reg.ValueExists('Enable Save Limit') = True) then
            begin
            	SavedSettings.EnableLimit := Reg.ReadBool('Enable Save Limit');
            end else
            begin
            	SavedSettings.EnableLimit := True;
            end;

         	if (Reg.ValueExists('Save Records') = True) then
            begin
            	SavedSettings.SaveRecords := Reg.ReadBool('Save Records');
            end else
            begin
            	SavedSettings.SaveRecords := True;
            end;

         	if (Reg.ValueExists('Load Records') = True) then
            begin
            	SavedSettings.LoadRecords := Reg.ReadBool('Load Settings');
            end else
            begin
            	SavedSettings.LoadRecords := True;
            end;

            { ... }

         end else
         begin
            SavedSettings.SavePath := GetCurrentDir;
            SavedSettings.SaveLimit := 1000;
            SavedSettings.EnableLimit := True;
            SavedSettings.SaveRecords := True;
            SavedSettings.LoadRecords := True;
         end;
      end else
      begin
         SavedSettings.SavePath := GetCurrentDir;
         SavedSettings.SaveLimit := 1000;
         SavedSettings.EnableLimit := True;
         SavedSettings.SaveRecords := True;
         SavedSettings.LoadRecords := True;
      end;
   finally
   	Reg.CloseKey();
   	Reg.Destroy();
   end;
end;

procedure SavePrefSettings();
const
	szSubkey = 'Software\MTechMedia';
var
	Reg : TRegistry;
begin
	Reg := TRegistry.Create();
   Reg.RootKey := HKEY_CURRENT_USER;

	try
 		if (Reg.OpenKey(szSubkey, True) = True) then
      begin
         Reg.CloseKey;
         if (Reg.OpenKey(szSubkey + '\Api Spy', True)) then
         begin
         	Reg.WriteString('Save Path', SavedSettings.SavePath);
            Reg.WriteInteger('Save Limit', SavedSettings.SaveLimit);
            Reg.WriteBool('Enable Save Limit', SavedSettings.EnableLimit);
            Reg.WriteBool('Save Records', SavedSettings.SaveRecords);
            Reg.WriteBool('Load Records', SavedSettings.LoadRecords);
      	end;
      end;
   finally
   	Reg.CloseKey();
   	Reg.Destroy();
   end;
end;

function TrimNull(s : String) : String;
begin
	if (Pos(#00, s) > 0) then
   begin
   	Result := Copy(s, 1, Pos(#00, s) - 1);
   end else
   begin
      Result := s;
   end;
end;

procedure HideFromTaskbar(Handle : HWND; Value: Boolean);
var
   Style  : Integer;
begin
   ShowWindow(Handle, SW_HIDE);

   Style := GetWindowLong(Handle, GWL_EXSTYLE);
   if (Value = true) then
   begin
      SetWindowLong(Handle, GWL_EXSTYLE, Style and not WS_EX_APPWINDOW);
   end else
   begin
      SetWindowLong(Handle, GWL_EXSTYLE, Style or WS_EX_APPWINDOW);
   end;

   ShowWindow(Handle, SW_SHOW);
end;

function GetPercentage(Val1 : Integer; Val2 : Integer) : String;
var
	dFloat  : Double;
   szFloat : String;
begin
   dFloat := ((Val1 / Val2) * 100);
   szFloat := FloatToStr(dFloat);

   if (Pos('.', szFloat) > 0) then
   begin
   	Result := Copy(szFloat, 1, Pos('.', szFloat) - 1) + '%';
   end else
   begin
      Result := szFloat + '%';
   end;
end;

end.
