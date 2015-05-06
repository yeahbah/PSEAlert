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
  DSharp.Bindings,
  SvBindings.Converters.DWScript;

type
  TStockDetailsController = class(TBaseController<TStockHeaderModel>, IMessageReceiver)
  private
    {$HINTS OFF}
    [Bind]
    lblStockName: TLabel;

    [BindExpression('LastTradedPrice', 'Caption', 'FormatFloat(''#,##0.####'', LastTradedPrice)', '')]
    lblLastTradePrice: TLabel;

    [BindExpression('ChangeClose', 'Caption', 'FormatFloat(''0.##'', ChangeClose)', '')]
    lblChange: TLabel;

    [BindExpression('ChangeClosePercentage', 'Caption', 'FormatFloat(''0.##'', ChangeClosePercentage)', '')]
    lblPctChange: TLabel;

    [BindExpression('TotalValue', 'Caption', 'FormatFloat(''#,##0.##'', TotalValue)', '')]
    lblValue: TLabel;

    [BindExpression('TotalVolume', 'Caption', 'FormatFloat(''#,##0'', TotalVolume)', '')]
    lblVolume: TLabel;

    [BindExpression('IntradayOpen', 'Caption', 'FormatFloat(''#,##0.####'', IntradayOpen)', '')]
    lblOpen: TLabel;

    [BindExpression('IntradayHigh', 'Caption', 'FormatFloat(''#,##0.####'', IntradayHigh)', '')]
    lblHigh: TLabel;

    [BindExpression('IntradayLow', 'Caption', 'FormatFloat(''#,##0.####'', IntradayLow)', '')]
    lblLow: TLabel;

    [BindExpression('AvgPrice', 'Caption', 'FormatFloat(''#,##0.####'', AvgPrice)', '')]
    lblAvgPrice: TLabel;

    [BindExpression('PreviousClose', 'Caption', 'FormatFloat(''#,##0.####'', PreviousClose)', '')]
    lblPrevClose: TLabel;

    [BindExpression('CurrentPE', 'Caption', 'FormatFloat(''#,##0.##'', CurrentPE)', '')]
    lblPERatio: TLabel;

    [BindExpression('FiftyTwoWeekHigh', 'Caption', 'FormatFloat(''#,##0.####'', FiftyTwoWeekHigh)', '')]
    lbl52WkHigh: TLabel;

    [BindExpression('FiftyTwoWeekLow', 'Caption', 'FormatFloat(''#,##0.####'', FiftyTwoWeekLow)', '')]
    lbl52WkLow: TLabel;

    [Bind]
    actRefresh: TAction;

    [Bind]
    actAddAlert: TAction;
    {$HINTS ON}
    fStockId: integer;
  protected
    procedure Initialize; override;
    procedure DoExecuteRefreshAction(Sender: TObject);
    procedure DoExecuteAddAlertAction(Sender: TObject);
  public
    destructor Destroy; override;
    procedure Receive(const aMessage: IMessage);
    property StockId: integer read fStockId;
  end;

function CreateStockDetailsController(aOwner: TComponent; aModel: TStockHeaderModel): IController<TStockHeaderModel>;

implementation

uses PSEAlert.Forms.StockDetails, Forms, PSEAlert.Messages, PSE.Data.Downloader,
  PSE.Data,
  Spring.Persistence.Criteria.Interfaces,
  Spring.Persistence.Criteria.Restrictions,
  UITypes, Yeahbah.ObjectClone, PSE.Data.Repository;

function CreateStockDetailsController(aOwner: TComponent; aModel: TStockHeaderModel): IController<TStockHeaderModel>;
begin
  TControllerFactory<TStockHeaderModel>.RegisterFactoryMethod(TfrmStockDetails,
    function: IController<TStockHeaderModel>
    var
      frm: TfrmStockDetails;
      s: TStockHeaderModel;
    begin

      frm := TfrmStockDetails.Create(aOwner);
      s := TObjectClone.From<TStockHeaderModel>(aModel);
      result := TStockDetailsController.Create(s, frm);

      TStockDetailsController(result).AutoFreeModel := true;

      frm.Caption := aModel.Symbol;

      frm.Show;
    end);
  result := TControllerFactory<TStockHeaderModel>.GetInstance(TfrmStockDetails);
end;

{ TStockDetailsController }

destructor TStockDetailsController.Destroy;
begin

  inherited;
end;

procedure TStockDetailsController.DoExecuteAddAlertAction(Sender: TObject);
begin
  MessengerInstance.SendMessage(TAddStockAlertMessage.Create(self.Model.Symbol));
end;

procedure TStockDetailsController.DoExecuteRefreshAction(Sender: TObject);
var
  downloader: TStockDetail_HeaderDownloader;
  stockModel: TStockModel;
begin
  if self.Model.Symbol[1] <> '^' then
  begin

    stockModel := PSEAlertDb.Session.CreateCriteria<TStockModel>
      .Add(
        TRestrictions.Eq('SYMBOL', Model.Symbol.ToUpper))
      .ToList.SingleOrDefault(nil);
    if stockModel <> nil then
    begin
      {$IFDEF FMXAPP}
      lblStockName.Text := stockModel.Description;
      {$ELSE}
      lblStockName.Caption := stockModel.Description;
      {$ENDIF}
      downloader := TStockDetail_HeaderDownloader.Create(stockModel.SecurityId);
      downloader.ExecuteAsync(
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
            var
              stockAttr: TStockAttribute;
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

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'PE';
                stockAttr.AttributeValue := aStock.CurrentPE.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'FiftyTwoWeekLow';
                stockAttr.AttributeValue := aStock.FiftyTwoWeekLow.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'FiftyTwoWeekHigh';
                stockAttr.AttributeValue := aStock.FiftyTwoWeekHigh.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'LastTradedPrice';
                stockAttr.AttributeValue := aStock.LastTradedPrice.ToString;
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

              stockAttr := TStockAttribute.Create;
              try
                stockAttr.Symbol := aStock.Symbol;
                stockAttr.AttributeKey := 'LastTradedDate';
                stockAttr.AttributeValue := DateToStr(aStock.LastTradedDate);
                stockAttributeRepository.Update(stockAttr);
              finally
                stockAttr.Free;
              end;

            end);
        end)
    end;

  end;
  //
end;

procedure TStockDetailsController.Initialize;
var
  stockModel: TStockModel;
begin
  inherited;
  //MessengerInstance.RegisterReceiver(self, TAfterDownloadMessage);

  actRefresh.OnExecute := DoExecuteRefreshAction;
  actAddAlert.OnExecute := DoExecuteAddAlertAction;

  stockModel := PSEAlertDb.Session.CreateCriteria<TStockModel>
    .Add(TRestrictions.Eq('SYMBOL', Model.Symbol.ToUpper)).ToList.SingleOrDefault(nil);
  if stockModel <> nil then
{$IFDEF FMXAPP}
    lblStockName.Text := stockModel.Description;
{$ELSE}
    lblStockName.Caption := stockModel.Description;
{$ENDIF}

end;

procedure TStockDetailsController.Receive(const aMessage: IMessage);
begin
//  if aMessage is TAfterDownloadMessage then
//  begin
//    if (aMessage as TAfterDownloadMessage).Data > 0 then
//      lblLastUpdateDateTime.Caption := 'As of ' + DateTimeToStr((aMessage as TAfterDownloadMessage).Data)
//    else
//      lblLastUpdateDateTime.Caption := 'Market Pre-Open';
//  end;
end;

end.
