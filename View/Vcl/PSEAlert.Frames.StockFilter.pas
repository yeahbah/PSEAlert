unit PSEAlert.Frames.StockFilter;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  System.Actions, Vcl.ActnList, Vcl.ExtCtrls;

type
  TframeStockFilter = class(TFrame)
    Panel1: TPanel;
    btnRun: TButton;
    btnClearAll: TButton;
    btnReloadData: TButton;
    Panel2: TPanel;
    ActionList1: TActionList;
    Label1: TLabel;
    cmbFilter: TComboBox;
    btnAdd: TButton;
    actReloadData: TAction;
    actClearAll: TAction;
    actRun: TAction;
    actAddFilter: TAction;
    scrollFilter: TScrollBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
