unit PSEAlert.Controller.StockDetails;

interface

uses
  Controller.Base,
  SvBindings,
  ExtCtrls,
  Yeahbah.Messaging,
  ActnList,
  PSE.Data.Model,
  StdCtrls,
  SysUtils,
  Classes,
  DSharp.Bindings;

type
  TStockDetailsController = class(TBaseController<TStockHeaderModel>, IMessageReceiver)
  private
    {$HINTS OFF}
    [Bind]
    lblLastUpdateDateTime: TLabel;
    [Bind('LastTradedPrice', 'Caption')]
    lblLastTradePrice: TLabel;
    [Bind('ChangeClose', 'Caption')]
    lblChange: TLabel;
    [Bind('ChangeClosePercentage', 'Caption')]
    lblPctChange: TLabel;
    [Bind('TotalValue', 'Caption')]
    lblValue: TLabel;

    [Bind('TotalVolume', 'Caption', TBindingMode.bmOneWay, Ord(TBindConverterType.bctIntegerToString))]
    lblVolume: TLabel;

    [Bind('IntradayOpen', 'Caption')]
    lblOpen: TLabel;

    [Bind('IntradayHigh', 'Caption')]
    lblHigh: TLabel;

    [Bind('IntradayLow', 'Caption')]
    lblLow: TLabel;

    [Bind('AvgPrice', 'Caption')]
    lblAvgPrice: TLabel;

    [Bind]
    actRefresh: TAction;
    {$HINTS ON}
    fStockId: integer;
  protected
    procedure Initialize; override;
    procedure DoExecuteRefreshAction(Sender: TObject);
  public
    procedure Receive(const aMessage: IMessage);
    property StockId: integer read fStockId;
  end;

function CreateStockDetailsController(aOwner: TComponent; aModel: TStockHeaderModel): IController<TStockHeaderModel>;

implementation

uses PSEAlert.Forms.StockDetails, Forms, PSEAlert.Messages, PSE.Data.Downloader,
  PSE.Data,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions,
  UITypes;

function CreateStockDetailsController(aOwner: TComponent; aModel: TStockHeaderModel): IController<TStockHeaderModel>;
begin
  TControllerFactory<TStockHeaderModel>.RegisterFactoryMethod(TfrmStockDetails,
    function: IController<TStockHeaderModel>
    var
      frm: TfrmStockDetails;
    begin
      frm := TfrmStockDetails.Create(aOwner);

      result := TStockDetailsController.Create(aModel, frm);
      TStockDetailsController(result).AutoFreeModel := true;

      frm.Caption := aModel.Symbol;

      frm.Show;
    end);
  result := TControllerFactory<TStockHeaderModel>.GetInstance(TfrmStockDetails);
end;

{ TStockDetailsController }

procedure TStockDetailsController.DoExecuteRefreshAction(Sender: TObject);
var
  downloader: TStockDetail_HeaderDownloader;
  stockModel: TStockModel;
begin
  if self.Model.Symbol[1] <> '^' then
  begin

    stockModel := PSEAlertDb.Session.CreateCriteria<TStockModel>
      .Add(TRestrictions.Eq('SYMBOL', Model.Symbol.ToUpper)).ToList.SingleOrDefault(nil);
    if stockModel <> nil then
    begin
      downloader := TStockDetail_HeaderDownloader.Create(stockModel.SecurityId);
      downloader.Execute(
        procedure
        begin
          Application.MainForm.Cursor := crHourGlass;
        end,
        procedure
        begin
          Application.MainForm.Cursor := crDefault;
        end,
        procedure (aStock: TStockHeaderModel)
        begin
          TThread.Synchronize(nil,
            procedure
            begin
              Model.Symbol := aStock.Symbol;
              Model.FiftyTwoWeekHigh := aStock.FiftyTwoWeekHigh;
              Model.FiftyTwoWeekLow := aStock.FiftyTwoWeekLow;
              Model.PreviousClose := aStock.PreviousClose;
              Model.ChangeClose := aStock.ChangeClose;
              Model.ChangeClosePercentage := aStock.ChangeClosePercentage;
              Model.LastTradedDate := aStock.LastTradedDate;
              Model.LastTradedPrice := aStock.LastTradedPrice;
              Model.TotalValue := aStock.TotalValue;
              Model.TotalVolume := aStock.TotalVolume;
              Model.IntradayLow := aStock.IntradayLow;
              Model.IntradayHigh := aStock.IntradayHigh;
              Model.IntradayOpen := aStock.IntradayOpen;
              Model.AvgPrice := aStock.AvgPrice;
              Model.CurrentPE := aStock.CurrentPE;
            end);
        end)
    end;

  end;
  //
end;

procedure TStockDetailsController.Initialize;
begin
  inherited;
  MessengerInstance.RegisterReceiver(self, TAfterDownloadMessage);

  actRefresh.OnExecute := DoExecuteRefreshAction;
end;

procedure TStockDetailsController.Receive(const aMessage: IMessage);
begin
  if aMessage is TAfterDownloadMessage then
  begin
    if (aMessage as TAfterDownloadMessage).Data > 0 then
      lblLastUpdateDateTime.Caption := 'As of ' + DateTimeToStr((aMessage as TAfterDownloadMessage).Data)
    else
      lblLastUpdateDateTime.Caption := 'Market Pre-Open';
  end;
end;

end.
