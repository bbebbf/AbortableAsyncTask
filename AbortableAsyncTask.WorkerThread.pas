unit AbortableAsyncTask.WorkerThread;

interface

uses System.Classes, AbortableAsyncTask.Types;

type
  TAbortableAsyncTaskWorkerThread<T, K> = class(TThread, IAbortableAsyncProgressIndicator<K>)
  strict private
    fRunner: IAbortableAsyncTaskRunner<T>;
    fAbortableAsyncTask: IAbortableAsyncTask<T, K>;
    fAsyncThreadData: IAbortableAsyncTaskSharedData<T>;
    fRunnerList: IAbortableAsyncTaskList;
    fTaskProgressIndicator: IAbortableAsyncProgressIndicator<K>;
    fFinishedState: TAbortableAsyncTaskTaskFinishedState;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    procedure ProgressBegin(const aKey: K; const aMaxWorkCount: Int64);
    procedure ProgressStep(const aKey: K; const aWorkCount: Int64);
    procedure ProgressEnd(const aKey: K);
    procedure RequestAbort;
  strict protected
    procedure Execute; override;
  public
    constructor Create(const aRunner: IAbortableAsyncTaskRunner<T>;
      const aRunnerList: IAbortableAsyncTaskList;
      const aAsyncThreadData: IAbortableAsyncTaskSharedData<T>;
      const aAbortableAsyncTask: IAbortableAsyncTask<T, K>);
  end;

implementation

uses System.SysUtils;

{ TAbortableAsyncTaskWorkerThread<T, K> }

constructor TAbortableAsyncTaskWorkerThread<T, K>.Create(const aRunner: IAbortableAsyncTaskRunner<T>;
  const aRunnerList: IAbortableAsyncTaskList;
  const aAsyncThreadData: IAbortableAsyncTaskSharedData<T>;
  const aAbortableAsyncTask: IAbortableAsyncTask<T, K>);
begin
  inherited Create;
  fRunner := aRunner;
  fRunnerList := aRunnerList;
  fAsyncThreadData := aAsyncThreadData;
  fAbortableAsyncTask := aAbortableAsyncTask;
  fAbortableAsyncTask.ExchangeProgressIndicator(fTaskProgressIndicator, Self);
end;

procedure TAbortableAsyncTaskWorkerThread<T, K>.Execute;
begin
  var lTaskResult := default(T);
  try
    try
      if Assigned(fRunnerList) then
        fRunnerList.Add(fRunner);

      lTaskResult := fAbortableAsyncTask.ExecuteTask;
      fAsyncThreadData.SetSucceededState(lTaskResult);
    except
      on Ex: EAbortableAsyncTaskAbort do
      begin
        lTaskResult := fAbortableAsyncTask.GetResultForAbort(Ex);
        fAsyncThreadData.SetAbortedState(Ex, lTaskResult);
      end;
      on Ex: Exception do
      begin
        lTaskResult := fAbortableAsyncTask.GetResultForOccurredException(Ex);
        fAsyncThreadData.SetExceptedState(Ex, lTaskResult);
      end;
    end;
  finally
    if Assigned(fRunnerList) then
      fRunnerList.Remove(fRunner);
  end;
end;

procedure TAbortableAsyncTaskWorkerThread<T, K>.RequestAbort;
begin
  if Finished or (fFinishedState = TAbortableAsyncTaskTaskFinishedState.Aborted) then
    Exit;

  raise EAbortableAsyncTaskAbort.Create('Task ' + fAbortableAsyncTask.GetTaskName + ' aborted.');
end;

procedure TAbortableAsyncTaskWorkerThread<T, K>.ProgressBegin(const aKey: K; const aMaxWorkCount: Int64);
begin
  if not Assigned(fTaskProgressIndicator) then
    Exit;

  TThread.Queue(Self,
    procedure()
    begin
      fTaskProgressIndicator.ProgressBegin(aKey, aMaxWorkCount);
    end
  );
end;

procedure TAbortableAsyncTaskWorkerThread<T, K>.ProgressEnd(const aKey: K);
begin
  if not Assigned(fTaskProgressIndicator) then
    Exit;

  TThread.Queue(Self,
    procedure()
    begin
      fTaskProgressIndicator.ProgressEnd(aKey);
    end
  );
end;

procedure TAbortableAsyncTaskWorkerThread<T, K>.ProgressStep(const aKey: K; const aWorkCount: Int64);
begin
  var lAbortRequested := fAsyncThreadData.AbortRequested;
  if lAbortRequested then
  begin
    RequestAbort;
    Exit;
  end;

  if not Assigned(fTaskProgressIndicator) then
    Exit;

  TThread.Queue(Self,
    procedure()
    begin
      fTaskProgressIndicator.ProgressStep(aKey, aWorkCount);
    end
  );
end;

function TAbortableAsyncTaskWorkerThread<T, K>.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TAbortableAsyncTaskWorkerThread<T, K>._AddRef: Integer;
begin
  Result := -1;
end;

function TAbortableAsyncTaskWorkerThread<T, K>._Release: Integer;
begin
  Result := -1;
end;

end.
