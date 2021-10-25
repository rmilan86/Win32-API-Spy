unit uCodeGen;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList;


const
	crMyCursor = 1; // Custom Cursor

type
  TfrmCodeGen = class(TForm)
    imgIcon: TImage;
    imgList: TImageList;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Shape1: TShape;
    imgSpy: TImage;
    ComboBox1: TComboBox;
    txtCode: TMemo;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure imgSpyMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgSpyMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgSpyMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    //procedure GenerateCode();
  public
    { Public declarations }
  end;

var
   frmCodeGen: TfrmCodeGen;
   bEnabled : Boolean;

implementation

uses
   uApiSpy;

{$R *.dfm}

procedure TfrmCodeGen.FormCreate(Sender: TObject);
begin
	Screen.Cursors[crMyCursor] := LoadCursor(HInstance, 'SPYCUR');

   { Were not spying }
   bEnabled := false;

   { Load spy icon }
   imgSpy.Picture.Icon := imgIcon.Picture.Icon;
end;

procedure TfrmCodeGen.imgSpyMouseDown(Sender: TObject; Button: TMouseButton;
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

   { Clear the code list }
   txtCode.Lines.Clear;
end;

procedure TfrmCodeGen.imgSpyMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
	if (bEnabled = true) then
   begin
   	GetApiInfo();
   end;
end;

procedure TfrmCodeGen.imgSpyMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
   procedure Add(s : String);
   begin
      txtCode.Lines.Add(s);
   end;
begin
	if (Button <> mbLeft) then exit;

	{ Set to false, were no longer spying }
	bEnabled := false;

   { Set the cursor back to normal }
	Screen.Cursor := crDefault;

   { Load spy icon }
   imgSpy.Picture.Icon := imgIcon.Picture.Icon;

   { Format data for display }
   with ApiInfo do
   begin
      { Window Handle }
      Add('Window Handle: ' + IntToStr(wHandle) + ' ');

      if (wHandle <> 0) then
      begin
         { Check and fix length for window classname }
         if (Length(wClassN) <> 0) then
         begin
            if (Length(wClassN) > 24) then
            begin
               Add('Window ClassName: ' + Copy(wClassN, 1, 24) + '...');
            end else
            begin
               Add('Window ClassName: ' + wClassN + ' ');
            end;
         end else
         begin
            Add('Window ClassName: N/A');
         end;

         { Check and fix length for window text }
         if (Length(wText) <> 0) then
         begin
            if (Length(wText) > 24) then
            begin
               Add('Windows Text: ' + Copy(wText, 1, 22) + '...');
            end else
            begin
              Add('Windows Text: ' + wText);
            end;
         end else
         begin
            Add('Windows Text: N/A');
         end;
         ///////////////////////////////////////////
         Add('');
         ///////////////////////////////////////////

         { Parent Handle }
         Add('Parent Handle: ' + IntToStr(pHandle));

         if (pHandle <> 0) then
         begin
            { Check and fix length for parent classname }
            if (Length(pClassN) <> 0) then
            begin
               if (Length(pClassN) > 24) then
               begin
                  Add('Parent ClassName: ' + Copy(pClassN, 1, 24) + '...');
               end else
               begin
                  Add('Parent ClassName: ' +  pClassN);
               end;
            end else
            begin
               Add('Parent ClassName: No classname was found.');
            end;

            { Check and fix length for parent text }
            if (Length(pText) <> 0) then
            begin
               if (Length(pText) > 24) then
               begin
                  Add('Parent Text: ' + Copy(pText, 1, 22) + '...');
               end else
               begin
                  Add('Parent Text: ' + pText)
               end;
            end else
            begin
               Add('Parent Text: No text was found.');
            end;
         end else
         begin
            Add('Parent Handle: 0');
            Add('Parent Class: N/A');
            Add('Parent Text: N/A');
         end;
      end else
      begin
         Add('Window Handle: 0');
         Add('Window Class: N/A');
         Add('Window Text: N/A');
         Add('');
         Add('Parent Handle: 0');
         Add('Parent Class: N/A');
         Add('Parent Text: N/A');
      end;
   end;
end;

end.
