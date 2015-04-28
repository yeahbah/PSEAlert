unit PSEAlert.Controller.MainForm;

interface

uses
  Controller.Base,
  SvBindings,
  ExtCtrls,
  Yeahbah.Messaging,
  ActnList,
{$IFDEF FMXAPP}
  FMX.Forms,
  FMX.Edit,
  FMX.Types,
  FMX.ListBox,
  FMX.Layouts,
{$ELSE}
  ComCtrls,
  Buttons,
  Forms,
{$ENDIF}
  SysUtils,
  StdCtrls,

  Controls,
  DB,
  Dialogs,
  Windows,
  Generics.Collections,
  Generics.Defaults,
  PSEAlert.Controller.StockAlertEntry,
  PSEAlert.Controller.Settings,
  PSEAlert.Settings,
  PSE.Data.Model,
  System.UITypes,
  PSEAlert.Controller.StockPrice;

type
  TMainFormController = class(TBaseController<TObject>, IMessageReceiver)
  private
    Timer1: TTimer;
    Timer2: TTimer;
    [Bind]
    actRefresh: TAction;
    [Bind]
    actAdd: TAction;
    [Bind]
    actSortAsc: TAction;
    [Bind]
    actSortDesc: TAction;
    [Bind]
    btnSort: TSpeedButton;
    [Bind]
    actRefreshMostActive: TAction;
{$IFDEF FMXAPP}
    [Bind]
    lblStatusText: TLabel;
    [Bind]
    cmbAddStock: TComboEdit;
{$ELSE}
    [Bind]
    StatusBar1: TStatusBar;
    [Bind]
    cmbAddStock: TComboBox;
{$ENDIF}

    [Bind]
    scrollMyStocks: TScrollBox;
    [Bind]
    scrollIndeces: TScrollBox;
    [Bind]
    scrollBoxMostActive: TScrollBox;
    [Bind]
    scrollBoxGainers: TScrollBox;
    [Bind]
    scrollBoxLosers: TScrollBox;
  protected
    fAlertEntryController: IController<TList<TAlertModel>>;
    fSettingsController: IController<TPSEAlertSettings>;
    procedure Initialize; override;
    procedure TriggerTimer1(Sender: TObject);
    procedure TriggerTimer2(Sender: TObject);
    procedure ExecuteRefreshAction(Sender: TObject);
    procedure ExecuteRefreshMostActiveAction(Sender: TObject);
    procedure ExecuteAddAction(Sender: TObject);
    procedure ExecuteSortAction(Sender: TObject);
    procedure ReloadComboStockList(const aComboBox:{$IFDEF FMXAPP}TComboEdit{$ELSE}TComboBox{$ENDIF});
    procedure AddStockToWatchList(const aSymbol: string);
    procedure CreateStockPriceFrame(const aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
      const aStockSymbol, aStockDescription: string; aUserActions: TUserActions);
    procedure MainFormClose(Sender: TObject; var Action: TCloseAction);
    procedure MainFormCreate(Sender: TObject);
    procedure MainFormActivate(Sender: TObject);
    procedure InitializeForm;
  public
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
    procedure SetStatusText(const aStatus: string);
  end;

function CreateMainFormController(aModel: TObject): IController<TObject>;

implementation

uses {$IFDEF FMXAPP}PSEAlert.FMX.MainForm{$ELSE}PSEAlert.MainForm{$ENDIF},
  PSEAlert.Messages,
  PSE.Data.Downloader, PSEAlert.Utils,
  Spring.Collections, PSE.Data,
  Spring.Persistence.Core.Interfaces,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions,
  Spring.Persistence.Criteria.OrderBy,
  Spring.Persistence.Criteria.Properties, PSE.Data.Repository,
  PSE.Data.Model.JSON,
  Classes;

function CreateMainFormController(aModel: TObject): IController<TObject>;
begin
  TControllerFactory<TObject>.RegisterFactoryMethod(TfrmMain,
    function: IController<TObject>
    var
      c: TMainFormController;
    begin
      {$IFNDEF FMXAPP}
      Application.CreateForm(TfrmMain, frmMain);
      {$ENDIF}
      c := TMainFormController.Create(aModel, frmMain);
      c.InitializeForm;

      {$IFNDEF FMXAPP}
      frmMain.OnActivate := c.MainFormActivate;
      {$ENDIF}

      frmMain.OnClose := c.MainFormClose;
      result := c;
      {$IFNDEF FMXAPP}
      frmMain.Show;
      {$ENDIF}
    end);
  result := TControllerFactory<TObject>.GetInstance(TfrmMain);

