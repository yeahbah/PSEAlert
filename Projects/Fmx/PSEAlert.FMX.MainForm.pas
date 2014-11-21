unit PSEAlert.FMX.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl, FMX.ListBox, FMX.Layouts, System.Actions, FMX.ActnList,
  FMX.Edit, PSEAlert.Settings, Yeahbah.Messaging, PSE.Data.Model,
  Generics.Collections;

type
  TfrmMain = class(TForm, IMessageReceiver)
    ActionList1: TActionList;
    actRefresh: TAction;
    actAdd: TAction;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    PageControl: TTabControl;
    tabWatchList: TTabItem;
    scrollMyStocks: TScrollBox;
    btnAddStock: TButton;
    SpeedButton1: TSpeedButton;
    tabIndeces: TTabItem;
    tabAlerts: TTabItem;
    tabAbout: TTabItem;
    lblStatusText: TLabel;
    btnRefresh: TSpeedButton;
    scrollIndeces: TScrollBox;
    SpeedButton2: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    cmbAddStock: TComboEdit;
    Label3: TLabel;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ReloadComboStockList(const aComboBox:{$IFDEF FMXAPP}TComboEdit{$ELSE}TComboBox{$ENDIF});
    procedure AddStockToWatchList(const aSymbol: string);
    procedure CreateStockPriceFrame(const aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
      const aStockSymbol, aStockDescription: string);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure InitializeForm;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
  private
    { Private declarations }
    procedure CreateAlertEntryScreen(aAlertModels: TList<TAlertModel>; aParent: TFMXObject);
    procedure CreateSettingsScreen;
  public
    { Public declarations }
    procedure Receive(const aMessage: IMessage);
    procedure SetStatusText(const aStatus: string);
  end;

var
  frmMain: TfrmMain;

implementation

uses
  PSEAlert.DataModule, PSEAlert.Utils, DB,
  PSEAlert.Messages, PSEAlert.Frames.StockPrice,
  PSE.Data.Downloader, PSEAlert.Frames.StockAlertEntry,
  PSEAlert.Frames.Settings;

{$R *.fmx}

procedure TfrmMain.actAddExecute(Sender: TObject);
var
  selectedSymbol: string;
begin

  selectedSymbol := cmbAddStock.Text;

  if cmbAddStock.ItemIndex > -1 then
    AddStockToWatchList(selectedSymbol);
end;

procedure TfrmMain.actRefreshExecute(Sender: TObject);
var
  downloadTask: TDownloadTask;
begin
  downloadTask := TDownloadTask.Create;
  downloadTask.Execute(
    procedure
    begin
      actRefresh.Enabled := false;
    end,

    procedure
    begin
      actRefresh.Enabled := true;
    end,

    procedure (stock: TStockModel)
    begin
      if stock <> nil then
        MessengerInstance.SendMessage(TStockUpdateMessage.Create(stock));
    end);
end;

procedure TfrmMain.AddStockToWatchList(const aSymbol: string);
begin
  PSEStocksData.sqlStocks.Open;
  if PSEStocksData.sqlStocks.Locate('SYMBOL', aSymbol.ToUpper, [loCaseInsensitive]) then
  begin
    PSEStocksData.PSEStocksConnection.ExecSQL('UPDATE STOCKS SET ISFAVORITE = ''1'' WHERE SYMBOL = ' + QuotedStr(aSymbol.ToUpper));
    if scrollMyStocks.FindComponent(aSymbol.ToUpper) = nil then
      CreateStockPriceFrame(scrollMyStocks, aSymbol.ToUpper, PSEStocksData.sqlStocks.FieldByName('DESCRIPTION').AsString);
  end
  else
    MessageDlg('Unable to find ' + aSymbol.ToUpper, TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);
end;

procedure TfrmMain.CreateAlertEntryScreen(aAlertModels: TList<TAlertModel>;
  aParent: TFMXObject);
var
  frame: TframeStockAlertEntry;
begin
  frame := TframeStockAlertEntry.Create(Application, aAlertModels);
  frame.Parent := aParent;
  frame.Align := TAlignLayout.Client;
  frame.edMaxAlert.Value := 10;
  frame.Visible := true;
end;

procedure TfrmMain.CreateSettingsScreen;
var
  frame: TframeSettings;
begin
  frame := TframeSettings.Create(Application);
  frame.Align := TAlignLayout.Client;
  frame.Parent := tabAbout;
  tabAbout.AddObject(frame);
  frame.Visible := true;
end;

procedure TfrmMain.CreateStockPriceFrame(const aParent: TFMXObject;
  const aStockSymbol, aStockDescription: string);
var
  stockModel: TStockModel;
  frmStockPrice: TframeStockPrice;
begin
  stockModel := TStockModel.Create;
  stockModel.Symbol := aStockSymbol;
  stockModel.Description := aStockDescription;
  frmStockPrice := TframeStockPrice.Create(aParent, stockModel);

  frmStockPrice.Align := TAlignLayout.Top;
  frmStockPrice.Name := GenerateControlName(stockModel.Symbol);
  frmStockPrice.Visible := true;
  aParent.AddObject(frmStockPrice);
end;

procedure TfrmMain.FormActivate(Sender: TObject);
var
  stockAlertModel: TAlertModel;
  tmp: string;
  alertModels: TList<TAlertModel>;
