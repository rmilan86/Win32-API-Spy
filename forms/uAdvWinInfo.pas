unit uAdvWinInfo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmAdvWinInfo = class(TForm)
    gbParentInfo: TGroupBox;
    Label1: TLabel;
    lblWCoords: TLabel;
    Label2: TLabel;
    lblCCoords: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lblWStyle: TLabel;
    lblEWStyle: TLabel;
    lblWStatus: TLabel;
    lblWBorders: TLabel;
    lblWType: TLabel;
    lblCVersion: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAdvWinInfo: TfrmAdvWinInfo;

implementation

{$R *.dfm}

end.
