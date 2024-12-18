unit unFraTask;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls,
  AbortableTask.Types;

type
  TfraTask = class(TFrame, IAbortableProgressIndicator<Integer>)
    ProgressBar: TProgressBar;
    btWaitFor: TButton;
    btAbort: TButton;
    procedure btAbortClick(Sender: TObject);
    procedure btWaitForClick(Sender: TObject);
  private
    fRunner: IAbortableTaskAsyncRunner<Integer>;
    procedure ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
    procedure ProgressEnd(const aKey: Integer);
    procedure ProgressStep(const aKey: Integer; const aWorkCount: Int64);
  public
    procedure NewTask(const aTask: IAbortableTask<Integer, Integer>; const aRunnerList: IAbortableTaskAsyncRunnerList);
  end;

implementation

{$R *.dfm}

uses AbortableTask.Async.Runner;

{ TfraTask }

procedure TfraTask.btAbortClick(Sender: TObject);
begin
  fRunner.RequestAbort;
end;

procedure TfraTask.btWaitForClick(Sender: TObject);
begin
  var lRunnerInt: IAbortableTaskAsyncRunner<Integer>;
  if Supports(fRunner, IAbortableTaskAsyncRunner<Integer>, lRunnerInt) then
  begin
    var lWaitResult := lRunnerInt.WaitForTaskResult;
    ShowMessage('Result: ' + IntToStr(lWaitResult.Result) + sLineBreak + sLineBreak +
      'State: ' + IntToStr(Ord(lWaitResult.FinishedState)) + sLineBreak +
      'Exception: [' + lWaitResult.ExceptionClass.ClassName + '] ' + lWaitResult.ExceptionMessage);
  end;
end;

procedure TfraTask.NewTask(const aTask: IAbortableTask<Integer, Integer>;
  const aRunnerList: IAbortableTaskAsyncRunnerList);
begin
  fRunner := TAbortableTaskAsyncRunner<Integer, Integer>.New(aTask, aRunnerList);
end;

procedure TfraTask.ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
begin
  ProgressBar.Min := 0;
  ProgressBar.Max := aMaxWorkCount;
  ProgressBar.Position := 0;
  ProgressBar.Visible := True;
end;

procedure TfraTask.ProgressEnd(const aKey: Integer);
begin
  Free;
end;

procedure TfraTask.ProgressStep(const aKey: Integer; const aWorkCount: Int64);
begin
  ProgressBar.Position := ProgressBar.Position + 1;
end;

end.
