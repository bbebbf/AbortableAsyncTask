unit AbortableTask.Async.Worker;

interface

uses System.Classes, AbortableTask.Types;

type
  TAbortableAsyncTaskWorker<T, K> = class(TThread, IAbortableTaskProcessor)
  strict private
    fRunner: IAbortableTaskAsyncRunner<T>;
    fAbortableTask: IAbortableTask<T, K>;
    fSharedData: IAbortableTaskAsyncSharedData<T>;
    fRunnerList: IAbortableTaskAsyncRunnerList;
    fAbortRequested: Boolean;

    procedure QueueMethod(const aQueueableMethod: TQueueableMethod);
    procedure CheckForRequestAbort;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    procedure RequestAbort;
  strict protected
    procedure Execute; override;
  public
    constructor Create(const aRunner: IAbortableTaskAsyncRunner<T>;
      const aRunnerList: IAbortableTaskAsyncRunnerList;
      const aAsyncThreadData: IAbortableTaskAsyncSharedData<T>;
      const aAbortableTask: IAbortableTask<T, K>);
  end;

implementation

uses System.SysUtils;

{ TAbortableAsyncTaskWorker<T, K> }

constructor TAbortableAsyncTaskWorker<T, K>.Create(const aRunner: IAbortableTaskAsyncRunner<T>;
  const aRunnerList: IAbortableTaskAsyncRunnerList;
  const aAsyncThreadData: IAbortableTaskAsyncSharedData<T>;
  const aAbortableTask: IAbortableTask<T, K>);
begin
  inherited Create;
  fRunner := aRunner;
  fRunnerList := aRunnerList;
  fSharedData := aAsyncThreadData;
  fAbortableTask := aAbortableTask;
  fAbortableTask.SetTaskProcessor(Self);
end;

procedure TAbortableAsyncTaskWorker<T, K>.Execute;
begin
  var lTaskResult := default(T);
  try
    try
      if Assigned(fRunnerList) then
        fRunnerList.Add(fRunner);

      lTaskResult := fAbortableTask.ExecuteTask;
      fSharedData.SetSucceededState(lTaskResult);
    except
      on Ex: EAbortableAsyncTaskAbort do
      begin
        lTaskResult := fAbortableTask.GetResultForAbort(Ex);
        fSharedData.SetAbortedState(Ex, lTaskResult);
      end;
      on Ex: Exception do
      begin
        lTaskResult := fAbortableTask.GetResultForOccurredException(Ex);
        fSharedData.SetExceptedState(Ex, lTaskResult);
      end;
    end;
  finally
    if Assigned(fRunnerList) then
      fRunnerList.Remove(fRunner);
  end;
end;

procedure TAbortableAsyncTaskWorker<T, K>.RequestAbort;
begin
  if Finished or fAbortRequested then
    Exit;

  fAbortRequested := True;
  raise EAbortableAsyncTaskAbort.Create('Task ' + fAbortableTask.GetTaskName + ' aborted.');
end;

procedure TAbortableAsyncTaskWorker<T, K>.CheckForRequestAbort;
begin
  if fSharedData.AbortRequested then
  begin
    RequestAbort;
  end;
end;

procedure TAbortableAsyncTaskWorker<T, K>.QueueMethod(const aQueueableMethod: TQueueableMethod);
begin
  TThread.Queue(Self,
    procedure()
    begin
      aQueueableMethod();
    end
    );
end;

function TAbortableAsyncTaskWorker<T, K>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TAbortableAsyncTaskWorker<T, K>._AddRef: Integer;
begin
  Result := -1;
end;

function TAbortableAsyncTaskWorker<T, K>._Release: Integer;
begin
  Result := -1;
end;

end.
