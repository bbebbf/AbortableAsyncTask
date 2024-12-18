unit AbortableAsyncTask.Runner;

interface

uses System.Classes, System.SysUtils, System.SyncObjs, Helper.Async, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskRunner<T, K> = class(TInterfacedObject, IAbortableAsyncTaskRunner<T>)
  strict private
    fAsyncThreadData: IAbortableAsyncTaskSharedData<T>;
    fWorker: TThread;

    function IsRunning: Boolean;
    function WaitForTask: IAbortableAsyncTaskResultBase;
    function WaitForTaskResult: IAbortableAsyncTaskResult<T>;
    procedure RequestAbort;

    function GeTAbortableAsyncTaskWorkerThreadHandle: THandle;
    function GetRunnerObject: TObject;
    function GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
    function GetTaskResult: T;
    function GetExceptionMessage: string;
    function GetExceptionClass: TClass;

    constructor Create(const aAbortableAsyncTask: IAbortableAsyncTask<T, K>;
      const aRunnerList: IAbortableAsyncTaskList);
  public
    class function New(const aAbortableAsyncTask: IAbortableAsyncTask<T, K>;
      const aRunnerList: IAbortableAsyncTaskList = nil): IAbortableAsyncTaskRunner<T>;
    destructor Destroy; override;
  end;

implementation

uses AbortableAsyncTask.Result, AbortableAsyncTask.List, AbortableAsyncTask.WorkerThread, AbortableAsyncTask.SharedData;

{ TAbortableAsyncTaskRunner<T, K> }

class function TAbortableAsyncTaskRunner<T, K>.New(const aAbortableAsyncTask: IAbortableAsyncTask<T, K>;
  const aRunnerList: IAbortableAsyncTaskList): IAbortableAsyncTaskRunner<T>;
begin
  Result := TAbortableAsyncTaskRunner<T, K>.Create(aAbortableAsyncTask, aRunnerList);
end;

constructor TAbortableAsyncTaskRunner<T, K>.Create(const aAbortableAsyncTask: IAbortableAsyncTask<T, K>;
  const aRunnerList: IAbortableAsyncTaskList);
begin
  inherited Create;
  fAsyncThreadData := TAbortableAsyncTaskSharedData<T>.Create;
  fWorker := TAbortableAsyncTaskWorkerThread<T, K>.Create(Self, aRunnerList, fAsyncThreadData, aAbortableAsyncTask);
end;

destructor TAbortableAsyncTaskRunner<T, K>.Destroy;
begin
  fAsyncThreadData.RequestAbort;
  WaitForTask;
  fWorker.Free;
  inherited;
end;

function TAbortableAsyncTaskRunner<T, K>.GetRunnerObject: TObject;
begin
  Result := Self;
end;

function TAbortableAsyncTaskRunner<T, K>.IsRunning: Boolean;
begin
  Result := fAsyncThreadData.FinishedState = TAbortableAsyncTaskTaskFinishedState.Unknown;
end;

function TAbortableAsyncTaskRunner<T, K>.GetExceptionClass: TClass;
begin
  Result := fAsyncThreadData.ExceptionClass;
end;

function TAbortableAsyncTaskRunner<T, K>.GetExceptionMessage: string;
begin
  Result := fAsyncThreadData.ExceptionMessage;
end;

function TAbortableAsyncTaskRunner<T, K>.GetFinishedState: TAbortableAsyncTaskTaskFinishedState;
begin
  Result := fAsyncThreadData.FinishedState;
end;

function TAbortableAsyncTaskRunner<T, K>.GetTaskResult: T;
begin
  Result := fAsyncThreadData.TaskResult;
end;

function TAbortableAsyncTaskRunner<T, K>.GeTAbortableAsyncTaskWorkerThreadHandle: THandle;
begin
  Result := fWorker.Handle;
end;

function TAbortableAsyncTaskRunner<T, K>.WaitForTask: IAbortableAsyncTaskResultBase;
var
  lWaitObjects: TArray<THandle>;
  lWaitForResult: TWaitForResult;
begin
  SetLength(lWaitObjects, 1);
  lWaitObjects[0] := fWorker.Handle;
  lWaitForResult :=  WaitForWhileProcessMessages(lWaitObjects, TWaitForKind.WaitForOne);
  if lWaitForResult.State in [TWaitForState.Signaled, TWaitForState.Abandoned] then
  begin
    Result := TAbortableAsyncTaskResultBase.Create(fAsyncThreadData.FinishedState,
      fAsyncThreadData.ExceptionClass, fAsyncThreadData.ExceptionMessage);
  end
  else
  begin
    Result := TAbortableAsyncTaskResultBase.Create(TAbortableAsyncTaskTaskFinishedState.WaitForError, Self.ClassType, '');
  end;
end;

function TAbortableAsyncTaskRunner<T, K>.WaitForTaskResult: IAbortableAsyncTaskResult<T>;
var
  lWaitForTaskResult: IAbortableAsyncTaskResultBase;
begin
  lWaitForTaskResult := WaitForTask;
  if lWaitForTaskResult.FinishedState = TAbortableAsyncTaskTaskFinishedState.WaitForError then
  begin
    Result := TAbortableAsyncTaskResult<T>.Create(lWaitForTaskResult.FinishedState,
      lWaitForTaskResult.ExceptionClass, lWaitForTaskResult.ExceptionMessage, default(T));
  end
  else
  begin
    Result := TAbortableAsyncTaskResult<T>.Create(lWaitForTaskResult.FinishedState,
      lWaitForTaskResult.ExceptionClass, lWaitForTaskResult.ExceptionMessage, fAsyncThreadData.TaskResult);
  end;
end;

procedure TAbortableAsyncTaskRunner<T, K>.RequestAbort;
begin
  fAsyncThreadData.RequestAbort;
end;

end.
