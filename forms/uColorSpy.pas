unit uColorSpy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ImgList;
   
type
  TfrmColorSpy = class(TForm)
    imgIcon: TImage;
    imgList: TImageList;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape1: TShape;
    imgSpy: TImage;
    gbWindowInfo: TGroupBox;
    Label2: TLabel;
    lblRGB: TLabel;
    Label6: TLabel;
    lblLong: TLabel;
    Label7: TLabel;
    lblHTML: TLabel;
    tmrPixel: TTimer;
    bgColor: TShape;
    Label1: TLabel;
    procedure imgSpyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgSpyMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure tmrPixelTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmColorSpy: TfrmColorSpy;
  bEnabled : Boolean;

implementation

{$R *.dfm}

procedure TfrmColorSpy.FormActivate(Sender: TObject);
begin
   { Were not spying }
   bEnabled := false;
end;

procedure TfrmColorSpy.imgSpyMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
	Icon : TIcon;
begin
	if (Button <> mbLeft) then exit;

   { Set to true, were spying }
   tmrPixel.Enabled := true;
	bEnabled := true;
end;

procedure TfrmColorSpy.imgSpyMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
	if (Button <> mbLeft) then exit;

	{ Set to false, were no longer spying }
   tmrPixel.Enabled := false;
	bEnabled := false;
end;

procedure TfrmColorSpy.tmrPixelTimer(Sender: TObject);
   function StrRev(s : String) : String;
   var
      n : Integer;
   begin
      Result := EmptyStr;
      for n  := Length(s) downto 1 do
      begin
         Result := Result + s[n];
      end;
   end;
var
   lpPoint : TPoint;
   wValue  : Cardinal;
   szTemp  : String;
begin
   if (bEnabled = true) then
   begin
      { Get cursor position }
      GetCursorPos(lpPoint);

      { Get the 32bit pixel }
      wValue := GetPixel(GetWindowDC(0), lpPoint.X, lpPoint.Y);
      //BitBlt(Image1.Canvas.Handle, 0, 10, 10, Image1.Canvas.Handle, 0, lpPoint.X, lpPoint.Y, SRCCOPY);

      { Display long value and set color }
      lblLong.Caption := IntToStr(wValue) + ' ';

      if (wValue = $00000000) then
      begin
         Label1.Font.Color := clWhite;
      end else
      begin
         Label1.Font.Color := clBlack;
      end;

      //Shape2.Brush.Color := wValue;

      { Convert long value to rgb format }
      lblRGB.Caption := IntToStr(wValue and $FF) + ',' +
                        IntToStr((wValue shr 8) and $FF) + ',' +
                        IntToStr((wValue shr 16) and $FF) + ' ';

      { Convert long value to html value }
      szTemp := StrRev(IntToHex(wValue, 8));
      lblHTML.Caption := '#' + szTemp + #$20;

      bgColor.Brush.Color := wValue;

      Application.ProcessMessages;
   end;
end;

end.