end;

{ TMainFormController }

procedure TMainFormController.AddStockToWatchList(const aSymbol: string);
var
  stocks: IList<TStockModel>;
  stock: TStockModel;
  criteria: ICriteria<TStockModel>;
begin
  //PSEStocksData.PSEStocksConnection.Close;

  criteria := PSEAlertDb.Session.CreateCriteria<TStockModel>;
  stocks := criteria.Add(TRestrictions.Eq('SYMBOL', aSymbol.ToUpper)).ToList;
  stock := stocks.SingleOrDefault;

  if stock <> nil then
  begin
    stockRepository.MakeFavorite(aSymbol.ToUpper);
{$IFDEF FMXAPP}
    if scrollMyStocks.FindComponent(aSymbol.ToUpper) = nil then
{$ELSE}
    if scrollMyStocks.FindChildControl(aSymbol.ToUpper) = nil then
{$ENDIF}
    CreateStockPriceFrame(scrollMyStocks, aSymbol.ToUpper, stock.Description, [Close]);
  end
  else
    MessageDlg('Unable to find ' + aSymbol.ToUpper, TMsgDlgType.mtError, [TMsgDlgBtn.mbOk], 0);

end;

procedure TMainFormController.CreateStockPriceFrame(
  const aParent: {$IFDEF FMXAPP}TFMXObject{$ELSE}TWinControl{$ENDIF};
  const aStockSymbol, aStockDescription: string; aUserActions: TUserActions);
var
  controller: IController<TIntradayModel>;
  stockModel: TIntradayModel;
begin
  stockModel := TIntradayModel.Create;
  stockModel.Symbol := aStockSymbol;
  stockModel.Description := aStockDescription;
  controller := CreateStockPriceController(stockModel, aParent, aUserActions);
end;

destructor TMainFormController.Destroy;
begin

  inherited;
end;

procedure TMainFormController.ExecuteAddAction(Sender: TObject);
var
  selectedSymbol: string;
begin
{$IFDEF FMXAPP}
  selectedSymbol := cmbAddStock.Text;
{$ELSE}
  selectedSymbol := cmbAddStock.Text;
{$ENDIF}
  if cmbAddStock.ItemIndex > -1 then
    AddStockToWatchList(selectedSymbol);
end;

procedure TMainFormController.ExecuteRefreshAction(Sender: TObject);
var
  downloadTask: TIntradayDownloader;
begin
  downloadTask := TIntradayDownloader.Create;
  downloadTask.Execute(
    procedure
    begin
      actRefresh.Enabled := false;
    end,

    procedure
    begin
      actRefresh.Enabled := true;
    end,

    procedure (stock: TIntradayModel)
    begin
      if stock <> nil then
        MessengerInstance.SendMessage(TIntradayUpdateMessage.Create(stock));
    end);
end;

procedure TMainFormController.ExecuteRefreshMostActiveAction(Sender: TObject);
begin
  ExecuteRefreshAction(Sender);
end;

procedure TMainFormController.ExecuteSortAction(Sender: TObject);
var
  a: TAction;
  i: Integer;
  s: TList<TFrame>;
  asc, desc: TDelegatedComparer<TFrame>;
  f: TFrame;
