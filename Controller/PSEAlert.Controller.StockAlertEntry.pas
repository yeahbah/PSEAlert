unit PSEAlert.Controller.StockAlertEntry;

interface

uses
  Controller.Base,
  SvBindings,
  PSE.Data.Model,

  Controls,
  Forms,
  StdCtrls,
  Dialogs,
  StrUtils,
  SysUtils,
  System.UITypes,
  Classes,
  Generics.Collections
  {$IFDEF FMXAPP}
  , FMX.Types
  , FMX.ListBox
  , FMX.Edit
  , FMX.Memo
  , FMX.Layouts
  , FMX.ActnList
  , FMX.Objects
  {$ELSE}
  , Vcl.Samples.Spin
  {$ENDIF},
  Spring,
  Spring.Collections,
  Yeahbah.Messaging;

type
  TStockAlertEntryController = class(TBaseController<TList<TAlertModel>>, IMessageReceiver)
  private
    {$HINTS OFF}
    [Bind]
    cmbLogic: TComboBox;

    [Bind]
    comboSymbol: {$IFDEF FMXAPP}TComboEdit{$ELSE}TComboBox{$ENDIF};

    [Bind]
    chkAddToMyStocks: TCheckBox;

    [Bind]
    cmbPriceLevel: TComboBox;

    [Bind]
    edPrice: TEdit;

    [Bind]
    edVolume: TEdit;

    [Bind]
    edMaxAlert: {$IFDEF FMXAPP}TSpinBox{$ELSE}TSpinEdit{$ENDIF};

    [Bind]
    edtNotes: TEdit;
{$IFDEF FMXAPP}
    [Bind]
    actAddAlert: TAction;
    [Bind]
    actReset: TAction;
{$ELSE}
    [Bind]
    btnReset: TButton;
    [Bind]
    btnAddAlert: TButton;
{$ENDIF}
    [Bind]
    scrollAlerts: TScrollBox;
    {$HINTS ON}
  protected
    procedure Initialize; override;
    procedure DoReset(Sender: TObject);
    procedure DoAddAlert(Sender: TObject);
    procedure CreateStockAlertRow(const aAlertModel: TAlertModel);
    procedure ReloadStockList;
    procedure IntEditKeyPress(Sender: TObject; var Key: Char);
  public

    procedure Receive(const aMessage: IMessage);
  end;

function CreateStockAlertEntryController(aAlertModel: IList<TAlertModel>;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TList<TAlertModel>>;

implementation

uses
  PSEAlert.Frames.StockAlertEntry,
  Yeahbah.ObjectClone,
  PSEAlert.Controller.StockAlert,
  PSEAlert.Messages,
  PSE.Data,
  Spring.Persistence.Core.Interfaces,
  PSE.Data.Repository;

function CreateStockAlertEntryController(aAlertModel: IList<TAlertModel>;
  aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF}): IController<TList<TAlertModel>>;
begin
  TControllerFactory<TList<TAlertModel>>.RegisterFactoryMethod(TframeStockAlertEntry,
    function: IController<TList<TAlertModel>>
    var
      frame: TframeStockAlertEntry;
      alertModels: TList<TAlertModel>;
    begin
      frame := TframeStockAlertEntry.Create(Application);
      frame.Parent := aParent;
      frame.Align := {$IFDEF FMXAPP}TAlignLayout.Client{$ELSE}TAlign.alClient{$ENDIF};
      frame.edMaxAlert.Value := 10;

      alertModels := TList<TAlertModel>.Create;
      alertModels.AddRange(aAlertModel.ToArray);
      result := TStockAlertEntryController.Create(alertModels, frame);
      frame.Visible := true;
    end);
  result := TControllerFactory<TList<TAlertModel>>.GetInstance(TframeStockAlertEntry);
end;

{ TStockAlertEntryController }

procedure TStockAlertEntryController.CreateStockAlertRow(
  const aAlertModel: TAlertModel);
var
  alertModel: TAlertModel;
  controller: IController<TAlertModel>;
