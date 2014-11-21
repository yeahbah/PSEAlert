unit PSEAlert.Frames.StockPrice;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Buttons, Vcl.ImgList, Vcl.Menus;

type
  TframeStockPrice = class(TFrame)
    lblStockSymbol: TLabel;
    lblStockName: TLabel;
    lblStockPrice: TLabel;
    lblStockVolume: TLabel;
    Bevel1: TBevel;
    btnClose: TSpeedButton;
    imgStatus: TImage;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    NewAlert1: TMenuItem;
    btnAlert: TSpeedButton;
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TframeStockPrice }

constructor TframeStockPrice.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  lblStockPrice.Font.Size := 11;
  lblStockName.Font.Size := 9;
  lblStockSymbol.Font.Size := 12;
  lblStockVolume.Font.Size := 9;

  lblStockPrice.Caption := '';
  lblStockVolume.Caption := '';
end;

destructor TframeStockPrice.Destroy;
begin

  inherited;
end;


end.
