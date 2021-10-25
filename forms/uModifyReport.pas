unit uModifyReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, uGlobals;

type
  TfrmModifyReport = class(TForm)
    txtWHandle: TLabeledEdit;
    txtWClassN: TLabeledEdit;
    txtWText: TLabeledEdit;
    txtPHandle: TLabeledEdit;
    txtPClassN: TLabeledEdit;
    txtPText: TLabeledEdit;
    cmdApply: TButton;
    procedure cmdCancelClick(Sender: TObject);
    procedure cmdApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    function IsNumeric(s : String) : Boolean;
  public
    { Public declarations }
  end;

var
  frmModifyReport: TfrmModifyReport;

implementation

uses uReport;

{$R *.dfm}

procedure TfrmModifyReport.cmdApplyClick(Sender: TObject);
var
	Index : Integer;
begin
	Index := Self.Tag;

	if (IsNumeric(txtWHandle.Text) = false) then
   begin
      MessageBox(0,
            	  PAnsiChar('The "Window Handle" entry has non-numeric values in it.'),
                 PAnsiChar('Unable to save modifications'),
                 MB_ICONEXCLAMATION);
      exit;
   end;

	if (IsNumeric(txtPHandle.Text) = false) then
   begin
      MessageBox(0,
            	  PAnsiChar('The "Parent Handle" entry has non-numeric values in it.'),
                 PAnsiChar('Unable to save modifications'),
                 MB_ICONEXCLAMATION);
      exit;
   end;

   with frmReports.lvReport.Items.Item[Index] do
   begin
   	SubItems[0] := txtWHandle.Text;
      SubItems[1] := txtWClassN.Text;
      SubItems[2] := txtWText.Text;
      SubItems[3] := txtPHandle.Text;
      SubItems[4] := txtPClassN.Text;
      SubItems[5] := txtPText.Text;
   end;

   frmReports.lvReport.ItemIndex := Index;
   frmReports.lvReportClick(Sender);
   Self.Close;
end;

procedure TfrmModifyReport.cmdCancelClick(Sender: TObject);
begin
	Self.Close;
end;

procedure TfrmModifyReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
	frmReports.Enabled := True;
end;

procedure TfrmModifyReport.FormHide(Sender: TObject);
begin
	bReportLoading := False;
end;

procedure TfrmModifyReport.FormShow(Sender: TObject);
begin
	bReportLoading := True;
end;

function TfrmModifyReport.IsNumeric(s: String): Boolean;
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

end.
