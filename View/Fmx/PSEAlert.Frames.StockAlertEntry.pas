unit PSEAlert.Frames.StockAlertEntry;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Layouts, FMX.Memo, FMX.ListBox, System.Actions, FMX.ActnList,
  FMX.Effects, FMX.ComboEdit, FMX.ScrollBox, FMX.Controls.Presentation,
  FMX.EditBox, FMX.SpinBox;

type
  TframeStockAlertEntry = class(TFrame)
    edMaxAlert: TSpinBox;
    Label1: TLabel;
    chkAddToMyStocks: TCheckBox;
    Label2: TLabel;
    cmbPriceLevel: TComboBox;
    edPrice: TEdit;
    cmbLogic: TComboBox;
    Label3: TLabel;
    edVolume: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    btnAddAlert: TButton;
    btnReset: TButton;
    scrollAlerts: TScrollBox;
    comboSymbol: TComboEdit;
    ActionList: TActionList;
    actAddAlert: TAction;
    actReset: TAction;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edtNotes: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
