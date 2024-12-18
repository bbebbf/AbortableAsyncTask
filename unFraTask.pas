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

procedure TfraTask.NewTask(const aTask: IAbortableTask<Integer, Integer>;
  const aRunnerList: IAbortableTaskAsyncRunnerList);
begin
  fRunner := TAbortableTaskAsyncRunner<Integer, Integer>.New(aTask, aRunnerList);
end;

procedure TfraTask.ProgressBegin(const aKey: Integer; const aMaxWorkCount: Int64);
begin

end;

procedure TfraTask.ProgressEnd(const aKey: Integer);
begin

end;

procedure TfraTask.ProgressStep(const aKey: Integer; const aWorkCount: Int64);
begin

end;

end.
