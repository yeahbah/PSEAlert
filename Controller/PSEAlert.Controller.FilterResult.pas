unit PSEAlert.Controller.FilterResult;

interface

uses
  Controller.Base,
  SvBindings,
  Generics.Collections,
  PSE.Data.Model,
  Forms,
  Grids;

type
  TFilterResultController = class(TBaseController<TList<TStockAttribute>>)
  private
    [Bind]
    gridResult: TStringGrid;
  protected
    procedure Initialize; override;
  public
    procedure LoadResult;
  end;

function CreateFilterResultController(aModel: TList<TStockAttribute>): IController<TList<TStockAttribute>>;

implementation

uses PSEAlert.Forms.FilterResult, Yeahbah.GenericQuery, Classes,
  Yeahbah.ObjectClone;

function CreateFilterResultController(aModel: TList<TStockAttribute>): IController<TList<TStockAttribute>>;
begin
  TControllerFactory<TList<TStockAttribute>>.RegisterFactoryMethod(TfrmFilterResult,
    function: IController<TList<TStockAttribute>>
    var
      frm: TfrmFilterResult;
      models: TList<TStockAttribute>;
    begin
      frm := TfrmFilterResult.Create(Application);

      // clone them objects so this controller can manage them
      models := TObjectList<TStockAttribute>.Create;
      TGenericQuery<TStockAttribute>.Foreach(aModel,
        procedure (s: TStockAttribute)
        begin
          models.Add(TObjectClone.From<TStockAttribute>(s));
        end);

      result := TFilterResultController.Create(models, frm);
      result.AutoFreeModel := true;

      frm.Left := Application.MainForm.Width + 10;
      frm.Top := Application.MainForm.Top + 100;
      frm.Show;
    end);
  result := TControllerFactory<TList<TStockAttribute>>.GetInstance(TfrmFilterResult);
end;

{ TFilterResultController }

procedure TFilterResultController.Initialize;
begin
  inherited;
  LoadResult;
end;

procedure TFilterResultController.LoadResult;
var
  tmpList: TStringList;
  stockAttr: TStockAttribute;
  i, colCount, rowCount, col, row: integer;
begin
  gridResult.RowCount := 0;
  gridResult.ColCount := 0;

  if Model.Count = 0 then
    Exit;

  gridResult.ColCount := 1;
  gridResult.RowCount := 1;
  gridResult.Rows[0].Add('Symbol');
  colCount := 1;
  rowCount := 1;
  for stockAttr in Model do
  begin

    // header
    if gridResult.Rows[0].IndexOf(stockAttr.AttributeDisplayText) < 0 then
    begin
      inc(colCount);
      gridResult.ColCount := colCount;
      col := gridResult.Rows[0].Add(stockAttr.AttributeDisplayText);
    end;

    // data
    row := gridResult.Cols[0].IndexOf(stockAttr.Symbol);
    if row <= 0 then
    begin
      inc(rowCount);
      gridResult.RowCount := rowCount;
      row := gridResult.Cols[0].Add(stockAttr.Symbol);
    end;

    col := gridResult.Rows[0].IndexOf(stockAttr.AttributeDisplayText);
    if col >= 0 then
      gridResult.Cells[col, row] := stockAttr.AttributeValue;

  end;
  if gridResult.RowCount > 0 then
    gridResult.FixedRows := 1;

  for i := 1 to gridResult.ColCount - 1 do
    gridResult.ColWidths[i] := 90;
end;

end.