begin
  desc := TDelegatedComparer<TFrame>.Create(
    function (const l, r: TFrame): integer
    begin
      result := CompareStr(r.Name, l.Name);
    end);

  asc := TDelegatedComparer<TFrame>.Create(
    function (const l, r: TFrame): integer
    begin
      result := CompareStr(l.Name, r.Name);
    end);

  s := TList<TFrame>.Create;
  try
    a := Sender as TAction;
    for i := 0 to scrollMyStocks.ControlCount -1 do
    begin
      if scrollMyStocks.Controls[i] is TFrame then
      begin
        s.Add(TFrame(scrollMyStocks.Controls[i]));
      end;
    end;

    while scrollMyStocks.ControlCount > 0 do
    begin
      scrollMyStocks.Controls[0].Visible := false;
      scrollMyStocks.Controls[0].Align := alNone;
      scrollMyStocks.RemoveControl(scrollMyStocks.Controls[0]);
    end;

    if a = actSortAsc then
    begin
      s.Sort(asc);
      btnSort.Action := actSortDesc;
    end
    else
    begin
      s.Sort(desc);
      btnSort.Action := actSortAsc;
    end;

    for f in s do
    begin
      f.Parent := scrollMyStocks;
      f.Align := alTop;
      f.Show;
    end;

  finally
    asc.Free;
    desc.Free;
    s.Free;
  end;

end;

procedure TMainFormController.Initialize;
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TPollIntervalChangedMessage);
  MessengerInstance.RegisterReceiver(self, TEnableDisablePollingMessage);
  MessengerInstance.RegisterReceiver(self, TReloadDataMessage<TStockModel>);
  MessengerInstance.RegisterReceiver(self, TBeforeDownloadMessage);
  MessengerInstance.RegisterReceiver(self, TAfterDownloadMessage);
  MessengerInstance.RegisterReceiver(self, TNoDataMessage<TIntradayModel>);
  MessengerInstance.RegisterReceiver(self, TAddStockToWatchListMessage);
  MessengerInstance.RegisterReceiver(self, TAlertTriggeredMessage);
  MessengerInstance.RegisterReceiver(self, TAddStockAlertMessage);

  Timer1 := TTimer.Create(Application);
  Timer2 := TTimer.Create(Application);

  Timer1.OnTimer := TriggerTimer1;
  Timer2.OnTimer := TriggerTimer2;

  // Attach action execute events
  actRefresh.OnExecute := ExecuteRefreshAction;
  actAdd.OnExecute := ExecuteAddAction;
  actSortAsc.OnExecute := ExecuteSortAction;
  actSortDesc.OnExecute := ExecuteSortAction;
  actRefreshMostActive.OnExecute := ExecuteRefreshMostActiveAction;

  btnSort.Action := actSortAsc;
end;

procedure TMainFormController.InitializeForm;
begin

  frmMain.Left := PSEAlertSettings.FormLeft;
  frmMain.Top := PSEAlertSettings.FormTop;
  frmMain.Width := PSEAlertSettings.FormWidth;
  frmMain.Height := PSEAlertSettings.FormHeight;

{$IFDEF FMXAPP}
  MainFormActivate(frmMain);
{$ELSE}
  frmMain.PageControl.ActivePageIndex := 0;
  frmMain.pageStocks.ActivePageIndex := 0;
  StatusBar1.Font.Size := 9;
{$ENDIF}

  Timer1.Interval := GetPollIntervalValue(PSEAlertSettings.PollInterval);
  Timer1.Enabled := PSEAlertSettings.PollInterval > 0;
end;

procedure TMainFormController.MainFormActivate(Sender: TObject);
var
  alertModels: IList<TAlertModel>;
  mainView: TfrmMain;
  stocks: IList<TStockModel>;
  indeces: IList<TIndexModel>;
  pseIndex: TIndexModel;
  stock: TStockModel;
  activityDownloader: TStockActivityDownloader;
begin

