unit PSEAlert.Test.MainFormController;

interface

uses
  DUnitX.TestFramework, PSEAlert.Controller.MainForm;

type

  [TestFixture]
  TMainFormControllerTest = class(TObject)
  private
    fMainFormController: TMainFormController;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    procedure Test_VisualControlEvents;

    procedure Test_Rcv_ReloadDataMessage;

  end;

implementation


{ TMainFormControllerTest }

procedure TMainFormControllerTest.Setup;
begin
  fMainFormController := TMainFormController.Create(nil, nil);
end;

procedure TMainFormControllerTest.TearDown;
begin
  fMainFormController.Free;
end;

procedure TMainFormControllerTest.Test_Rcv_ReloadDataMessage;
begin

end;

procedure TMainFormControllerTest.Test_VisualControlEvents;
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TMainFormControllerTest);
end.
