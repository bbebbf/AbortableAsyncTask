unit AbortableAsyncTask;

interface

uses System.Classes, System.SysUtils, System.SyncObjs, AbortableAsyncTask.Types;

type
  IAbortableAsyncTaskRunner = interface
    ['{65763F41-A120-4B42-8FB5-472D594956E8}']
    function IsRunning: Boolean;
    function IsAborted: Boolean;
    function IsExcepted: Boolean;
    procedure AbortTask;
    function GetOnFinishedTask: TNotifyEvent;
    procedure SetOnFinishedTask(const aValue: TNotifyEvent);
    function GetExceptionMessage: string;
    property OnFinishedTask: TNotifyEvent read GetOnFinishedTask write SetOnFinishedTask;
    property ExceptionMessage: string read GetExceptionMessage;
  end;

  IAsyncThreadData = interface
    ['{885D45BF-03D1-4732-B851-B34EC3EAB18A}']
    function GetAbortedEvent: TSimpleEvent;
    function GetFinishedEvent: TSimpleEvent;
    function GetExceptionEvent: TSimpleEvent;
    function GetExceptionMessage: string;
    procedure SetExceptionMessage(const aValue: string);
    function GetAbortRequested: Boolean;
    function GetOnFinishedTask: TNotifyEvent;
    procedure SetOnFinishedTask(const aValue: TNotifyEvent);
    procedure RequestAbort;
    property OnFinishedTask: TNotifyEvent read GetOnFinishedTask write SetOnFinishedTask;
    property AbortedEvent: TSimpleEvent read GetAbortedEvent;
    property FinishedEvent: TSimpleEvent read GetFinishedEvent;
    property ExceptionEvent: TSimpleEvent read GetExceptionEvent;
    property AbortRequested: Boolean read GetAbortRequested;
    property ExceptionMessage: string read GetExceptionMessage write SetExceptionMessage;
  end;

  TAbortableAsyncTaskRunner = class(TInterfacedObject, IAbortableAsyncTaskRunner)
  strict private
    fAbortableAsyncTask: IAbortableAsyncTask;
    fAsyncThreadData: IAsyncThreadData;
    fWorker: TThread;

    function IsRunning: Boolean;
    function IsAborted: Boolean;
    function IsExcepted: Boolean;
    procedure AbortTask;
    function GetExceptionMessage: string;
    function GetOnFinishedTask: TNotifyEvent;
    procedure SetOnFinishedTask(const aValue: TNotifyEvent);

    constructor Create(const aAbortableAsyncTask: IAbortableAsyncTask);
  public
    class function New(const aAbortableAsyncTask: IAbortableAsyncTask): IAbortableAsyncTaskRunner;
    destructor Destroy; override;
  end;

implementation

type
  EAbortableAsyncTaskAbort = class(EAbort);

  TAsyncThreadData = class(TInterfacedObject, IAsyncThreadData)
  strict private
    fCritialSection: TCriticalSection;
    fAbortRequested: Boolean;
    fFinishedEvent: TSimpleEvent;
    fAbortedEvent: TSimpleEvent;
    fExceptionEvent: TSimpleEvent;
    fExceptionMessage: string;
    fOnFinishedTask: TNotifyEvent;
    function GetAbortedEvent: TSimpleEvent;
    function GetFinishedEvent: TSimpleEvent;
    function GetExceptionEvent: TSimpleEvent;
    function GetExceptionMessage: string;
    procedure SetExceptionMessage(const aValue: string);
    function GetAbortRequested: Boolean;
    procedure RequestAbort;
    function GetOnFinishedTask: TNotifyEvent;
    procedure SetOnFinishedTask(const aValue: TNotifyEvent);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TWorkerThread = class(TThread, IAbortableAsyncThreadProgressIndicator)
  strict private
    fRunner: TObject;
    fAbortableAsyncTask: IAbortableAsyncTask;
    fAsyncThreadData: IAsyncThreadData;
    fTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator;
    fAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc;
    fTaskAborted: Boolean;
    fTaskExcepted: Boolean;

    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;

    procedure ProgressBegin(const aMaxWorkCount: Int64);
    procedure ProgressStep(const aWorkCount: Int64);
    procedure ProgressEnd();
    procedure AbortTask;

    procedure HandleAborted(const aEAbortMessage: string);
    procedure HandleExcepted(const aExceptionMessage: string);
  strict protected
    procedure Execute; override;
  public
    constructor Create(const aRunner: TObject;
      const aAsyncThreadData: IAsyncThreadData;
      const aAbortableAsyncTask: IAbortableAsyncTask;
      const aTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator;
      const aAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc);
  end;