{$IFNDEF FMXAPP}
  frmMain.OnActivate := nil;
{$ENDIF}

  ReloadComboStockList(cmbAddStock);

  stocks := stockRepository.GetFavoriteStocks;
  for stock in stocks do
  begin
    CreateStockPriceFrame(scrollMyStocks, stock.Symbol, stock.description, [Close]);
  end;

  indeces := PSEAlertDb.Session.CreateCriteria<TIndexModel>
              .OrderBy(TOrderBy.Asc('SORT_ORDER'))
              .ToList;

  for pseIndex in indeces do
  begin
    CreateStockPriceFrame(scrollIndeces, pseIndex.AltIndexSymbol, pseIndex.IndexName, []);
  end;

  // download most active
  activityDownloader := TStockActivityDownloader.Create(TActivityDownloadType.MostActive);
  activityDownloader.Execute(nil, nil,
    procedure (aStock: TJSONDailySummaryModel)
    begin
      TThread.Synchronize(nil,
      procedure
      begin
        CreateStockPriceFrame(scrollBoxMostActive, aStock.securitySymbol, aStock.securityName, [])
      end);
    end);

  // top gainers
  activityDownloader := TStockActivityDownloader.Create(TActivityDownloadType.Advance);
  activityDownloader.Execute(nil, nil,
    procedure (aStock: TJSONDailySummaryModel)
    begin
      TThread.Synchronize(nil,
      procedure
      begin
        CreateStockPriceFrame(scrollBoxGainers, aStock.securitySymbol, aStock.securityName, [])
      end);
    end);

  // top losers
  activityDownloader := TStockActivityDownloader.Create(TActivityDownloadType.Decline);
  activityDownloader.Execute(nil, nil,
    procedure (aStock: TJSONDailySummaryModel)
    begin
      TThread.Synchronize(nil,
      procedure
      begin
        CreateStockPriceFrame(scrollBoxLosers, aStock.securitySymbol, aStock.securityName, [])
      end);
    end);

  mainView := View as TfrmMain;

  alertModels := stockAlertRepository.GetStockAlerts;
  fAlertEntryController := CreateStockAlertEntryController(alertModels, mainView.tabAlerts);
  fSettingsController := CreatePSEAlertSettingsController(PSEAlertSettings, mainView.tabAbout);

end;

procedure TMainFormController.MainFormClose(Sender: TObject; var Action: TCloseAction);
var
  mainView: TfrmMain;
begin
  mainView := Self.View as TfrmMain;
  Timer1.Enabled := false;
  PSEAlertSettings.FormLeft :=  mainView.Left;
  PSEAlertSettings.FormTop := mainView.Top;
  PSEAlertSettings.FormWidth := mainView.Width;
  PSEAlertSettings.FormHeight := mainView.Height;
  MessengerInstance.UnRegisterAll;
end;

procedure TMainFormController.MainFormCreate(Sender: TObject);
begin
  InitializeForm;
end;

procedure TMainFormController.Receive(const aMessage: IMessage);
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
  if aMessage is TNoDataMessage<TIntradayModel> then
  begin
    SetStatusText('');
  end
  else
  if aMessage is TReloadDataMessage<TStockModel> then
  begin
    ReloadComboStockList(cmbAddStock);
  end
  else
  if aMessage is TAddStockToWatchListMessage then
  begin
    AddStockToWatchList((aMessage as TAddStockToWatchListMessage).Data);
  end
  else
  if aMessage is TAddStockAlertMessage then
  begin
    frmMain.PageControl.ActivePage := frmMain.tabAlerts;

  end;
{$IFNDEF FMXAPP}
  if aMessage is TAlertTriggeredMessage then
  begin
    //FlashTaskbarIcon;
    FlashWindow(frmMain.Handle, true);
  end;
{$ENDIF}
end;

procedure TMainFormController.ReloadComboStockList(const aComboBox:{$IFDEF FMXAPP}TComboEdit{$ELSE}TComboBox{$ENDIF});
var
  stocks: IList<TStockModel>;
  stock: TStockModel;
begin
  aComboBox.Clear;

  stocks := PSEAlertDb.Session.FindAll<TStockModel>();
  for stock in stocks do
  begin
//    if stock.Symbol[1] <> '^' then
    aComboBox.Items.Add(stock.Symbol);
  end;

  aComboBox.ItemIndex := 0;
end;

procedure TMainFormController.SetStatusText(const aStatus: string);
begin
{$IFDEF FMXAPP}
  lblStatusText.Text := aStatus;
{$ELSE}
  StatusBar1.SimpleText := aStatus;
{$ENDIF}
end;

procedure TMainFormController.TriggerTimer1(Sender: TObject);
begin
  Timer1.Enabled := false;
  try
    actRefresh.Execute;
  finally
    Timer1.Enabled := true;
  end;
end;

procedure TMainFormController.TriggerTimer2(Sender: TObject);
begin
  Timer2.Enabled := false;
  actRefresh.Execute;
  Timer1.Enabled := PSEAlertSettings.PollInterval > 0;
end;

end.
