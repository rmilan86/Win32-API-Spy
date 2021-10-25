unit uReportLoad;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls;

type
  TfrmReportsLoad = class(TForm)
    Bevel1: TBevel;
    lblReport: TLabel;
    PBar: TProgressBar;
    lblPercent: TLabel;
    Shape1: TShape;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmReportsLoad: TfrmReportsLoad;

implementation

{$R *.dfm}

procedure TfrmReportsLoad.FormCreate(Sender: TObject);
begin
	Self.Width := Bevel1.Width;
   Self.Height := Bevel1.Height;
end;

end.