begin


  frmMain.OnActivate := nil;


  ReloadComboStockList(cmbAddStock);

  PSEStocksData.cdsMyStocks.Open;
  while not PSEStocksData.cdsMyStocks.Eof do
  begin
    CreateStockPriceFrame(scrollMyStocks, PSEStocksData.cdsMyStocks.FieldByName('SYMBOL').AsString,
      PSEStocksData.cdsMyStocks.FieldByName('DESCRIPTION').AsString);
    PSEStocksData.cdsMyStocks.Next;
  end;

  PSEStocksData.cdsIndeces.Open;
  while not PSEStocksData.cdsIndeces.Eof do
  begin
    CreateStockPriceFrame(scrollIndeces, PSEStocksData.cdsIndeces.FieldByName('SYMBOL').AsString,
      PSEStocksData.cdsIndeces.FieldByName('DESCRIPTION').AsString);
    PSEStocksData.cdsIndeces.Next;
  end;

  alertModels := TList<TAlertModel>.Create;

  PSEStocksData.cdsAlerts.Open;
  while not PSEStocksData.cdsAlerts.Eof do
  begin
    stockAlertModel := TAlertModel.Create;

    stockAlertModel.StockSymbol := PSEStocksData.cdsAlerts.FieldByName('SYMBOL').AsString;
    stockAlertModel.PriceTrigger.PriceTriggerType := TPriceTriggerType(PSEStocksData.cdsAlerts.FieldByName('PRICELEVEL').AsInteger);
    stockAlertModel.PriceTrigger.Price := PSEStocksData.cdsAlerts.FieldByName('PRICE').AsFloat;
    tmp := PSEStocksData.cdsAlerts.FieldByName('VOL_CONJUNCT').AsString;
    if tmp <> string.Empty then
    begin
      if tmp = 'OR' then
        stockAlertModel.VolumeTrigger.Logic := TLogicType.LogicOr;
      if tmp = 'AND' then
        stockAlertModel.VolumeTrigger.Logic := TLogicType.LogicAND;
      stockAlertModel.VolumeTrigger.Volume := PSEStocksData.cdsAlerts.FieldByName('VOLUME').AsInteger;
    end;
    stockAlertModel.AlertCount := PSEStocksData.cdsAlerts.FieldByName('ALERT_COUNT').AsInteger;
    stockAlertModel.MaxAlertCount := PSEStocksData.cdsAlerts.FieldByName('MAX_ALERT').AsInteger;
    stockAlertModel.Notes := PSEStocksData.cdsAlerts.FieldByName('NOTES').AsString;
    alertModels.Add(stockAlertModel);

    PSEStocksData.cdsAlerts.Next;
  end;

  CreateAlertEntryScreen(alertModels, tabAlerts);
  CreateSettingsScreen;
//  fAlertEntryController := CreateStockAlertEntryController(alertModels, mainView.tabAlerts);

//  fSettingsController := CreatePSEAlertSettingsController(PSEAlertSettings, mainView.tabAbout);

end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := false;
  PSEAlertSettings.FormLeft :=  Left;
  PSEAlertSettings.FormTop := Top;
  PSEAlertSettings.FormWidth := Width;
  PSEAlertSettings.FormHeight := Height;
  MessengerInstance.UnRegisterAll;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  PageControl.ActiveTab := tabWatchList;
  InitializeForm;
end;

procedure TfrmMain.InitializeForm;
begin
  frmMain.Left := PSEAlertSettings.FormLeft;
  frmMain.Top := PSEAlertSettings.FormTop;
  frmMain.Width := PSEAlertSettings.FormWidth;
  frmMain.Height := PSEAlertSettings.FormHeight;


  FormActivate(frmMain);


  Timer1.Interval := GetPollIntervalValue(PSEAlertSettings.PollInterval);
  Timer1.Enabled := PSEAlertSettings.PollInterval > 0;
end;

procedure TfrmMain.Receive(const aMessage: IMessage);
begin
  if aMessage is TPollIntervalChangedMessage then
  begin
    Timer1.Interval := (aMessage as TPollIntervalChangedMessage).Data;
  end
  else
  if aMessage is TEnableDisablePollingMessage then
  begin
    Timer1.Enabled := (aMessage as TEnableDisablePollingMessage).Data;
  end
  else
  if aMessage is TBeforeDownloadMessage then
  begin
    SetStatusText('Downloading...');
  end
  else
  if aMessage is TAfterDownloadMessage then
  begin
    if (aMessage as TAfterDownloadMessage).Data > 0 then
      SetStatusText('As of ' + DateTimeToStr((aMessage as TAfterDownloadMessage).Data))
    else
      SetStatusText('Market Pre-Open');
  end
  else
  if aMessage is TNoDataMessage then
  begin
    SetStatusText('');
  end
  else
  if aMessage is TReloadDataMessage then
  begin
    ReloadComboStockList(cmbAddStock);
  end
  else
  if aMessage is TAddStockToWatchListMessage then
  begin
    AddStockToWatchList((aMessage as TAddStockToWatchListMessage).Data);
  end;
{$IFNDEF FMXAPP}
  if aMessage is TAlertTriggeredMessage then
  begin
    //FlashTaskbarIcon;
    FlashWindow(frmMain.Handle, true);
  end;
{$ENDIF}
end;

procedure TfrmMain.ReloadComboStockList(const aComboBox: TComboEdit);
begin
  aComboBox.Clear;
  PSEStocksData.sqlStocks.Open;
  PSEStocksData.sqlStocks.First;
  while not PSEStocksData.sqlStocks.Eof do
  begin
    aComboBox.Items.Add(PSEStocksData.sqlStocks.FieldByName('SYMBOL').AsString);
    PSEStocksData.sqlStocks.Next;
  end;
  aComboBox.ItemIndex := 0;
end;

procedure TfrmMain.SetStatusText(const aStatus: string);
begin

  lblStatusText.Text := aStatus;

end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := false;
  try
    actRefresh.Execute;
  finally
    Timer1.Enabled := true;
  end;
end;

procedure TfrmMain.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := false;
  actRefresh.Execute;
  Timer1.Enabled := PSEAlertSettings.PollInterval > 0;
end;

end.
