unit PSEAlert.Frames.StockPrice;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Controls.Presentation;

type
  TframeStockPrice = class(TFrame)
    lblStockSymbol: TLabel;
    lblStockName: TLabel;
    stockInfoPanel: TPanel;
    lblStockVolume: TLabel;
    btnClose: TSpeedButton;
    btnAlert: TSpeedButton;
    Label1: TLabel;
    lblStockPrice: TLabel;
  private
    { Private declarations }
    imgStatus: TImage;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent); override;
  end;

implementation

{$R *.fmx}

{ TframeStockPrice }

constructor TframeStockPrice.Create(aOwner: TComponent);
var
  imgAlert: TImage;
  res: TResourceStream;
begin
  inherited;
  imgStatus := TImage.Create(stockInfoPanel);
  stockInfoPanel.AddObject(imgStatus);

  imgStatus.Width := 24;
  imgStatus.Height := 24;
  imgStatus.Position.X := 3;
  imgStatus.Position.Y := 8;

  imgAlert := TImage.Create(btnAlert);
  res := TResourceStream.Create(hInstance, 'bell_alert', RT_RCDATA);
  try
    btnAlert.AddObject(imgAlert);
    imgAlert.Align := TAlignLayout.Client;
    imgAlert.Bitmap.LoadFromStream(res);
  finally
    res.Free;
  end;
  btnAlert.Visible := false;

end;

end.
