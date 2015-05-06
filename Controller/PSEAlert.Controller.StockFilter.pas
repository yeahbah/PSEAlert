unit PSEAlert.Controller.StockFilter;

interface

uses
  Controller.Base,
  SvBindings,
  Classes,
  Controls,
  StdCtrls,
  ActnList,
  Forms,
  PSEAlert.Service.Filter.StockFilterItemBase,
  Generics.Collections,
  PSEAlert.Controller.FilterResult,
  PSE.Data.Model,
  Yeahbah.Messaging;

type
  TStockFilterController = class(TBaseController<TList<TStockFilterItemBase>>, IMessageReceiver)
  private
    [Bind]
    cmbFilter: TComboBox;
    [Bind]
    actReloadData: TAction;
    [Bind]
    actClearAll: TAction;
    [Bind]
    actRun: TAction;
    [Bind]
    actAddFilter: TAction;
    [Bind]
    scrollFilter: TScrollBox;
    fFilterResult: IController<TList<TStockAttribute>>;
    fFilterControllers: TList<IController<TStockFilterItemBase>>;
  protected
    procedure Initialize; override;
    procedure ExecuteRunAction(Sender: TObject);
    procedure ExecuteClearAllAction(Sender: TObject);
    procedure ExecuteAddFilterAction(Sender: TObject);
    procedure ExecuteReloadDataAction(Sender: TObject);

  public
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
  end;

function CreateStockFilterController(aOwner: TWinControl): IController<TList<TStockFilterItemBase>>;

implementation

uses
  PSEAlert.Frames.StockFilter, PSE.Data.Downloader,
  Spring.Collections, PSE.Data, SysUtils,
  PSEAlert.Service.StockFilterService,
  Yeahbah.GenericQuery, PSE.Data.Repository, PSEAlert.Messages;

function CreateStockFilterController(aOwner: TWinControl): IController<TList<TStockFilterItemBase>>;
begin
 TControllerFactory<TList<TStockFilterItemBase>>.RegisterFactoryMethod(TframeStockFilter,
    function: IController<TList<TStockFilterItemBase>>
    var
      frm: TframeStockFilter;
    begin
      frm := TframeStockFilter.Create(aOwner);
      {$IFDEF FMXAPP}
      aParent.AddObject(frm);
      {$ELSE}
      frm.Parent := aOwner;
      {$ENDIF}
      frm.Align := {$IFDEF FMXAPP}TAlignLayout.Top{$ELSE}alClient{$ENDIF};


      result := TStockFilterController.Create(TList<TStockFilterItemBase>.Create, frm);
      result.AutoFreeModel := true;

      frm.Visible := true;
    end);
  result := TControllerFactory<TList<TStockFilterItemBase>>.GetInstance(TframeStockFilter);
end;

{ TStockFilterController }

destructor TStockFilterController.Destroy;
begin
  fFilterControllers.Free;
  inherited;
end;

procedure TStockFilterController.ExecuteAddFilterAction(Sender: TObject);
var
  pair: TPair<TStockFilterItemBase, TFilterControllerMethod>;
begin
  for pair in StockFilterService.StockFilters do
  begin
    if pair.Key.Description = cmbFilter.Text then
    begin
      if Model.IndexOf(pair.Key) >= 0 then
        Exit;
      Model.Add(pair.Key);
      fFilterControllers.Add(pair.Value(scrollFilter, pair.Key));
      exit;
    end;
  end;

end;

procedure TStockFilterController.ExecuteClearAllAction(Sender: TObject);
var
  p: TControl;
begin
  while scrollFilter.ControlCount > 0 do
  begin
    p := scrollFilter.Controls[0];
    try
      scrollFilter.RemoveControl(scrollFilter.Controls[0]);
    finally
      p.Free;
    end;
  end;
  Model.Clear;
  fFilterControllers.Clear;
end;

procedure TStockFilterController.ExecuteReloadDataAction(Sender: TObject);
var
  downloader: TStockDetail_HeaderDownloader;
  stocks: IList<TStockModel>;

