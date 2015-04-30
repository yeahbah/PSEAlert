unit PSEAlert.Frames.StockAlert;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ActnList, System.Actions, FMX.Controls.Presentation;

type
  TframeStockAlert = class(TFrame)
    btnDelete: TSpeedButton;
    btnAlertTriggered: TSpeedButton;
    Panel1: TPanel;
    lblAlertSymbol: TLabel;
    lblAlertDetails: TLabel;
    lblVolumeAlert: TLabel;
    Label1: TLabel;
    btnNotes: TSpeedButton;
    lblNote: TLabel;
    Label2: TLabel;
    procedure btnNotesClick(Sender: TObject);
  private
    { Private declarations }
    actDelete: TAction;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.fmx}
{$R PSEAlert.res PSEAlertResource.rc}

{ TframeStockAlert }

procedure TframeStockAlert.btnNotesClick(Sender: TObject);
begin
  lblNote.Visible := not lblNote.Visible;
  if not lblNote.Visible then
    Height := 64
  else
    Height := 113;
end;

constructor TframeStockAlert.Create(aOwner: TComponent);

begin
  inherited Create(aOwner);
  actDelete := TAction.Create(self);
  btnDelete.Action := actDelete;

  lblNote.Text := '';
  lblNote.Visible := false;

end;

end.