{ TAbortableAsyncTaskRunner }

class function TAbortableAsyncTaskRunner.New(const aAbortableAsyncTask: IAbortableAsyncTask): IAbortableAsyncTaskRunner;
begin
  Result := TAbortableAsyncTaskRunner.Create(aAbortableAsyncTask);
end;

constructor TAbortableAsyncTaskRunner.Create(const aAbortableAsyncTask: IAbortableAsyncTask);
begin
  inherited Create;
  fAbortableAsyncTask := aAbortableAsyncTask;
  fAsyncThreadData := TAsyncThreadData.Create;

  var lAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc := nil;
  var lTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator := nil;
  aAbortableAsyncTask.GetAbortRequestedProc(lAbortRequestedProc);
  aAbortableAsyncTask.GetTaskProgressIndicator(lTaskProgressIndicator);
  if not Assigned(lAbortRequestedProc) and not Assigned(lTaskProgressIndicator) then
  begin
    raise EArgumentException.Create('GetAbortRequestedProc and GetTaskProgressIndicator returned NIL. You must at least implement one of them.');
  end;

  fWorker := TWorkerThread.Create(Self, fAsyncThreadData, fAbortableAsyncTask,
    lTaskProgressIndicator, lAbortRequestedProc);
end;

destructor TAbortableAsyncTaskRunner.Destroy;
begin
  fAsyncThreadData.RequestAbort;
  inherited;
end;

function TAbortableAsyncTaskRunner.IsAborted: Boolean;
begin
  Result := fAsyncThreadData.AbortedEvent.WaitFor(0) = TWaitResult.wrSignaled;
end;

function TAbortableAsyncTaskRunner.IsExcepted: Boolean;
begin
  Result := fAsyncThreadData.ExceptionEvent.WaitFor(0) = TWaitResult.wrSignaled;
end;

function TAbortableAsyncTaskRunner.IsRunning: Boolean;
begin
  Result := fAsyncThreadData.FinishedEvent.WaitFor(0) <> TWaitResult.wrSignaled;
end;

function TAbortableAsyncTaskRunner.GetExceptionMessage: string;
begin
  Result := fAsyncThreadData.ExceptionMessage;
end;

function TAbortableAsyncTaskRunner.GetOnFinishedTask: TNotifyEvent;
begin
  Result := fAsyncThreadData.OnFinishedTask;
end;

procedure TAbortableAsyncTaskRunner.SetOnFinishedTask(const aValue: TNotifyEvent);
begin
  fAsyncThreadData.OnFinishedTask := aValue;
end;

procedure TAbortableAsyncTaskRunner.AbortTask;
begin
  fAsyncThreadData.RequestAbort;
end;

{ TWorkerThread }

constructor TWorkerThread.Create(const aRunner: TObject;
  const aAsyncThreadData: IAsyncThreadData;
  const aAbortableAsyncTask: IAbortableAsyncTask;
  const aTaskProgressIndicator: IAbortableAsyncTaskProgressIndicator;
  const aAbortRequestedProc: TAbortableAsyncTaskAbortRequestedProc);
begin
  inherited Create;
  FreeOnTerminate := True;
  fAsyncThreadData := aAsyncThreadData;
  fAbortableAsyncTask := aAbortableAsyncTask;
  fTaskProgressIndicator := aTaskProgressIndicator;
  fAbortRequestedProc := aAbortRequestedProc;
end;

procedure TWorkerThread.Execute;
begin
  try
    try
      fAbortableAsyncTask.SetAsyncProgressIntf(Self);
      fAbortableAsyncTask.ExecuteTask;
    except
      on Ex: EAbortableAsyncTaskAbort do
      begin
        HandleAborted(Ex.Message);
      end;
      on Ex: Exception do
      begin
        HandleExcepted(Ex.Message);
      end;
    end;
  finally
    fAsyncThreadData.FinishedEvent.SetEvent;
    if Assigned(fAsyncThreadData.OnFinishedTask) then
    begin
      TThread.Synchronize(Self,
        procedure()
        begin
          fAsyncThreadData.OnFinishedTask(fRunner);
        end
      );
    end;
  end;
end;

