unit PSEAlert.Frames.StockAlertEntry;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Layouts, FMX.Memo, FMX.ListBox, System.Actions, FMX.ActnList,
  FMX.Effects, PSE.Data.Model, Generics.Collections;

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
    memNotes: TMemo;
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
  private
    fModel: TList<TAlertModel>;
    { Private declarations }
    procedure Initialize;
    procedure DoReset(Sender: TObject);
    procedure DoAddAlert(Sender: TObject);
    procedure ReloadStockList;
    procedure CreateStockAlertRow(const aAlertModel: TAlertModel);
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); overload; override;
    constructor Create(aOwner: TComponent; aModel: TList<TAlertModel>); reintroduce; overload;
    property Model: TList<TAlertModel> read fModel write fModel;
  end;

implementation

uses
  PSEAlert.DataModule, Yeahbah.Messaging, Yeahbah.ObjectClone,
  PSEAlert.Messages, PSEAlert.Frames.StockAlert, PSEAlert.Utils;

{$R *.fmx}

{ TframeStockAlertEntry }

constructor TframeStockAlertEntry.Create(aOwner: TComponent);
begin
  inherited;
end;

constructor TframeStockAlertEntry.Create(aOwner: TComponent;
  aModel: TList<TAlertModel>);
begin
  Create(aOwner);
  Model := aModel;
  Initialize;
end;

procedure TframeStockAlertEntry.CreateStockAlertRow(
  const aAlertModel: TAlertModel);
var
  alertModel: TAlertModel;
  frm: TframeStockAlert;
begin

  alertModel := TObjectClone.From(aAlertModel);
  alertModel.PriceTrigger := TObjectClone.From(aAlertModel.PriceTrigger);
  alertModel.VolumeTrigger := TObjectClone.From(aAlertModel.VolumeTrigger);

  frm := TframeStockAlert.Create(scrollAlerts, alertModel);
  scrollAlerts.AddObject(frm);
  frm.Align := TAlignLayout.Top;
  frm.Name := 'alert' + GenerateControlName(alertModel.StockSymbol);
  frm.Visible := true;

end;

procedure TframeStockAlertEntry.DoAddAlert(Sender: TObject);
var
  stockAlertModel: TAlertModel;
  selectedText: string;
begin

  selectedText := comboSymbol.Text.Trim.ToUpper;
  if scrollAlerts.FindComponent('alert' + selectedText) <> nil then

  begin
    MessageDlg('Alert for stock '+ selectedText +' already exist.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  if selectedText = '' then
  begin
    MessageDlg('Please select stock symbol.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  if cmbPriceLevel.ItemIndex < 0 then
  begin
    MessageDlg('Please select price level.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  if edPrice.Text = '' then
  begin
    MessageDlg('Please enter stock price.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
    Exit;
  end;

  stockAlertModel := TAlertModel.Create;
  try
    stockAlertModel.StockSymbol := selectedText;
    stockAlertModel.CreatedDateTime := Now;
    stockAlertModel.PriceTrigger.Price := StrToFloat(edPrice.Text);
    stockAlertModel.PriceTrigger.PriceTriggerType := TPriceTriggerType(cmbPriceLevel.ItemIndex);

    if cmbLogic.ItemIndex > 0 then
    begin
      stockAlertModel.VolumeTrigger.Volume := StrToFloat(edVolume.Text);
      stockAlertModel.VolumeTrigger.Logic := TLogicType(cmbLogic.ItemIndex);
    end;
    stockAlertModel.AlertCount := 0;
    stockAlertModel.Notes := memNotes.Lines.Text;
    CreateStockAlertRow(stockAlertModel);
  finally
    stockAlertModel.Free;
  end;

  if edMaxAlert.Text = '' then
    edMaxAlert.Value := 10;

  PSEStocksData.cdsAlerts.Open;
  PSEStocksData.cdsAlerts.Insert;
  PSEStocksData.cdsAlerts.FieldByName('SYMBOL').AsString := selectedText;
  PSEStocksData.cdsAlerts.FieldByName('PRICE').AsString := edPrice.Text;
  PSEStocksData.cdsAlerts.FieldByName('PRICELEVEL').AsInteger := cmbPriceLevel.ItemIndex;


  if cmbLogic.ItemIndex > 0 then
  begin
    PSEStocksData.cdsAlerts.FieldByName('VOL_CONJUNCT').AsString := cmbLogic.Selected.Text;
    PSEStocksData.cdsAlerts.FieldByName('VOLUME').AsString := edVolume.Text;
  end;


  PSEStocksData.cdsAlerts.FieldByName('MAX_ALERT').AsString := edMaxAlert.Text;
  PSEStocksData.cdsAlerts.FieldByName('NOTES').AsString := memNotes.Lines.Text;

  try
    PSEStocksData.cdsAlerts.Post;
    PSEStocksData.cdsAlerts.ApplyUpdates(0);
  except
    on e: Exception do
    begin
      MessageDlg(e.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
      PSEStocksData.cdsAlerts.Cancel;
    end;
  end;

  if chkAddToMyStocks.IsChecked then
    MessengerInstance.SendMessage(TAddStockToWatchListMessage.Create(selectedText));


  actReset.Execute;


end;

procedure TframeStockAlertEntry.DoReset(Sender: TObject);
begin
  edPrice.Text := '';
  edVolume.Text := '';
  cmbLogic.ItemIndex := -1;
  comboSymbol.Text := '';
  cmbPriceLevel.ItemIndex := -1;

  chkAddToMyStocks.IsChecked := false;

  edMaxAlert.Text := '10';
  memNotes.Lines.Clear;

end;

procedure TframeStockAlertEntry.Initialize;
var
  alertModel: TAlertModel;
begin

  actReset.OnExecute := DoReset;
  actAddAlert.OnExecute := DoAddAlert;

  ReloadStockList;

  for alertModel in Model do
  begin
    CreateStockAlertRow(alertModel);
  end;

end;

procedure TframeStockAlertEntry.ReloadStockList;
begin
  comboSymbol.Clear;
  PSEStocksData.sqlStocks.Open;
  PSEStocksData.sqlStocks.First;
  while not PSEStocksData.sqlStocks.Eof do
  begin
    comboSymbol.Items.Add(PSEStocksData.sqlStocks.FieldByName('SYMBOL').AsString);
    PSEStocksData.sqlStocks.Next;
  end;
  comboSymbol.ItemIndex := 0;
end;

end.
