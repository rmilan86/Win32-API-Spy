unit uApiSpy;

interface

uses
	Windows,
   SysUtils,
   Forms;

type
	{ API Information Structure }
	PAPIINFO = ^TAPIINFO;
	TAPIINFO = record

		wHandle : THandle;      // Window Handle
      wClassN : String[255];  // Window ClassName
      wText   : String[255];  // Window Text
      pHandle : THandle;      // Parent Handle
      pClassN : String[255];  // Parent ClassName
      pText   : String[255];  // Parent Text
   end;

   procedure GetApiInfo();

var
   { Stores records }
	 AI       : Array of TAPIINFO;

   { Stores current set of api information }
   ApiInfo  : TAPIInfo;

   { Stores current window information  }
   pWinInfo : TWindowInfo;

   { Last handle that was received }
   hLastWnd : THandle;

implementation

procedure GetApiInfo();
var
	lpPoint   : TPoint;
   hWnd      : THandle;
   WndHandle : THandle;
   lpBuffer  : Array [0..254] of Char;
begin
	{ Get cursor position }
   GetCursorPos(lpPoint);

   // The GetCursorPos() returns the value of the pointer
   // We need to Increment a guestimation to get the center of the icon.
   Inc(lpPoint.X, 5);
   Inc(lpPoint.Y, 7);

   { Get window handle from cursor position }
   hWnd := WindowFromPoint(lpPoint);

   if ((hWnd <> hLastWnd) and (hWnd <> 0)) then
   begin
   	{ Save the window handle }
      hLastWnd := hWnd;
      ApiInfo.wHandle := hWnd;

      { Get the window text }
      FillChar(lpBuffer, 255, #00);
      GetWindowText(hWnd, lpBuffer, 255);
      ApiInfo.wText := lpBuffer;

      { Get the window class name }
      FillChar(lpBuffer, 255, #00);
      GetClassName(hWnd, lpBuffer, 255);
      ApiInfo.wClassN := lpBuffer;

      { Get the handle to the parent window }
      WndHandle := GetParent(hWnd);

      { Make sure we have a handle }
      if (WndHandle <> 0) then
      begin
      	{ Save the parent handle }
         ApiInfo.pHandle := WndHandle;

         { Get the parent class name }
         FillChar(lpBuffer, 255, #00);
         GetClassName(WndHandle, lpBuffer, 255);
         ApiInfo.pClassN := lpBuffer;

         { Get parent window text }
         FillChar(lpBuffer, 255, #00);
         GetWindowText(WndHandle, lpBuffer, 255);
         ApiInfo.pText := lpBuffer;
      end else
      begin
      	ApiInfo.pHandle := 0;
         ApiInfo.pClassN := StringOfChar(#00, 255);
         ApiInfo.pText := StringOfChar(#00, 255);
      end;
	end;

   { Handle Plugins }
end;

end.
