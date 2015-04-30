unit PSEAlert.Frames.StockAlert;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.ActnList, System.Actions, FMX.Controls.Presentation;

type
  TframeStockAlert = class(TFrame)
    btnAlertTriggered: TSpeedButton;
    Panel1: TPanel;
    lblAlertSymbol: TLabel;
    lblAlertDetails: TLabel;
    lblVolumeAlert: TLabel;
    lblNote: TLabel;
    btnDelete: TSpeedButton;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }

  end;

implementation

{$R *.fmx}
{$R PSEAlert.res PSEAlertResource.rc}


end.
