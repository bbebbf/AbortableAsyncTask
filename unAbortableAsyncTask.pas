unit unAbortableAsyncTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  AbortableAsyncTask.Types;

type
  TfmMain = class(TForm, IAbortableAsyncProgressIndicator<Integer>)
    ProgressBar: TProgressBar;
    btTaskStart: TButton;
    btRequestAbort: TButton;
    btAwait: TButton;
    ProgressBar1: TProgressBar;
    procedure FormDestroy(Sender: TObject);
    procedure btAwaitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btTaskStartClick(Sender: TObject);
    procedure btRequestAbortClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    fAbortableAsyncTaskList: IAbortableAsyncTaskList;
    procedure ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
    procedure ProgressEnd(const aKey: Integer);
    procedure ProgressStep(const aKey: Integer; const aWorkCount: Int64);
    function GetProgressBar(const aKey: Integer): TProgressBar;
  public
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses AbortableAsyncTask.List, AbortableAsyncTask.Runner, ExampleTask;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fAbortableAsyncTaskList := nil;
end;

procedure TfmMain.btAwaitClick(Sender: TObject);
begin
  var lTaskRunner := fAbortableAsyncTaskList.First;
  if not Assigned(lTaskRunner) then
    Exit;

  var lTaskRunnerInteger: IAbortableAsyncTaskRunner<Integer>;
  if Supports(lTaskRunner, IAbortableAsyncTaskRunner<Integer>, lTaskRunnerInteger) then
  begin
    var lAwaitResult := lTaskRunnerInteger.WaitForTaskResult;
    ShowMessage('Result=' + IntToStr(lAwaitResult.Result) + sLineBreak + sLineBreak +
     'FinishedState=' + IntToStr(Ord(lAwaitResult.FinishedState)) + sLineBreak +
     'ExceptionClass=' + lAwaitResult.ExceptionClass.ClassName + sLineBreak +
     'ExceptionMessage=' + lAwaitResult.ExceptionMessage);
  end;

end;

procedure TfmMain.btRequestAbortClick(Sender: TObject);
begin
  var lTask := fAbortableAsyncTaskList.First;
  if not Assigned(lTask) then
    Exit;

  lTask.RequestAbort;
end;

procedure TfmMain.btTaskStartClick(Sender: TObject);
begin
  var lTask: IAbortableAsyncTask<Integer, Integer> := TExampleTask.Create(fAbortableAsyncTaskList.Count + 1, Self);
  var lAbortableAsyncTaskRunner := TAbortableAsyncTaskRunner<Integer, Integer>.New(lTask, fAbortableAsyncTaskList);
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if fAbortableAsyncTaskList.Count > 0 then
  begin
    if MessageDlg('Sollen die laufenden Downloads abgebrochen werden?', TMsgDlgType.mtConfirmation,
      mbYesNo, 0, TMsgDlgBtn.mbYes) = mrYes then
    begin
      if fAbortableAsyncTaskList.Count > 0 then
      begin
        fAbortableAsyncTaskList.RequestAbortToAllAndWait;
      end;
    end
    else
    begin
      CanClose := False;
    end;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  ProgressBar.Visible := False;
  ProgressBar1.Visible := False;
  fAbortableAsyncTaskList := TAbortableAsyncTaskList.Create;
end;

procedure TfmMain.ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
begin
  GetProgressBar(aKey).Position := 0;
  GetProgressBar(aKey).Min := 0;
  GetProgressBar(aKey).Max := aMaxWorkCount;
  GetProgressBar(aKey).Visible := True;
end;

procedure TfmMain.ProgressEnd(const aKey: Integer);
begin
  GetProgressBar(aKey).Position := 0;
  GetProgressBar(aKey).Visible := False;
end;

procedure TfmMain.ProgressStep(const aKey: Integer; const aWorkCount: Int64);
begin
  GetProgressBar(aKey).Position := aWorkCount;
end;

function TfmMain.GetProgressBar(const aKey: Integer): TProgressBar;
begin
  case aKey of
    2: Result := ProgressBar1;
    else Result := ProgressBar;
  end;
end;

end.
