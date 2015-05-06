unit PSEAlert.Service.Filter.PERatioFilter;

interface

uses
  PSEAlert.Service.Filter.StockFilterItemBase,
  PSE.Data.Model,
  Classes,
  Generics.Collections;

type
  TPERatioFilter = class(TStockFilterItemBase)
  private
    fToPE: single;
    fFromPE: single;
  protected
    function GetDescription: string; override;
  public
    constructor Create;
    procedure Run(aResult: TList<TStockAttribute>); override;
    property Description: string read GetDescription;
    property FromPE: single read fFromPE write fFromPE;
    property ToPE: single read fToPE write fToPE;
  end;

implementation

{ TPERatioFilter }

uses
  PSE.Data, Yeahbah.GenericQuery, SysUtils;

constructor TPERatioFilter.Create;
begin
  inherited Create;
  fFromPE := 10;
  fToPE := 25;
end;

function TPERatioFilter.GetDescription: string;
begin
  result := 'P/E Ratio';
end;

procedure TPERatioFilter.Run(aResult: TList<TStockAttribute>);
var
  stocks, tmp: TList<TStockAttribute>;
begin
  stocks := TGenericQuery<TStockAttribute>.From(aResult)
    .Where(
      function(s: TStockAttribute): boolean
      begin
        result := s.AttributeKey = 'PE';
        result := result and (StrToFloat(s.AttributeValue) >= fFromPE);
        result := result and (StrToFloat(s.AttributeValue) <= fToPE);
      end).ToList;

  tmp := TGenericQuery<TStockAttribute>.From(aResult)
    .Where(
      function (s: TStockAttribute): boolean
      begin
        result := TGenericQuery<TStockAttribute>.From(stocks)
          .Count(
            function (x: TStockAttribute): boolean
            begin
              result := x.Symbol = s.Symbol;
            end) > 0;
      end).ToList;

  aResult.Clear;
  aResult.AddRange(tmp.ToArray);

  stocks.Free;
  tmp.Free;

end;

end.
