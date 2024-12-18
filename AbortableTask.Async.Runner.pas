unit AbortableTask.Async.Runner;

interface

uses System.Classes, System.SysUtils, System.SyncObjs, Helper.Async, AbortableTask.Types;

type
  TAbortableTaskAsyncRunner<T, K> = class(TInterfacedObject, IAbortableTaskAsyncRunner<T>)
  strict private
    fSharedData: IAbortableTaskAsyncSharedData<T>;
    fWorker: TThread;

    function IsRunning: Boolean;
    function WaitForTask: IAbortableTaskResultBase;
    function WaitForTaskResult: IAbortableTaskResult<T>;
    procedure RequestAbort;
    function GetWorkerThreadHandle: THandle;

    constructor Create(const aAbortableTask: IAbortableTask<T, K>;
      const aRunnerList: IAbortableTaskAsyncRunnerList);
  public
    class function New(const aAbortableTask: IAbortableTask<T, K>;
      const aRunnerList: IAbortableTaskAsyncRunnerList = nil): IAbortableTaskAsyncRunner<T>;
    destructor Destroy; override;
  end;

implementation

uses AbortableTask.Result, AbortableTask.Async.RunnerList, AbortableTask.Async.Worker, AbortableTask.Async.SharedData;

{ TAbortableTaskAsyncRunner<T, K> }

class function TAbortableTaskAsyncRunner<T, K>.New(const aAbortableTask: IAbortableTask<T, K>;
  const aRunnerList: IAbortableTaskAsyncRunnerList): IAbortableTaskAsyncRunner<T>;
begin
  Result := TAbortableTaskAsyncRunner<T, K>.Create(aAbortableTask, aRunnerList);
end;

constructor TAbortableTaskAsyncRunner<T, K>.Create(const aAbortableTask: IAbortableTask<T, K>;
  const aRunnerList: IAbortableTaskAsyncRunnerList);
begin
  inherited Create;
  fSharedData := TAbortableTaskAsyncSharedData<T>.Create;
  fWorker := TAbortableAsyncTaskWorker<T, K>.Create(Self, aRunnerList, fSharedData, aAbortableTask);
end;

destructor TAbortableTaskAsyncRunner<T, K>.Destroy;
begin
  fSharedData.RequestAbort;
  WaitForTask;
  fWorker.Free;
  inherited;
end;

function TAbortableTaskAsyncRunner<T, K>.IsRunning: Boolean;
begin
  Result := fSharedData.FinishedState = TAbortableTaskFinishedState.Unknown;
end;

function TAbortableTaskAsyncRunner<T, K>.GetWorkerThreadHandle: THandle;
begin
  Result := fWorker.Handle;
end;

function TAbortableTaskAsyncRunner<T, K>.WaitForTask: IAbortableTaskResultBase;
var
  lWaitObjects: TArray<THandle>;
  lWaitForResult: TWaitForResult;
begin
  SetLength(lWaitObjects, 1);
  lWaitObjects[0] := fWorker.Handle;
  lWaitForResult :=  WaitForWhileProcessMessages(lWaitObjects, TWaitForKind.WaitForOne);
  if lWaitForResult.State in [TWaitForState.Signaled, TWaitForState.Abandoned] then
  begin
    Result := TAbortableAsyncTaskResultBase.Create(fSharedData.FinishedState,
      fSharedData.ExceptionClass, fSharedData.ExceptionMessage);
  end
  else
  begin
    Result := TAbortableAsyncTaskResultBase.Create(TAbortableTaskFinishedState.WaitForError, Self.ClassType, '');
  end;
end;

function TAbortableTaskAsyncRunner<T, K>.WaitForTaskResult: IAbortableTaskResult<T>;
var
  lWaitForTaskResult: IAbortableTaskResultBase;
begin
  lWaitForTaskResult := WaitForTask;
  if lWaitForTaskResult.FinishedState = TAbortableTaskFinishedState.WaitForError then
  begin
    Result := TAbortableAsyncTaskResult<T>.Create(lWaitForTaskResult.FinishedState,
      lWaitForTaskResult.ExceptionClass, lWaitForTaskResult.ExceptionMessage, default(T));
  end
  else
  begin
    Result := TAbortableAsyncTaskResult<T>.Create(lWaitForTaskResult.FinishedState,
      lWaitForTaskResult.ExceptionClass, lWaitForTaskResult.ExceptionMessage, fSharedData.TaskResult);
  end;
end;

procedure TAbortableTaskAsyncRunner<T, K>.RequestAbort;
begin
  fSharedData.RequestAbort;
end;

end.
