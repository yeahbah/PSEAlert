unit PSEAlert.Frames.StockAlert;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Buttons, ActnList;

type
  TframeStockAlert = class(TFrame)
    lblAlertSymbol: TLabel;
    lblAlertDetails: TLabel;
    lblVolumeAlert: TLabel;
    Bevel1: TBevel;
    btnDelete: TSpeedButton;
    btnAlertTriggered: TSpeedButton;
    BalloonHint1: TBalloonHint;
  private
    { Private declarations }
    actDelete: TAction;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

{ TframeStockAlert }

constructor TframeStockAlert.Create(aOwner: TComponent);
begin
  inherited;
  actDelete := TAction.Create(self);
  btnDelete.Action := actDelete;
end;

end.
