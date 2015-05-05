unit PSEAlert.Service.Types;

interface

uses
  Generics.Collections;

type
  TFilterResult = class
  private
    fStockSymbol: string;
    fStockAttribute: TDictionary<string, string>;
  public
    constructor Create(const aStockSymbol: string);
    destructor Destroy; override;
    property StockAttribute: TDictionary<string, string> read fStockAttribute;
    property StockSymbol: string read fStockSymbol;
  end;

implementation

{ TFilterResult }

constructor TFilterResult.Create(const aStockSymbol: string);
begin
  fStockSymbol := aStockSymbol;
  fStockAttribute := TDictionary<string, string>.Create;
end;

destructor TFilterResult.Destroy;
begin
  fStockAttribute.Free;
  inherited;
end;

end.
