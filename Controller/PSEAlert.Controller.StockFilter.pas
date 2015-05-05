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
  Generics.Collections;

type
  TStockFilterController = class(TBaseController<TList<TStockFilterItemBase>>)
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
  protected
    procedure Initialize; override;
    procedure ExecuteRunAction(Sender: TObject);
    procedure ExecuteClearAllAction(Sender: TObject);
    procedure ExecuteAddFilterAction(Sender: TObject);
    procedure ExecuteReloadDataAction(Sender: TObject);

  public

  end;

function CreateStockFilterController(aOwner: TWinControl): IController<TList<TStockFilterItemBase>>;

implementation

uses
  PSEAlert.Frames.StockFilter, PSE.Data.Downloader,
  Spring.Collections, PSE.Data.Model, PSE.Data, SysUtils,
  PSEAlert.Service.StockFilterService,
  Yeahbah.GenericQuery;

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

procedure TStockFilterController.ExecuteAddFilterAction(Sender: TObject);
var
  stockFilterItem: TStockFilterItemBase;
  pair: TPair<TStockFilterItemBase, TFilterControllerMethod>;
begin

  for pair in StockFilterService.StockFilters do
  begin
    if pair.Key.Description = cmbFilter.Text then
    begin
      pair.Value(scrollFilter, pair.Key);
      Model.Add(pair.Key);
      exit;
    end;
  end;

end;

procedure TStockFilterController.ExecuteClearAllAction(Sender: TObject);
begin

end;

procedure TStockFilterController.ExecuteReloadDataAction(Sender: TObject);
var
  downloader: TStockDetail_HeaderDownloader;
  stocks: IList<TStockModel>;

begin
  PSEAlertDb.Session.Execute('DELETE FROM STOCK_ATTRIBUTE', []);
  stocks := PSEAlertDb.Session.FindAll<TStockModel>;
  stocks.ForEach(
    procedure (const stock: TStockModel)
    begin
      downloader := TStockDetail_HeaderDownloader.Create(stock.SecurityId);
      downloader.ExecuteAsync(
        procedure
        begin

        end,
        procedure
        begin

        end,
        procedure (s: TStockHeaderModel)
        begin
          TThread.Synchronize(nil,
            procedure
            var
              stockAttrib: TStockAttribute;
            begin
              stockAttrib := TStockAttribute.Create;
              try
                stockAttrib.Symbol := s.Symbol;
                stockAttrib.AttributeKey := 'PE';
                stockAttrib.AttributeValue := s.CurrentPE.ToString;
                stockAttrib.AttributeType := 'single';
                PSEAlertDb.Session.Save(stockAttrib);
              finally
                stockAttrib.Free;
              end;

              stockAttrib := TStockAttribute.Create;
              try
                stockAttrib.Symbol := s.Symbol;
                stockAttrib.AttributeKey := 'FiftyTwoWeekLow';
                stockAttrib.AttributeValue := s.FiftyTwoWeekLow.ToString;
                stockAttrib.AttributeType := 'single';
                PSEAlertDb.Session.Save(stockAttrib);
              finally
                stockAttrib.Free;
              end;

              stockAttrib := TStockAttribute.Create;
              try
                stockAttrib.Symbol := s.Symbol;
                stockAttrib.AttributeKey := 'FiftyTwoWeekHigh';
                stockAttrib.AttributeValue := s.FiftyTwoWeekHigh.ToString;
                stockAttrib.AttributeType := 'single';
                PSEAlertDb.Session.Save(stockAttrib);
              finally
                stockAttrib.Free;
              end;

            end);
        end);
    end);
end;

procedure TStockFilterController.ExecuteRunAction(Sender: TObject);
begin
  if scrollFilter.ControlCount > 0 then
  begin

  end;
end;

procedure TStockFilterController.Initialize;
var
  stockFilterItem: TPair<TStockFilterItemBase, TFilterControllerMethod>;
begin
  inherited;
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

end.
