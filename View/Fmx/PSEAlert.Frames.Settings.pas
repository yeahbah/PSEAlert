unit PSEAlert.Frames.Settings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.ListBox, System.Actions, FMX.ActnList, FMX.Controls.Presentation;

type
  TframeSettings = class(TFrame)
    btnReloadData: TButton;
    edtOpenWav: TEdit;
    chkPlaySound: TCheckBox;
    cmbInterval: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    btnOpenWav: TButton;
    ActionList: TActionList;
    actReloadData: TAction;
    actOpenWav: TAction;
    Label5: TLabel;
    Label6: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

end.