procedure TWorkerThread.HandleAborted(const aEAbortMessage: string);
begin
  fTaskAborted := True;
  fAsyncThreadData.ExceptionMessage := aEAbortMessage;
  fAsyncThreadData.AbortedEvent.SetEvent;
end;

procedure TWorkerThread.HandleExcepted(const aExceptionMessage: string);
begin
  fTaskExcepted := True;
  fAsyncThreadData.ExceptionMessage := aExceptionMessage;
  fAsyncThreadData.ExceptionEvent.SetEvent;
end;

procedure TWorkerThread.AbortTask;
begin
  if Finished or fTaskAborted then
    Exit;

  raise EAbortableAsyncTaskAbort.Create('Task ' + fAbortableAsyncTask.GetTaskName + ' aborted.');
end;

procedure TWorkerThread.ProgressBegin(const aMaxWorkCount: Int64);
begin
  if not Assigned(fTaskProgressIndicator) then
    Exit;

  TThread.Synchronize(Self,
    procedure()
    begin
      fTaskProgressIndicator.ProgressBegin(aMaxWorkCount);
    end
  );
end;

procedure TWorkerThread.ProgressEnd;
begin
  if not Assigned(fTaskProgressIndicator) then
    Exit;

  TThread.Synchronize(Self,
    procedure()
    begin
      fTaskProgressIndicator.ProgressEnd();
    end
  );
end;

procedure TWorkerThread.ProgressStep(const aWorkCount: Int64);
begin
  var lAbortRequested := fAsyncThreadData.AbortRequested;
  if lAbortRequested then
  begin
    AbortTask;
    Exit;
  end;

  if Assigned(fTaskProgressIndicator) then
  begin
    TThread.Synchronize(Self,
      procedure()
      begin
        fTaskProgressIndicator.ProgressStep(aWorkCount, lAbortRequested);
      end
    );
    if lAbortRequested then
    begin
      AbortTask;
      Exit;
    end;
  end;

  if Assigned(fAbortRequestedProc) then
  begin
    TThread.Synchronize(Self,
      procedure()
      begin
        fAbortRequestedProc(lAbortRequested);
      end
    );
    if lAbortRequested then
    begin
      AbortTask;
    end;
  end;
end;

function TWorkerThread.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TWorkerThread._AddRef: Integer;
begin
  Result := -1;
end;

function TWorkerThread._Release: Integer;
begin
  Result := -1;
end;

{ TAsyncThreadData }

constructor TAsyncThreadData.Create;
begin
  inherited Create;
  fCritialSection := TCriticalSection.Create;
  fFinishedEvent := TSimpleEvent.Create;
  fAbortedEvent := TSimpleEvent.Create;
  fExceptionEvent := TSimpleEvent.Create;
end;

destructor TAsyncThreadData.Destroy;
begin
  fExceptionEvent.Free;
  fAbortedEvent.Free;
  fFinishedEvent.Free;
  fCritialSection.Free;
  inherited;
end;

function TAsyncThreadData.GetAbortedEvent: TSimpleEvent;
begin
  Result := fAbortedEvent;
end;

function TAsyncThreadData.GetFinishedEvent: TSimpleEvent;
begin
  Result := fFinishedEvent;
end;

function TAsyncThreadData.GetOnFinishedTask: TNotifyEvent;
begin
  Result := fOnFinishedTask;
end;

function TAsyncThreadData.GetExceptionEvent: TSimpleEvent;
begin
  fCritialSection.Enter;
  try
    Result := fExceptionEvent;
  finally
    fCritialSection.Leave;
  end;
end;

function TAsyncThreadData.GetAbortRequested: Boolean;
begin
  fCritialSection.Enter;
  try
    Result := fAbortRequested;
  finally
    fCritialSection.Leave;
  end;
end;

function TAsyncThreadData.GetExceptionMessage: string;
begin
  fCritialSection.Enter;
  try
    Result := fExceptionMessage;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAsyncThreadData.RequestAbort;
begin
  fCritialSection.Enter;
  try
    fAbortRequested := True;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAsyncThreadData.SetExceptionMessage(const aValue: string);
begin
  fCritialSection.Enter;
  try
    fExceptionMessage := aValue;
  finally
    fCritialSection.Leave;
  end;
end;

procedure TAsyncThreadData.SetOnFinishedTask(const aValue: TNotifyEvent);
begin
  fCritialSection.Enter;
  try
    fOnFinishedTask := aValue;
  finally
    fCritialSection.Leave;
  end;
end;

end.
