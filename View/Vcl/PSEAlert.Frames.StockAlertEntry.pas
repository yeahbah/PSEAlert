unit PSEAlert.Frames.StockAlertEntry;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Samples.Spin;

type
  TframeStockAlertEntry = class(TFrame)
    Label2: TLabel;
    comboSymbol: TComboBox;
    chkAddToMyStocks: TCheckBox;
    cmbPriceLevel: TComboBox;
    Label3: TLabel;
    edPrice: TEdit;
    edVolume: TEdit;
    Label4: TLabel;
    cmbLogic: TComboBox;
    Label5: TLabel;
    edMaxAlert: TSpinEdit;
    memNotes: TMemo;
    Label6: TLabel;
    Bevel1: TBevel;
    btnAddAlert: TButton;
    btnReset: TButton;
    scrollAlerts: TScrollBox;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

{ TframeStockAlertEntry }

constructor TframeStockAlertEntry.Create(aOwner: TComponent);
var
  i: Integer;
begin
  inherited;

  for i := 0 to ControlCount - 1 do
  begin
    if Controls[i] is TLabel then
      TLabel(Controls[i]).ParentFont := true;
    if Controls[i] is TEdit then
      TEdit(Controls[i]).ParentFont := true;
    if Controls[i] is TComboBox then
      TComboBox(Controls[i]).ParentFont := true;
    if Controls[i] is TMemo then
      TMemo(Controls[i]).ParentFont := true;
    if Controls[i] is TSpinEdit then
      TSpinEdit(Controls[i]).ParentFont := true;
    if Controls[i] is TCheckBox then
      TCheckBox(Controls[i]).ParentFont := true;
    if Controls[i] is TButton then
      TButton(Controls[i]).ParentFont := true;
  end;
  Font.Size := 9;

end;

end.