begin
  stockAttributeRepository.DeleteAll;
  stocks := PSEAlertDb.Session.FindAll<TStockModel>;
  try
    actClearAll.Enabled := false;
    actAddFilter.Enabled := false;
    actRun.Enabled := false;
    stocks.ForEach(
      procedure (const stock: TStockModel)
      begin
        downloader := TStockDetail_HeaderDownloader.Create(stock.SecurityId);
        downloader.Execute(
  //        procedure
  //        begin
  //          actReloadData.Caption := 'Busy...';
  //        end,
  //        procedure
  //        begin
  //          actReloadData.Caption := 'Reload Data';
  //        end,
          procedure (s: TStockHeaderModel)
          begin
  //          TThread.Synchronize(nil,
  //            procedure
  //            begin
                actReloadData.Caption := 'Updating: ' + s.Symbol;
                Application.ProcessMessages;
                stockAttributeRepository.SaveNewAttribute(s.Symbol, 'PE',
                  s.CurrentPE.ToString, 'single', 'P/E');

                stockAttributeRepository.SaveNewAttribute(s.Symbol, 'FiftyTwoWeekLow',
                  s.FiftyTwoWeekLow.ToString, 'single', '52Wk Low');

                stockAttributeRepository.SaveNewAttribute(s.Symbol, 'FiftyTwoWeekHigh',
                  s.FiftyTwoWeekHigh.ToString, 'single', '52Wk High');

                stockAttributeRepository.SaveNewAttribute(s.Symbol, 'LastTradedPrice',
                  s.LastTradedPrice.ToString, 'single', 'Last Traded Price');

                stockAttributeRepository.SaveNewAttribute(s.Symbol, 'LastTradedDate',
                  DateToStr(s.LastTradedDate), 'date', 'Last Traded Date');

  //            end);
          end);
      end);
  finally
    actReloadData.Caption := 'Reload Data';
    actClearAll.Enabled := true;
    actAddFilter.Enabled := true;
    actRun.Enabled := true;
  end;

end;

procedure TStockFilterController.ExecuteRunAction(Sender: TObject);
var
  stockFilter: TStockFilterItemBase;
  stocks: IList<TStockAttribute>;
  filterResult: TList<TStockAttribute>;

begin
  if scrollFilter.ControlCount > 0 then
  begin
    stocks := PSEAlertDb.Session.FindAll<TStockAttribute>;
    filterResult := TList<TStockAttribute>.Create;
    try
      filterResult.AddRange(stocks.ToArray);
      for stockFilter in Model do
      begin
        stockFilter.Run(filterResult);
      end;

      fFilterResult := CreateFilterResultController(filterResult);
    finally
      filterResult.Free;
    end;
  end;
end;

procedure TStockFilterController.Initialize;
var
  stockFilterItem: TPair<TStockFilterItemBase, TFilterControllerMethod>;
begin
  inherited;
  fFilterControllers := TList<IController<TStockFilterItemBase>>.Create;
  MessengerInstance.RegisterReceiver(self, TCloseFilterMessage);

  actRun.OnExecute := ExecuteRunAction;
  actReloadData.OnExecute := ExecuteReloadDataAction;
  actClearAll.OnExecute := ExecuteClearAllAction;
  actAddFilter.OnExecute := ExecuteAddFilterAction;

  cmbFilter.Items.Clear;
  for stockFilterItem in StockFilterService.StockFilters do
  begin
    cmbFilter.Items.Add(stockFilterItem.Key.Description);
  end;
end;

procedure TStockFilterController.Receive(const aMessage: IMessage);
var
  filterItem: TStockFilterItemBase;
begin
  if aMessage is TCloseFilterMessage then
  begin
    filterItem := TGenericQuery<TStockFilterItemBase>.From(Model)
      .Single(
        function (s: TStockFilterItemBase): boolean
        begin
          result := s.Description = TCloseFilterMessage(aMessage).Data;
        end);
    if filterItem <> nil then
      Model.Remove(filterItem);
  end;
end;

end.