begin
  alertModel := TObjectClone.From(aAlertModel);
  //ShowMessage(alertModel.ID.ToString);
  controller := CreateStockAlertController(alertModel, scrollAlerts);
end;

procedure TStockAlertEntryController.DoAddAlert(Sender: TObject);
var
  stockAlertModel: TAlertModel;
  selectedText: string;

begin
{$IFDEF FMXAPP}
  selectedText := comboSymbol.Text.Trim.ToUpper;
//  if scrollAlerts.FindComponent('alert' + selectedText) <> nil then
{$ELSE}
  selectedText := comboSymbol.Text;
//  if scrollAlerts.FindChildControl('alert' + selectedText) <> nil then
{$ENDIF}
//  begin
//    MessageDlg('Alert for stock '+ selectedText +' already exist.', TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
//    Exit;
//  end;

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
    stockAlertModel.Price := StrToFloat(edPrice.Text);
    stockAlertModel.PriceTriggerType := TPriceTriggerType(cmbPriceLevel.ItemIndex);

    if cmbLogic.ItemIndex > 0 then
    begin
      stockAlertModel.Volume := StrToFloat(edVolume.Text);
      stockAlertModel.Logic := TLogicType(cmbLogic.ItemIndex);
    end;

    stockAlertModel.AlertCount := 0;
    stockAlertModel.Notes := edtNotes.Text;

    PSEAlertDb.Session.Save(stockAlertModel);

    CreateStockAlertRow(stockAlertModel);

  finally
    stockAlertModel.Free;
  end;

  if edMaxAlert.Text = '' then
    edMaxAlert.Value := 10;


{$IFDEF FMXAPP}
  if chkAddToMyStocks.IsChecked then
{$ELSE}
  if chkAddToMyStocks.Checked then
{$ENDIF}
    MessengerInstance.SendMessage(TAddStockToWatchListMessage.Create(selectedText));

{$IFDEF FMXAPP}
  actReset.Execute;
{$ELSE}
  btnReset.Click;
{$ENDIF}
end;

procedure TStockAlertEntryController.DoReset(Sender: TObject);
begin
  edPrice.Text := '';
  edVolume.Text := '';
  cmbLogic.ItemIndex := -1;
  comboSymbol.Text := '';
  cmbPriceLevel.ItemIndex := -1;
{$IFDEF FMXAPP}
  chkAddToMyStocks.IsChecked := false;
{$ELSE}
  chkAddToMyStocks.Checked := false;
{$ENDIF}
  edMaxAlert.Text := '10';
  edtNotes.Text := '';
end;

procedure TStockAlertEntryController.Initialize;
var
  alertModel: TAlertModel;
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TAddStockAlertMessage);

{$IFDEF FMXAPP}
  actReset.OnExecute := DoReset;
  actAddAlert.OnExecute := DoAddAlert;
{$ELSE}
  edPrice.OnKeyPress := IntEditKeyPress;
  edVolume.OnKeyPress := IntEditKeyPress;
  btnReset.OnClick := DoReset;
  btnAddAlert.OnClick := DoAddAlert;
{$ENDIF}
  ReloadStockList;
  for alertModel in Model do
  begin
    CreateStockAlertRow(alertModel);
  end;
end;

procedure TStockAlertEntryController.IntEditKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', '.', #8]) then
    Key := #0;
end;

procedure TStockAlertEntryController.Receive(const aMessage: IMessage);
begin
  if aMessage is TAddStockAlertMessage then
  begin
    DoReset(nil);
    comboSymbol.ItemIndex := comboSymbol.Items.IndexOf(TAddStockAlertMessage(aMessage).Data);
  end;
end;

procedure TStockAlertEntryController.ReloadStockList;
var
  stocks: IList<TStockModel>;
  stock: TStockModel;
begin
  comboSymbol.Clear;

  stocks := stockRepository.GetAllStocks;
  for stock in stocks do
  begin
    comboSymbol.Items.Add(stock.Symbol);
  end;

  comboSymbol.ItemIndex := 0;
end;

end.
