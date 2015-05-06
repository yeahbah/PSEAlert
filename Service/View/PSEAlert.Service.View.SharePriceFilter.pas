unit PSEAlert.Service.View.SharePriceFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls, System.Actions, Vcl.ActnList;

type
  TframeSharePriceFilter = class(TFrame)
    Panel1: TPanel;
    Label3: TLabel;
    Label2: TLabel;
    lblFilterDescription: TLabel;
    btnClose: TSpeedButton;
    edtFromPrice: TEdit;
    edtToPrice: TEdit;
    ActionList1: TActionList;
    actClose: TAction;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
