unit PSEAlert.FMX.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl, FMX.ListBox, FMX.Layouts, System.Actions, FMX.ActnList,
  FMX.Edit, FMX.ComboEdit, FMX.Controls.Presentation;

type
  TfrmMain = class(TForm)
    ActionList1: TActionList;
    actRefresh: TAction;
    actAdd: TAction;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    PageControl: TTabControl;
    tabWatchList: TTabItem;
    tabIndeces: TTabItem;
    tabAlerts: TTabItem;
    tabAbout: TTabItem;
    lblStatusText: TLabel;
    scrollIndeces: TScrollBox;
    SpeedButton2: TSpeedButton;
    Label2: TLabel;
    actSortAsc: TAction;
    actSortDesc: TAction;
    actRefreshMostActive: TAction;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    btnAddStock: TButton;
    Label3: TLabel;
    btnRefresh: TSpeedButton;
    Label1: TLabel;
    cmbAddStock: TComboEdit;
    scrollMyStocks: TScrollBox;
    SpeedButton1: TSpeedButton;
    scrollBoxMostActive: TScrollBox;
    scrollBoxGainers: TScrollBox;
    scrollBoxLosers: TScrollBox;
    btnSort: TSpeedButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  PageControl.ActiveTab := tabWatchList;
end;

end.
